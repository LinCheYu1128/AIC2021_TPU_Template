`include "src/define.v"

module pe (
    input clk,
    input rst,
    input  [`DATA_SIZE-1:0] a,
    input  [`DATA_SIZE-1:0] b,
    input  [`DATA_SIZE-1:0] psum,
    output reg[`DATA_SIZE-1:0] a_out,
    output reg[`DATA_SIZE-1:0] out
);

always @(posedge clk or posedge rst) begin
    if(rst)begin
        out <= `DATA_SIZE'b0;
        a_out <= `DATA_SIZE'b0;
    end 
    else begin 
        out <= a * b + psum;
        a_out <= a;
    end
end

endmodule