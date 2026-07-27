`timescale 1ns / 1ps

module top_module_tb();

    // ---------------------------------------------------------
    // 1. INTERFACE SIGNALS
    // ---------------------------------------------------------
    reg clk;
    reg rst;
    reg buy;
    reg coin;
    reg pq;
    reg go;
    reg [1:0] s1s2;

    wire [6:0] seg;
    wire [3:0] an;
    wire [7:0] led;
    wire error;

    // ---------------------------------------------------------
    // 2. MONITORING SIGNALS (Drag these into Vivado Waveform)
    // ---------------------------------------------------------
    // These allow you to see internal state without $display
    wire [7:0] w_balance = uut.vm.balance_display;
    wire [7:0] w_return  = uut.vm.return_display;
    wire [1:0] w_state   = uut.vm.current_state;
    wire [7:0] w_total_cost = uut.vm.total_cost;
    
    // Internal stock tracking
    wire [7:0] stock_p1 = uut.vm.stock_p1;
    wire [7:0] stock_p2 = uut.vm.stock_p2;

    // ---------------------------------------------------------
    // 3. UNIT UNDER TEST (UUT)
    // ---------------------------------------------------------
    top_module uut (
        .clk(clk), 
        .rst(rst), 
        .buy(buy), 
        .coin(coin), 
        .pq(pq), 
        .go(go), 
        .s1s2(s1s2), 
        .seg(seg), 
        .an(an), 
        .led(led), 
        .error(error)
    );

    // 100MHz Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // ---------------------------------------------------------
    // 4. DEBOUNCE SIMULATION TASK
    // ---------------------------------------------------------
    task press_button_with_bounce;
        output reg btn;
        begin
            // Physical bounce noise
            btn = 1; #20;
            btn = 0; #20;
            btn = 1; #20;
            btn = 0; #20;
            btn = 1; 
            // Hold for 11ms (Threshold is 10ms)
            #11000000; 
            btn = 0;
            // Stabilization time
            #10000000; 
        end
    endtask

    // ---------------------------------------------------------
    // 5. TEST SEQUENCE
    // ---------------------------------------------------------
    initial begin
        // Reset System
        rst = 1;
        buy = 0; coin = 0; pq = 0; go = 0; s1s2 = 2'b00;
        #100;
        rst = 0;
        #200;

        // --- SCENARIO 1: Product 1 (5 units) ---
        // Verify balance updates and transition to Purchase state
        press_button_with_bounce(buy);
        s1s2 = 2'b01; 
        #100;
        press_button_with_bounce(pq);   // Quantity = 1
        press_button_with_bounce(coin); // Add 5 units
        press_button_with_bounce(go);   // Transaction Done
        
        #500; // Observe change in w_return and stock_p1

        // --- SCENARIO 2: ERROR (Insufficient Funds) ---
        press_button_with_bounce(buy);
        s1s2 = 2'b10; // Product 2 (10 units)
        #100;
        press_button_with_bounce(pq); 
        // DO NOT add coins
        press_button_with_bounce(go);   // Transaction Error
        
        #500; // Observe error wire going high

        // --- SCENARIO 3: MULTI-PURCHASE (Product 1 x 2 = 10 units) ---
        press_button_with_bounce(buy);
        s1s2 = 2'b01;
        #100;
        press_button_with_bounce(pq); 
        press_button_with_bounce(pq); 
        press_button_with_bounce(coin); 
        press_button_with_bounce(coin); 
        press_button_with_bounce(go);

        #1000;
        $finish;
    end

endmodule