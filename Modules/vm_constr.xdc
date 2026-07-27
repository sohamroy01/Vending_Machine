# 100 MHz board clock
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# Set Bank 0 voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Switches
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {s1s2[0]}] ; # SW0
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {s1s2[1]}] ; # SW1

# sw[15] for Reset/Buy (rst/buy) - Leftmost switch
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {buy_btn}]  ; # SW15

# Using the 5 on-board buttons for the vending machine actions
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {coin_btn}] ; # btnC (Center)
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {pq_btn}]   ; # btnU (Up)
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {rst}]      ; # btnD (Down) - commonly used for Reset
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports {go_btn}]   ; # btnR (Right)

# LEDs
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {idle_mode_status}]     ; # LED0
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {purchase_mode_active}] ; # LED1

# Transaction statuses
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {done}]                 ; # LED2
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {error}]                ; # LED3

# Selected Product (2 bits)
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {selected_product_led[0]}] ; # LED4
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {selected_product_led[1]}] ; # LED5

# Selected Quantity (4 bits)
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {selected_quantity_led[0]}] ; # LED6
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {selected_quantity_led[1]}] ; # LED7
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {selected_quantity_led[2]}] ; # LED8
set_property -dict {PACKAGE_PIN V3  IOSTANDARD LVCMOS33} [get_ports {selected_quantity_led[3]}] ; # LED9

# 7-Segment Display Anodes
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports {an[0]}] ; # AN0 (Rightmost)
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {an[1]}] ; # AN1
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports {an[2]}] ; # AN2
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports {an[3]}] ; # AN3 (Leftmost)

# 7-Segment Display Segments (A to G)
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports {seg[0]}] ; # SEG_A
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports {seg[1]}] ; # SEG_B
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports {seg[2]}] ; # SEG_C
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports {seg[3]}] ; # SEG_D
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {seg[4]}] ; # SEG_E
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {seg[5]}] ; # SEG_F
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports {seg[6]}] ; # SEG_G