`timescale 1ns / 1ps

module seven_segment(
    input clk,             // 100 MHz board clock
    input rst,
    input [7:0] number,    // 8-bit binary number (can hold up to 255)
    output reg [6:0] seg,  // 7 segments (A-G)
    output reg [3:0] an    // 4 Anodes (digit selectors)
);

    reg [3:0] hundreds, tens, ones;
    reg [11:0] bcd;
    integer i;

    always @(*) begin
        bcd = 12'd0; // Initialize BCD to zero
        
        // Loop 8 times for an 8-bit number
        for (i = 7; i >= 0; i = i - 1) begin
            // If any BCD column is 5 or greater, add 3 to that column
            if (bcd[3:0] >= 5) 
                bcd[3:0] = bcd[3:0] + 3;
            if (bcd[7:4] >= 5) 
                bcd[7:4] = bcd[7:4] + 3;
            if (bcd[11:8] >= 5) 
                bcd[11:8] = bcd[11:8] + 3;
                
            // Shift left by 1, bringing in the next bit of the binary number
            bcd = {bcd[10:0], number[i]};
        end
        
        // Extract the individual digits for the display
        hundreds = bcd[11:8];
        tens     = bcd[7:4];
        ones     = bcd[3:0];
    end

    // 18 bits at 100MHz gives a refresh rate around ~381Hz (fast enough to avoid flicker)
    reg [17:0] refresh_counter;
    always @(posedge clk or posedge rst) begin
        if (rst) 
            refresh_counter <= 0;
        else 
            refresh_counter <= refresh_counter + 1;
    end

    // Use the top 2 bits of the counter to constantly cycle through the 3 digits
    wire [1:0] led_activation = refresh_counter[17:16];
    reg [3:0] current_digit;

  
    // Note: Assuming active-low anodes (0 = ON, 1 = OFF) which is standard
    always @(*) begin
        case(led_activation)
            2'b00: begin
                an = 4'b1110;          // Turn ON Digit 0 (Rightmost / Ones)
                current_digit = ones;
            end
            2'b01: begin
                an = 4'b1101;          // Turn ON Digit 1 (Middle / Tens)
                current_digit = tens;
            end
            2'b10: begin
                an = 4'b1011;          // Turn ON Digit 2 (Leftmost / Hundreds)
                current_digit = hundreds;
            end
            default: begin
                an = 4'b1111;          // All OFF for unused 4th state
                current_digit = 4'b0000;
            end
        endcase
    end

 
    // Note: Assuming active-low segments (0 = light ON)
    always @(*) begin
        case(current_digit)
            4'h0: seg = 7'b1000000; 
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100; 
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001; 
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010; 
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000; 
            4'h9: seg = 7'b0010000;
            default: seg = 7'b1111111; // Completely OFF if invalid
        endcase
    end

endmodule