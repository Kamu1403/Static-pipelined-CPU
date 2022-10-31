`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/28 12:29:39
// Design Name: 
// Module Name: calculator
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
// posedge calculate
//////////////////////////////////////////////////////////////////////////////////

`include "define.vh"

module calculator(
    input clk,
    input [31:0] a, //multiplicand/dividend
    input [31:0] b, //multiplier/divisor
    input [1:0] calc,
    input reset,      //high-active,at the beginning of test
    input ena,  //high-active
    output reg [31:0] oLO,
    output reg [31:0] oHI,
    output sum_finish
    );

    reg start,busy,finish;
    wire busyDivu,busyDiv,busyMult,busyMultu;
    wire [63:0] oMult,oMultu,oDiv,oDivu;
    always @(*) begin
        case (calc)
            `CAL_MULTU: begin
                oLO<=oMultu[31:0];
                oHI<=oMultu[63:32];
                busy<=busyMultu;
            end
            `CAL_MULT: begin
                oLO<=oMult[31:0];
                oHI<=oMult[63:32];
                busy<=busyMult;
            end
            `CAL_DIVU: begin
                oLO<=oDivu[31:0];
                oHI<=oDivu[63:32];
                busy<=busyDivu;
            end
            `CAL_DIV: begin
                oLO<=oDiv[31:0];
                oHI<=oDiv[63:32];
                busy<=busyDiv;
            end
            default: begin end
        endcase
    end

    assign sum_finish=finish;
    always @(negedge ena or negedge busy) begin
        if(ena&!busy)
            finish<=1;
        else if (!ena) 
            finish<=0;
    end
    always @(posedge ena or posedge busy) begin
        if(ena&!busy)
            start<=1;
        else if (busy) 
            start<=0;
    end



    MULT MULT_inst(
        .clk(clk),
        .reset(reset),    //active high
        .start(start&(calc==`CAL_MULT)),
        .a(a), //multiplicand
        .b(b), //multiplier
        .z(oMult),
        .busy(busyMult)
    );
    MULTU MULTU_inst(
        .clk(clk),
        .reset(reset),    //active high
        .start(start&(calc==`CAL_MULTU)),
        .a(a), //multiplicand
        .b(b), //multiplier
        .z(oMultu),
        .busy(busyMultu)
    );
    DIV DIV_inst(
        .dividend(a),
        .divisor(b),
        .start(start&(calc==`CAL_DIV)),
        .clock(clk),
        .reset(reset),    //active-high
        .q(oDiv[31:0]),
        .r(oDiv[63:32]),
        .busy(busyDiv)
    );
    DIVU DIVU_inst(
        .dividend(a),
        .divisor(b),
        .start(start&(calc==`CAL_DIVU)),
        .clock(clk),
        .reset(reset),    //active-high
        .q(oDivu[31:0]),
        .r(oDivu[63:32]),
        .busy(busyDivu)
    );
endmodule
