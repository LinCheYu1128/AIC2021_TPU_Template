//============================================================================//
// AIC2021 Project1 - TPU Design                                              //
// file: top.v                                                                //
// description: Top module complete your TPU design here                      //
// authors: kaikai (deekai9139@gmail.com)                                     //
//          suhan  (jjs93126@gmail.com)                                       //
//============================================================================//

`include "src/define.v"
`include "src/global_buffer.v"
`include "src/pe.v"

module top(clk, rst, start, m, n,  k, done);

  input clk;
  input rst;
  input start;
  input [3:0] m, k, n;
  output reg done;

  reg                   wr_en_a,
                        wr_en_b,
                        wr_en_out;
  reg  [`DATA_SIZE-1:0] index_a,
                        index_b,
                        index_out;
  reg  [`WORD_SIZE-1:0] data_in_a,
                        data_in_b,
                        data_in_o;
  wire [`WORD_SIZE-1:0] data_out_a,
                        data_out_b,
                        data_out_o;
//----------------------------------------------------------------------------//
// Global buffers declaration                                                 //
//----------------------------------------------------------------------------//
  global_buffer GBUFF_A(.clk     (clk       ),
                        .rst     (rst       ),
                        .wr_en   (wr_en_a   ),
                        .index   (index_a   ),
                        .data_in (data_in_a ),
                        .data_out(data_out_a));

  global_buffer GBUFF_B(.clk     (clk       ),
                        .rst     (rst       ),
                        .wr_en   (wr_en_b   ),
                        .index   (index_b   ),
                        .data_in (data_in_b ),
                        .data_out(data_out_b));

  global_buffer GBUFF_OUT(.clk     (clk      ),
                          .rst     (rst      ),
                          .wr_en   (wr_en_out),
                          .index   (index_out),
                          .data_in (data_in_o),
                          .data_out(data_out_o));
//----------------------------------------------------------------------------//
// TPU module declaration                                                     //
//----------------------------------------------------------------------------//
//****TPU tpu1(); add your design here*****//
reg [1:0]cur_state,next_state;
localparam IDLE   = 2'b00;
localparam LOAD   = 2'b01;
localparam WORK   = 2'b10;
localparam FINISH = 2'b11;
/////////////////////////////////////////////
reg [`WORD_SIZE-1:0] matrix_a[0:8];
reg [`WORD_SIZE-1:0] matrix_b[0:8];
reg [`WORD_SIZE-9:0] temp1;
reg [`WORD_SIZE-17:0] temp2;
reg [`WORD_SIZE-25:0] temp3;
reg [`DATA_SIZE-1:0] a11,a12,a13,a14,
                     ans1,ans2,ans3,ans4,
                     b11,b12,b13,b14,
                     b21,b22,b23,b24,
                     b31,b32,b33,b34,
                     b41,b42,b43,b44;
wire [`DATA_SIZE-1:0] a21,a22,a23,a24, 
                      a31,a32,a33,a34, 
                      a41,a42,a43,a44,
                      w11,w12,w13,w14,
                      w21,w22,w23,w24,
                      w31,w32,w33,w34,
                      w41,w42,w43,w44,
                      psum1,psum2,psum3,psum4;
reg load_en,work_fin,wr_fin;
integer counter;
always @(posedge clk or posedge rst) begin
	if(rst) cur_state <= IDLE;
	else cur_state <= next_state;
end
always @(*) begin
  case (cur_state)
    IDLE   : next_state = (start)? LOAD:IDLE;
    LOAD   : next_state = (load_en)? WORK:LOAD;
    WORK   : next_state = (work_fin)? FINISH:WORK;
    FINISH : next_state = FINISH; 
    default: next_state = IDLE;
  endcase
end
always @(posedge clk) begin
  if(cur_state == LOAD)begin
    case (index_a)
      1:matrix_a[0] <= data_out_a;
      2:matrix_a[1] <= data_out_a;
      3:matrix_a[2] <= data_out_a;
      4:matrix_a[3] <= data_out_a;
      5:matrix_a[4] <= data_out_a;
      6:matrix_a[5] <= data_out_a;
      7:matrix_a[6] <= data_out_a;
      8:matrix_a[7] <= data_out_a;
      9:matrix_a[8] <= data_out_a;
    endcase
  end
end
always @(posedge clk) begin
  if(cur_state == LOAD)begin
    case (index_b)
      1:matrix_b[0] <= data_out_b;
      2:matrix_b[1] <= data_out_b;
      3:matrix_b[2] <= data_out_b;
      4:matrix_b[3] <= data_out_b;
      5:matrix_b[4] <= data_out_b;
      6:matrix_b[5] <= data_out_b;
      7:matrix_b[6] <= data_out_b;
      8:matrix_b[7] <= data_out_b;
      9:matrix_b[8] <= data_out_b;
    endcase
  end
end
integer l;
always @(posedge clk) begin
  if(cur_state == IDLE)begin
    load_en <= 0;
    index_a <= 0;
    index_b <= 0;
    wr_en_a <= 0;
    wr_en_b <= 0;
  end 
  else if(cur_state == LOAD) begin
    // l <= (m<=4 && n<=4)?k:((m<=8 && n<=8)?2*k:3*k);
    // $display("%d",l);
    l <= (k<=4)?k:((k<=8)?k-4:k-8);
    if(index_a == k) begin
      load_en <= 1;
      index_a <= 0;
      index_b <= 0;
    end
    else begin
      load_en <= 0;
      index_a <= index_a + 1;
      index_b <= index_b + 1;
    end
  end
end
always @(posedge clk) begin
  if(cur_state == WORK)begin
      case (counter)
      0:begin
        a11 <= matrix_a[0][31:24];  
      end
      1:begin
        a11 <= matrix_a[0][23:16];
        a12 <= matrix_a[1][31:24];  
      end 
      2:begin
        a11 <= matrix_a[0][15: 8];
        a12 <= matrix_a[1][23:16];
        a13 <= matrix_a[2][31:24];
      end
      3:begin
        a11 <= matrix_a[0][ 7: 0];
        a12 <= matrix_a[1][15: 8];
        a13 <= matrix_a[2][23:16];
        a14 <= matrix_a[3][31:24];
      end
      4:begin
        a12 <= matrix_a[1][ 7: 0];
        a13 <= matrix_a[2][15: 8];
        a14 <= matrix_a[3][23:16];
        a11 <= matrix_a[4][31:24];
      end
      5:begin
        a13 <= matrix_a[2][ 7: 0];
        a14 <= matrix_a[3][15: 8];
        a11 <= matrix_a[4][23:16];
        a12 <= matrix_a[5][31:24];
      end
      6:begin
        a14 <= matrix_a[3][ 7: 0];
        a11 <= matrix_a[4][15: 8];
        a12 <= matrix_a[5][23:16];
        a13 <= matrix_a[6][31:24];
      end
      7:begin
        a11 <= matrix_a[4][ 7: 0];
        a12 <= matrix_a[5][15: 8];
        a13 <= matrix_a[6][23:16];
        a14 <= matrix_a[7][31:24];
      end
      8:begin
        a12 <= matrix_a[5][ 7: 0];
        a13 <= matrix_a[6][15: 8];
        a14 <= matrix_a[7][23:16];
        a11 <= matrix_a[8][31:24];
      end
      9:begin
        a13 <= matrix_a[6][ 7: 0];
        a14 <= matrix_a[7][15: 8];
        a11 <= matrix_a[8][23:16];
      end
      10:begin
        a14 <= matrix_a[7][ 7: 0];
        a11 <= matrix_a[8][15: 8];
      end
      11:begin
        a11 <= matrix_a[8][ 7: 0];
      end
      endcase
  end
end
always @(posedge clk) begin
  if(cur_state == WORK)begin
      case (counter)
      0:begin
          b11 <= matrix_b[0][31:24];
      end
      1:begin
          b12 <= matrix_b[1][31:24];
          b21 <= matrix_b[0][23:16];
      end
      2:begin
          b13 <= matrix_b[2][31:24];
          b22 <= matrix_b[1][23:16];
          b31 <= matrix_b[0][15: 8];
      end   
      3:begin
          b14 <= matrix_b[3][31:24];
          b23 <= matrix_b[2][23:16];
          b32 <= matrix_b[1][15: 8];
          b41 <= matrix_b[0][ 7: 0];
      end       
      4:begin
          b11 <= matrix_b[4][31:24];
          b24 <= matrix_b[3][23:16];
          b33 <= matrix_b[2][15: 8];
          b42 <= matrix_b[1][ 7: 0];
      end
      5:begin
          b12 <= matrix_b[4][23:16];
          b21 <= matrix_b[5][31:24];
          b34 <= matrix_b[3][15: 8];
          b43 <= matrix_b[2][ 7: 0];
      end
      6:begin
          b13 <= matrix_b[4][15: 8];
          b22 <= matrix_b[5][23:16];
          b31 <= matrix_b[6][31:24];
          b44 <= matrix_b[3][ 7: 0];
      end
      7:begin
          b14 <= matrix_b[4][ 7: 0];
          b23 <= matrix_b[5][15: 8];
          b32 <= matrix_b[6][23:16];
          b41 <= matrix_b[7][31:24];
      end
      8:begin
          b24 <= matrix_b[5][ 7: 0];
          b33 <= matrix_b[6][15: 8];
          b42 <= matrix_b[7][23:16];
          b11 <= matrix_b[8][31:24];
      end
      9:begin
          b34 <= matrix_b[6][ 7: 0];
          b43 <= matrix_b[7][15: 8];
          b21 <= matrix_b[8][23:16];
      end
      10:begin
          b44 <= matrix_b[7][ 7: 0];
          b31 <= matrix_b[8][15: 8];
      end
      11:begin
          b41 <= matrix_b[8][ 7: 0];
      end
      endcase
  end
end
always @(posedge clk) begin
  if(cur_state == WORK)begin
    counter <= counter + 1;
  end
  else counter <= 0;
end

always @(*) begin
  case (l)
    1:begin
      ans1 = w11;
      ans2 = w21;
      ans3 = w31;
      ans4 = w41;
    end
    2:begin
      ans1 = w12;
      ans2 = w22;
      ans3 = w32;
      ans4 = w42;
    end
    3:begin
      ans1 = w13;
      ans2 = w23;
      ans3 = w33;
      ans4 = w43;
    end
    4:begin
      ans1 = w14;
      ans2 = w24;
      ans3 = w34;
      ans4 = w44;
    end 
    default:begin
      ans1 = 0;
      ans2 = 0;
      ans3 = 0;
      ans4 = 0;
    end 
  endcase
end

always @(posedge clk) begin
  if(cur_state == WORK)begin //counter 3 //counter 5 6 7 8 9 10  //counter 10 - 20 
    if(counter >= k+1)begin
      case (counter)
      k+1:begin
        temp1[7:0] <= ans1;
      end 
      k+2:begin
        temp1[15:8] <= ans2;
        temp2[ 7:0] <= ans1;
      end
      k+3:begin
        temp1[23:16] <= ans3;
        temp2[15: 8] <= ans2;
        temp3[ 7: 0] <= ans1;
      end
      default:begin
        temp1 <= {ans3,temp2[15:0]};
        temp2[15:0] <= {ans2,temp3[7:0]};
        temp3[ 7:0] <= ans1;
      end
      endcase
    end
  end
end
always @(posedge clk) begin
  if(cur_state == WORK)begin
    if(counter >= (k+n) && counter < (k+2*n))begin //counter 4 5 //counter 8 9 10 11 //counter 13 14 15 16
      wr_en_out <= 1;
      index_out <= counter - k - n;
      case (k)
        1:data_in_o <= {`DATA_SIZE'b0,`DATA_SIZE'b0,`DATA_SIZE'b0,ans1};
        2:data_in_o <= {`DATA_SIZE'b0,`DATA_SIZE'b0,ans2,temp1[7:0]};
        3:data_in_o <= {`DATA_SIZE'b0,ans3,temp1[15:0]};
        default: data_in_o <= {ans4,temp1};  
      endcase
    end
    else if(counter == k + 2*n)begin  //counter 6 //counter 10
      wr_en_out <= 0;
      work_fin <= 1;
    end
  end
  else work_fin <= 0; 
end


always @(posedge clk) begin
  if(cur_state==FINISH) done <= 1;
end

//-----------------------------------------------------------------------//
// process element                                                       //
//-----------------------------------------------------------------------//
assign psum1 = (counter <= 4)? 0 : w14;
assign psum2 = (counter <= 5)? 0 : w24;
assign psum3 = (counter <= 6)? 0 : w34;
assign psum4 = (counter <= 7)? 0 : w44;

pe pe_w11(.clk(clk),.rst(rst),.a(a11),.b(b11),.a_out(a21),.psum(psum1),.out(w11));
pe pe_w12(.clk(clk),.rst(rst),.a(a12),.b(b12),.a_out(a22),.psum(w11),.out(w12));
pe pe_w13(.clk(clk),.rst(rst),.a(a13),.b(b13),.a_out(a23),.psum(w12),.out(w13));
pe pe_w14(.clk(clk),.rst(rst),.a(a14),.b(b14),.a_out(a24),.psum(w13),.out(w14));

pe pe_w21(.clk(clk),.rst(rst),.a(a21),.b(b21),.a_out(a31),.psum(psum2),.out(w21));
pe pe_w22(.clk(clk),.rst(rst),.a(a22),.b(b22),.a_out(a32),.psum(w21),.out(w22));
pe pe_w23(.clk(clk),.rst(rst),.a(a23),.b(b23),.a_out(a33),.psum(w22),.out(w23));
pe pe_w24(.clk(clk),.rst(rst),.a(a24),.b(b24),.a_out(a34),.psum(w23),.out(w24));

pe pe_w31(.clk(clk),.rst(rst),.a(a31),.b(b31),.a_out(a41),.psum(psum3),.out(w31));
pe pe_w32(.clk(clk),.rst(rst),.a(a32),.b(b32),.a_out(a42),.psum(w31),.out(w32));
pe pe_w33(.clk(clk),.rst(rst),.a(a33),.b(b33),.a_out(a43),.psum(w32),.out(w33));
pe pe_w34(.clk(clk),.rst(rst),.a(a34),.b(b34),.a_out(a44),.psum(w33),.out(w34));

pe pe_w41(.clk(clk),.rst(rst),.a(a41),.b(b41),.a_out(   ),.psum(psum4),.out(w41));
pe pe_w42(.clk(clk),.rst(rst),.a(a42),.b(b42),.a_out(   ),.psum(w41),.out(w42));
pe pe_w43(.clk(clk),.rst(rst),.a(a43),.b(b43),.a_out(   ),.psum(w42),.out(w43));
pe pe_w44(.clk(clk),.rst(rst),.a(a44),.b(b44),.a_out(   ),.psum(w43),.out(w44));

endmodule

///////////////////////////////////////////////////////////////////////////////////////
