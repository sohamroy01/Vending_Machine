`timescale 1ns / 1ps

module top_module (
    input clk,                    // 100 MHz board clock
    input rst,                    // Reset signal
    
    // Raw inputs from physical board buttons (noisy)
    input coin_btn,
    input pq_btn,
    input buy_btn,
    input go_btn,
    
    // Switch input for product selection
    input [1:0] s1s2,
    
    // Status LED outputs
    output done,
    output error,
    output [1:0] selected_product_led,
    output [3:0] selected_quantity_led,
    output purchase_mode_active,
    output idle_mode_status,
    
    // Seven Segment Display outputs
    output [6:0] seg,
    output [3:0] an
);


    // Wires to carry the clean, debounced button signals
    wire coin_db;
    wire pq_db;
    wire buy_db;
    wire go_db;

    // Wires to carry data from the vending machine out to the display
    wire [7:0] balance_display;
    wire [7:0] return_display;


    debouncer db_coin (
        .clk(clk), .rst(rst), .button_in(coin_btn), .button_out(coin_db)
    );
    
    debouncer db_pq (
        .clk(clk), .rst(rst), .button_in(pq_btn), .button_out(pq_db)
    );
    
    debouncer db_buy (
        .clk(clk), .rst(rst), .button_in(buy_btn), .button_out(buy_db)
    );
    
    debouncer db_go (
        .clk(clk), .rst(rst), .button_in(go_btn), .button_out(go_db)
    );


   
    Vending_machine vm_inst (
        .clk(clk),
        .rst(rst),
        .coin(coin_db),         // using debounced signal
        .pq(pq_db),             // using debounced signal
        .buy(buy_db),           // using debounced signal
        .go(go_db),             // using debounced signal
        .s1s2(s1s2),
        .done(done),
        .error(error),
        .balance_display(balance_display), // internal wire
        .return_display(return_display),   // internal wire
        .selected_product_led(selected_product_led),
        .selected_quantity_led(selected_quantity_led),
        .purchase_mode_active(purchase_mode_active),
        .idle_mode_status(idle_mode_status)
    );


    // Connected directly to 'return_display' to strictly show the return value
    seven_segment display_inst (
        .clk(clk),
        .rst(rst),
        .number(return_display), 
        .seg(seg),
        .an(an)
    );

endmodule