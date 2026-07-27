`timescale 1ns / 1ps

module debouncer #(
    parameter TIMER_MAX = 99_999_999; // 1 second at 100MHz
)(
    input  wire clk,
    input  wire rst,          // Active-high reset
    input  wire button_in,
    output reg  button_out    // 1-clock-cycle pulse on press
);

    // ==========================================
    // STAGE 1: SYNCHRONIZER (Anti-Metastability)
    // ==========================================
    reg sync_ff1, sync_ff2;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff1 <= button_in;
            sync_ff2 <= sync_ff1;
        end
    end

    // ==========================================
    // STAGE 2: 20ms TIMER
    // ==========================================
    wire timer_reset;
    wire timer_done;
   reg [26:0] timer_count; // Increased to 27 bits to hold 99,999,999
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer_count <= 0;
        end else if (timer_reset) begin
            timer_count <= 0;
        end else if (~timer_done) begin
            timer_count <= timer_count + 1;
        end
    end

    assign timer_done = (timer_count >= TIMER_MAX);

    // ==========================================
    // STAGE 3: FSM DEBOUNCER
    // ==========================================
    reg [1:0] state_reg, state_next;
    parameter s0 = 0, s1 = 1, s2 = 2, s3 = 3;
    
    wire noisy = sync_ff2;
    wire debounced_level; // The continuous stable level

    // Sequential state register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state_reg <= s0;
        else
            state_reg <= state_next;
    end

    // Next state logic
    always @(*) begin
        state_next = state_reg; // Default state
        case(state_reg)
            s0: if (~noisy)
                    state_next = s0;
                else if (noisy)
                    state_next = s1;
            s1: if (~noisy)
                    state_next = s0;
                else if (noisy & ~timer_done)
                    state_next = s1;
                else if (noisy & timer_done)
                    state_next = s2;
            s2: if (~noisy)
                    state_next = s3;
                else if (noisy)
                    state_next = s2;
            s3: if (noisy)
                    state_next = s2;
                else if (~noisy & ~timer_done)
                    state_next = s3;
                else if (~noisy & timer_done)
                    state_next = s0;
            default: state_next = s0;
        endcase
    end

    // FSM Output Logic
    // Reset timer when in stable states (s0, s2). Let it run in transition states (s1, s3).
    assign timer_reset = (state_reg == s0) | (state_reg == s2);
    // Button is considered "pressed" only in states s2 and s3
    assign debounced_level = (state_reg == s2) | (state_reg == s3);

    // ==========================================
    // STAGE 4: EDGE DETECTOR (1-cycle pulse)
    // ==========================================
    reg prev_debounced_level;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_debounced_level <= 1'b0;
            button_out <= 1'b0;
        end else begin
            prev_debounced_level <= debounced_level;
            
            // Output is HIGH only on the rising edge of the debounced signal
            button_out <= debounced_level & ~prev_debounced_level;
        end
    end

endmodule