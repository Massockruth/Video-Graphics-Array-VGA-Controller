------------------------------------------------------------------------
-- Title			: Project - VGA Controller
-- Author		: Keila Souriac & Ruth Massock
-- Date			: 11/08/2024
-- Description : This program is the driver for the VGA interface on the
--				     DE-1 FPGA board.
------------------------------------------------------------------------
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;
 ----------------------------------------------------------
 ENTITY Project IS
 GENERIC (
	Ha: INTEGER := 96; 	--Hpulse
	Hb: INTEGER := 144;	--Hpulse+HBP
	Hc: INTEGER := 784; 	--Hpulse+HBP+Hactive
	Hd: INTEGER := 800; 	--Hpulse+HBP+Hactive+HFP
	Va: INTEGER := 2; 	--Vpulse
	Vb: INTEGER := 35; 	--Vpulse+VBP
	Vc: INTEGER := 515; 	--Vpulse+VBP+Vactive
	Vd: INTEGER := 525); --Vpulse+VBP+Vactive+VFP
 PORT (
	clk: IN STD_LOGIC; --50MHz in our board
	red_switch, green_switch, blue_switch: IN STD_LOGIC;
	pixel_clk: BUFFER STD_LOGIC;
	Hsync, Vsync: BUFFER STD_LOGIC;
	R, G, B: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	HEX0,HEX2,HEX3,HEX4,HEX5: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	nblanck, nsync : OUT STD_LOGIC);
 END Project;
 ----------------------------------------------------------
 ARCHITECTURE vga OF Project IS
 SIGNAL Hactive, Vactive, dena: STD_LOGIC;
 ------HEX display signals------------
	signal M: STD_LOGIC_VECTOR(6 DOWNTO 0):="0101010";	
	signal K: STD_LOGIC_VECTOR(6 DOWNTO 0):="0001001"; -- Letter H as a K
	signal S: STD_LOGIC_VECTOR(6 DOWNTO 0):="0010010"; -- letter S
	signal O: STD_LOGIC_VECTOR(6 DOWNTO 0):="1111111"; -- all segments off
	signal Red	: STD_LOGIC_VECTOR(6 DOWNTO 0):="0101111";	--Lowercase r (RUTH & RED)
	signal Green: STD_LOGIC_VECTOR(6 DOWNTO 0):="0000010"; -- Letter G (GREEN)
	signal Blue	: STD_LOGIC_VECTOR(6 DOWNTO 0):="0000000"; -- Letter B (BLUE)
 BEGIN
 -------------------------------------------------------
 --Part 1: CONTROL GENERATOR
 -------------------------------------------------------
 --Static signals for DACs:
 nblanck <= '1'; --no direct blanking
 nsync <= '0'; --no sync on green
 --Create pixel clock (50MHz->25MHz):
 PROCESS (clk)
 BEGIN
 IF (clk'EVENT AND clk='1') THEN
 pixel_clk <= NOT pixel_clk;
 END IF;
 END PROCESS;
 --Horizontal signals generation:
 PROCESS (pixel_clk)
 VARIABLE Hcount: INTEGER RANGE 0 TO Hd;
 BEGIN
 IF (pixel_clk'EVENT AND pixel_clk='1') THEN
 Hcount := Hcount + 1;
 IF (Hcount=Ha) THEN
 Hsync <= '1';
 ELSIF (Hcount=Hb) THEN
 Hactive <= '1';
 ELSIF (Hcount=Hc) THEN
 Hactive <= '0';
 ELSIF (Hcount=Hd) THEN
 Hsync <= '0';
 Hcount := 0;
 END IF;
 END IF;
 END PROCESS;
 --Vertical signals generation:
 PROCESS (Hsync)
 VARIABLE Vcount: INTEGER RANGE 0 TO Vd;
 BEGIN
 IF (Hsync'EVENT AND Hsync='0') THEN
 Vcount := Vcount + 1;
 IF (Vcount=Va) THEN
 Vsync <= '1';
 ELSIF (Vcount=Vb) THEN
 Vactive <= '1';
 ELSIF (Vcount=Vc) THEN
 Vactive <= '0';
 ELSIF (Vcount=Vd) THEN
 Vsync <= '0';
 Vcount := 0;
 END IF;
 END IF;
 END PROCESS;
 ---Display enable generation:
 dena <= Hactive AND Vactive;
 -------------------------------------------------------
 --Part 2: IMAGE GENERATOR
 -------------------------------------------------------
 PROCESS (Hsync, Vsync, Vactive, dena, red_switch,
 green_switch, blue_switch)
 VARIABLE line_counter: INTEGER RANGE 0 TO Vc;
 BEGIN
 IF (Vsync='0') THEN
 line_counter := 0;
 ELSIF (Hsync'EVENT AND Hsync='1') THEN
 IF (Vactive='1') THEN
 line_counter := line_counter + 1;
 END IF;
 END IF;
 IF (dena='1') THEN
 IF (line_counter=1) THEN
 R <= (OTHERS => '1');
 G <= (OTHERS => '0');
 B <= (OTHERS => '0');
 ELSIF (line_counter>1 AND line_counter<=3) THEN
 R <= (OTHERS => '0');
 G <= (OTHERS => '1');
 B <= (OTHERS => '0');
 ELSIF (line_counter>3 AND line_counter<=6) THEN
 R <= (OTHERS => '0');
 G <= (OTHERS => '0');
 B <= (OTHERS => '1');
 ELSE
 R <= (OTHERS => red_switch);
 G <= (OTHERS => green_switch);
 B <= (OTHERS => blue_switch);
 END IF;
 ELSE
 R <= (OTHERS => '0');
 G <= (OTHERS => '0');
 B <= (OTHERS => '0');
 END IF;
 END PROCESS;
 -------- case for hex display---------------
 PROCESS (red_switch,
 green_switch, blue_switch)
 BEGIN
 ----Display our initials-------
 HEX5 <= Red;
 HEX4 <= M;
 HEX3 <= K;
 HEX2 <= S;
 
 If(red_switch <= '0' and green_switch <= '0' and blue_switch <= '0') then
 HEX0 <= O;
 elsif(red_switch <= '1' and green_switch <= '0' and blue_switch <= '0' ) then
 HEX0 <= Red;
 Elsif(red_switch <= '0' and green_switch <= '1' and blue_switch <= '0') then
 HEX0  <= Green;
 ElsIf(red_switch <= '0' and green_switch <= '0' and blue_switch <= '1') then
 HEX0 <= Blue;
 Else
 HEX0 <= O;
 END IF;
 END PROCESS;
 END vga;
 ----------------------------------------------------------
