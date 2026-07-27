`timescale 1ns / 1ps

module Vending_machine (  
    input clk,
    input rst,
    input coin,           
    input pq,             
    input buy,            
    input go,             
    input [1:0] s1s2,     
    
    output reg done,
    output reg error,
    output reg [7:0] balance_display,
    output reg [7:0] return_display,
    output reg [1:0] selected_product_led,
    output reg [3:0] selected_quantity_led,
    output reg purchase_mode_active,
    output reg idle_mode_status    
);

    parameter IDLE     = 2'b00;
    parameter PURCHASE = 2'b01;
    parameter DONE     = 2'b10;
    parameter ERROR    = 2'b11;

    parameter PRICE_P1 = 8'd5;   
    parameter PRICE_P2 = 8'd10;  

    reg [1:0] current_state, next_state;

    reg [7:0] quantity_p1;       
    reg [7:0] quantity_p2;       
    reg [7:0] stock_p1;          
    reg [7:0] stock_p2;          
    
    wire [7:0] total_cost;
    wire sufficient_balance;
    wire sufficient_stock;
    
    assign total_cost = (PRICE_P1 * quantity_p1) + (PRICE_P2 * quantity_p2);
    assign sufficient_balance = (balance_display >= total_cost);
    assign sufficient_stock = (stock_p1 >= quantity_p1) && (stock_p2 >= quantity_p2);
    
    // STATE REGISTER      
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // NEXT STATE LOGIC (COMBINATIONAL)
    always @(*) begin
        next_state = current_state;  
        
        case (current_state)
            IDLE: begin
                if (buy) next_state = PURCHASE;
            end
            PURCHASE: begin
                if (go) begin
                    if (sufficient_balance && sufficient_stock) next_state = DONE;
                    else next_state = ERROR;
                end
            end
            DONE: begin
                // WAIT here until the user presses 'buy' to start the NEXT transaction
                if (buy) next_state = PURCHASE;
            end
            ERROR: begin
                // WAIT here until the user presses 'buy' to try again
                if (buy) next_state = PURCHASE;
            end
            default: next_state = IDLE;
        endcase
    end

    // OUTPUT AND DATAPATH LOGIC (SEQUENTIAL)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            balance_display <= 8'd0;
            return_display <= 8'd0;
            quantity_p1 <= 8'd0;
            quantity_p2 <= 8'd0;
            stock_p1 <= 8'd10;         
            stock_p2 <= 8'd10;         
            idle_mode_status <= 1'b1;
            purchase_mode_active <= 1'b0;
            done <= 1'b0;
            error <= 1'b0;
            selected_product_led <= 2'b00;
            selected_quantity_led <= 4'd0;
        end
        else begin
            // Update mode status lights continuously based on state
            idle_mode_status <= (current_state == IDLE);
            purchase_mode_active <= (current_state == PURCHASE);

            case (current_state)
                IDLE: begin
                    balance_display <= 8'd0;
                    return_display <= 8'd0;
                    quantity_p1 <= 8'd0;
                    quantity_p2 <= 8'd0;
                    selected_product_led <= 2'b00;
                    selected_quantity_led <= 4'd0;
                end

                PURCHASE: begin
                    done <= 1'b0;
                    error <= 1'b0;
                    
                    // Add coins
                    if (coin) begin
                        balance_display <= balance_display + 8'd5;
                    end
                    
                    // Select product and increment quantity
                    if (s1s2 == 2'b01) begin
                        selected_product_led <= 2'b01;
                        if (pq) quantity_p1 <= quantity_p1 + 8'd1;
                        selected_quantity_led <= quantity_p1[3:0];
                    end
                    else if (s1s2 == 2'b10) begin
                        selected_product_led <= 2'b10;
                        if (pq) quantity_p2 <= quantity_p2 + 8'd1;
                        selected_quantity_led <= quantity_p2[3:0];
                    end
                    else begin
                        selected_product_led <= 2'b00;
                        selected_quantity_led <= 4'd0;
                    end
                    
                    // CRITICAL FIX: Do the math right as we transition out of PURCHASE
                    if (go) begin
                        if (sufficient_balance && sufficient_stock) begin
                            stock_p1 <= stock_p1 - quantity_p1;
                            stock_p2 <= stock_p2 - quantity_p2;
                            return_display <= balance_display - total_cost;
                            // Keep the remainder in the balance for the next purchase!
                            balance_display <= balance_display - total_cost; 
                        end else begin
                            return_display <= balance_display;
                        end
                    end
                end

                DONE: begin
                    done <= 1'b1;
                    
                    // When the user presses 'buy' to start using their remaining money...
                    if (buy) begin
                                   
                        quantity_p1 <= 8'd0;    // Reset quantities so they can start fresh!           
                        quantity_p2 <= 8'd0;
                        selected_quantity_led <= 4'd0;
                    end
                end

                ERROR: begin
                    error <= 1'b1;
                    
                    if (buy) begin
                        return_display <= 8'd0;            
                        quantity_p1 <= 8'd0;    // Reset quantities so they can start fresh!               
                        quantity_p2 <= 8'd0;
                        selected_quantity_led <= 4'd0;
                    end
                end
            endcase
        end
    end
endmodule