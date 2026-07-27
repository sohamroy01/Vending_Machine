module slow_clk(
    input clk,
    input rst,
    output reg clk_out
);
    reg [25:0] count;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            clk_out <= 0;
        end else if (count == 500000) begin // Adjust this for desired speed
            count <= 0;
            clk_out <= ~clk_out;
        end else begin
            count <= count + 1;
        end
    end
endmodule