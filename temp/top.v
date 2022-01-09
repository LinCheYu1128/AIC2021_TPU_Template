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
reg [`DATA_SIZE-1:0] a11,a12,a13,a14,temp;

reg [`WORD_SIZE-9:0] temp1,temp2,temp3,temp4;
wire [`DATA_SIZE-1:0] a21,a22,a23,a24, 
                      a31,a32,a33,a34, 
                      a41,a42,a43,a44,
                      w11,w12,w13,w14,
                      w21,w22,w23,w24,
                      w31,w32,w33,w34,
                      w41,w42,w43,w44;
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
    l <= (m<=4 && n<=4)?k:((m<=8 && n<=8)?2*k:3*k);
    // $display("%d",l);
    if(index_a == l) begin
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
        a15 <= matrix_a[4][31:24];
      end
      5:begin
        a13 <= matrix_a[2][ 7: 0];
        a14 <= matrix_a[3][15: 8];
        a15 <= matrix_a[4][23:16];
        a16 <= matrix_a[5][31:24];
      end
      6:begin
        a14 <= matrix_a[3][ 7: 0];
        a15 <= matrix_a[4][15: 8];
        a16 <= matrix_a[5][23:16];
        a17 <= matrix_a[6][31:24];
      end
      7:begin
        a15 <= matrix_a[4][ 7: 0];
        a16 <= matrix_a[5][15: 8];
        a17 <= matrix_a[6][23:16];
        a18 <= matrix_a[7][31:24];
      end
      8:begin
        a16 <= matrix_a[5][ 7: 0];
        a17 <= matrix_a[6][15: 8];
        a18 <= matrix_a[7][23:16];
        a19 <= matrix_a[8][31:24];
      end
      9:begin
        a17 <= matrix_a[6][ 7: 0];
        a18 <= matrix_a[7][15: 8];
        a19 <= matrix_a[8][23:16];
      end
      10:begin
        a18 <= matrix_a[7][ 7: 0];
        a19 <= matrix_a[8][15: 8];
      end
      11:begin
        a19 <= matrix_a[8][ 7: 0];
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

always @(posedge clk) begin
  if(cur_state == WORK)begin
    if(counter >= k + 1)begin //counter 3 //counter 5 6 7 8 9 10  //counter 10 - 20 
      if(k==2) temp <= w12;
      else if(k==4)begin
        case (counter)
          5:begin
            temp1[7:0] <= w14;
          end 
          6:begin
            temp1[15:8] <= w24;
            temp2[ 7:0] <= w14;
          end
          7:begin
            temp1[23:16] <= w34;
            temp2[15: 8] <= w24;
            temp3[ 7: 0] <= w14;
          end
          default:begin
            temp1 <= {w34,temp2[15:0]};
            temp2[15:0] <= {w24,temp3[7:0]};
            temp3[ 7:0] <= w14;
          end
        endcase
      end
      else if(k==9)begin
        case (counter)
          10:begin
            temp1[7:0] <= w19;
          end
          11:begin
            temp1[15:8] <= w29;
            temp2[ 7:0] <= w19;
          end
          12:begin
            temp1[23:16] <= w39;
            temp2[15: 8] <= w29;
            temp3[ 7: 0] <= w19;
          end 
          default:begin
            temp1 <= {w39,temp2[15:0]};
            temp2[15:0] <= {w29,temp3[7:0]};
            temp3[ 7:0] <= w19;
          end 
        endcase
      end
    end
  end
end
always @(posedge clk) begin
  if(cur_state == WORK)begin
    if(counter >= (k+n) && counter < (2*k+n))begin //counter 4 5 //counter 8 9 10 11
      wr_en_out <= 1;
      index_out <= counter - k - n;
      case (k)
        2:data_in_o <= {`DATA_SIZE'b0,`DATA_SIZE'b0,w22,temp};
        4:data_in_o <= {w44,temp1};
        9:data_in_o <= {w49,temp1};
        default: data_in_o <= `WORD_SIZE'b0;  
      endcase
    end
    else if(counter == 2*k + n)begin  //counter 6 //counter 10
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
pe pe_w11(.clk(clk),.rst(rst),.a(a11),.b(b11),.a_out(a21),.psum( 0 ),.out(w11));
pe pe_w12(.clk(clk),.rst(rst),.a(a12),.b(b12),.a_out(a22),.psum(w11),.out(w12));
pe pe_w13(.clk(clk),.rst(rst),.a(a13),.b(b13),.a_out(a23),.psum(w12),.out(w13));
pe pe_w14(.clk(clk),.rst(rst),.a(a14),.b(b14),.a_out(a24),.psum(w13),.out(w14));

pe pe_w21(.clk(clk),.rst(rst),.a(a21),.b(b21),.a_out(a31),.psum( 0 ),.out(w21));
pe pe_w22(.clk(clk),.rst(rst),.a(a22),.b(b22),.a_out(a32),.psum(w21),.out(w22));
pe pe_w23(.clk(clk),.rst(rst),.a(a23),.b(b23),.a_out(a33),.psum(w22),.out(w23));
pe pe_w24(.clk(clk),.rst(rst),.a(a24),.b(b24),.a_out(a34),.psum(w23),.out(w24));

pe pe_w31(.clk(clk),.rst(rst),.a(a31),.b(b31),.a_out(a41),.psum( 0 ),.out(w31));
pe pe_w32(.clk(clk),.rst(rst),.a(a32),.b(b32),.a_out(a42),.psum(w31),.out(w32));
pe pe_w33(.clk(clk),.rst(rst),.a(a33),.b(b33),.a_out(a43),.psum(w32),.out(w33));
pe pe_w34(.clk(clk),.rst(rst),.a(a34),.b(b34),.a_out(a44),.psum(w33),.out(w34));

pe pe_w41(.clk(clk),.rst(rst),.a(a41),.b(b41),.a_out(   ),.psum( 0 ),.out(w41));
pe pe_w42(.clk(clk),.rst(rst),.a(a42),.b(b42),.a_out(   ),.psum(w41),.out(w42));
pe pe_w43(.clk(clk),.rst(rst),.a(a43),.b(b43),.a_out(   ),.psum(w42),.out(w43));
pe pe_w44(.clk(clk),.rst(rst),.a(a44),.b(b44),.a_out(   ),.psum(w43),.out(w44));


endmodule

///////////////////////////////////////////////////////////////////////////////////////
matrix_b[0][31:24]
matrix_b[1][31:24]
matrix_b[2][31:24]
matrix_b[3][31:24]
matrix_b[4][31:24]
matrix_b[5][31:24]
matrix_b[6][31:24]
matrix_b[7][31:24]
matrix_b[8][31:24]
matrix_b[0][23:16]
matrix_b[1][23:16]
matrix_b[2][23:16]
matrix_b[3][23:16]
matrix_b[4][23:16]
matrix_b[5][23:16]
matrix_b[6][23:16]
matrix_b[7][23:16]
matrix_b[8][23:16]
matrix_b[0][15: 8]
matrix_b[1][15: 8]
matrix_b[2][15: 8]
matrix_b[3][15: 8]
matrix_b[4][15: 8]
matrix_b[5][15: 8]
matrix_b[6][15: 8]
matrix_b[7][15: 8]
matrix_b[8][15: 8]
matrix_b[0][ 7: 0]
matrix_b[1][ 7: 0]
matrix_b[2][ 7: 0]
matrix_b[3][ 7: 0]
matrix_b[4][ 7: 0]
matrix_b[5][ 7: 0]
matrix_b[6][ 7: 0]
matrix_b[7][ 7: 0]
matrix_b[8][ 7: 0]