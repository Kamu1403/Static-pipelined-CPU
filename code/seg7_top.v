`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/07 21:37:51
// Design Name: 
// Module Name: seg7_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define CLK_PERIOD 3

module seg7_top(
    input clk_in,
	input reset,
	output [7:0] o_seg,
	output [7:0] o_sel,
    output egg_break

    // output [31:0] test_pc,
    // output [31:0] test_ir
    );

    wire [31:0] test_pc,test_ir;

    wire clk_cpu, clk_seg7,clk_100mhz;
    assign clk_100mhz=clk_in;

    reg [`CLK_PERIOD-1:0] counter;
    wire [31:0] seg7_idata;
    assign clk_cpu=counter[`CLK_PERIOD-3];
    assign clk_seg7=counter[`CLK_PERIOD-1];

    always @(posedge clk_100mhz or posedge reset) begin
        if(reset) begin
            counter<=0;
        end
        else begin
            counter<=counter+1'b1;
        end
    end

    wire [31:0] reg_12,reg_13,reg_14;
    assign seg7_idata={reg_12[15:0],reg_13[15:0]};
    assign egg_break=reg_14[0];

    seg7x16 seg7x16_inst(
        .clk(clk_cpu),
	    .reset(reset),
	    .cs(1'b1),
	    .i_data(seg7_idata),
	    .o_seg(o_seg),
	    .o_sel(o_sel)
    );

    top_parts cpu_inst(
        .clk(clk_cpu),  //posedge write-active
        .reset(reset),    //active-high asynchronous
        .top_pc(test_pc),
        .top_ir(test_ir),

        //for test_egg program out
        .reg_12(reg_12),
        .reg_13(reg_13),
        .reg_14(reg_14)
    );
endmodule
