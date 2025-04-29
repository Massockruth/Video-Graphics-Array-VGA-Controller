# Video-Graphics-Array-VGA-Controller
# Summary:
For this project, students will learn how to use VGA interface on DE-1 FPGA board. The
following objectives will be covered for the project:
1) Display red, blue, green on the monitor with three switches (mode 640x480 --60Hz).
2) 7 segment HEX display for each color.
A demo video has been uploaded on Canvas.
# Introduction:
Video Graphics Array (VGA) is an analog video display controller. On DE-1 SoC, Cyclone
V accesses VGA interface through DAC ADV7123 to transfer digital signal to analog signal. As
shown in Figure 1, the FPGA sends 8 signals to DAC and VGA port. VGA_R, VGA_G, VGA_B
are 8-bits signals represent the intensity of each color. VGA_CLK is also called Pixel_CLK that
is being used as a base clock for driving the VGA display. VGA_sync_N selects the mode between
Green DAC and RGB DAC. VGA_BLANK_N is set to 0 during the retrace period of the line or
of the frame. 
