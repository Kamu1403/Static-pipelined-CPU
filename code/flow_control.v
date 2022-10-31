`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/19 11:05:11
// Design Name: 
// Module Name: flow_control
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

`include "define.vh"

module flow_control(
    input clk,input reset,
    input [6:0] raddr1,input [6:0] raddr2,input [6:0] waddr1,input [6:0] waddr2,input [6:0] waddr3,
    input mult_div_stall,input mult_div_over,input overflow_stall,

    /*-----------flow_control-----------*/
    output [1:0] cond0,output [1:0] cond1,output [1:0] cond2,output [1:0] cond3,output [1:0] cond4
    );

    reg [1:0] cond[0:4];
    assign cond0=cond[0];
    assign cond1=cond[1];
    assign cond2=cond[2];
    assign cond3=cond[3];
    assign cond4=cond[4];

    reg [1:0] state,nextstate;reg [4:0] cnt;
    wire violation1=(waddr1!=`VIOLATION_NON)&&(raddr1==waddr1||raddr2==waddr1||(waddr1==`VIOLATION_HILO&&(raddr1==`VIOLATION_HI||raddr1==`VIOLATION_LO||raddr2==`VIOLATION_HI||raddr2==`VIOLATION_LO)));
    wire violation2=(waddr2!=`VIOLATION_NON)&&(raddr1==waddr2||raddr2==waddr2||(waddr2==`VIOLATION_HILO&&(raddr1==`VIOLATION_HI||raddr1==`VIOLATION_LO||raddr2==`VIOLATION_HI||raddr2==`VIOLATION_LO)));
    wire violation3=(waddr3!=`VIOLATION_NON)&&(raddr1==waddr3||raddr2==waddr3||(waddr3==`VIOLATION_HILO&&(raddr1==`VIOLATION_HI||raddr1==`VIOLATION_LO||raddr2==`VIOLATION_HI||raddr2==`VIOLATION_LO)));
    wire violation=violation1|violation2|violation3;
    
    always @(posedge clk or posedge reset) begin
        if(reset)
            state<=`FLOW_NORMAL;
        else
            state<=nextstate;
    end

    always @(*) begin
        case (state)
            `FLOW_NORMAL: begin
                if (overflow_stall) begin
                    if (violation) begin
                        cond[0]<=`PARTS_COND_FLOW;  //IF
                        cond[1]<=`PARTS_COND_ZERO;  //ID
                        cond[2]<=`PARTS_COND_ZERO;  //EX
                        cond[3]<=`PARTS_COND_FLOW;  //ME
                        cond[4]<=`PARTS_COND_FLOW;  //WB
                        nextstate<=`FLOW_NORMAL;
                    end else begin
                        cond[0]<=`PARTS_COND_FLOW;  //IF
                        cond[1]<=`PARTS_COND_FLOW;  //ID
                        cond[2]<=`PARTS_COND_ZERO;  //EX
                        cond[3]<=`PARTS_COND_FLOW;  //ME
                        cond[4]<=`PARTS_COND_FLOW;  //WB
                        nextstate<=`FLOW_NORMAL;
                    end
                end
                else if (!mult_div_over&mult_div_stall) begin
                    cond[0]<=`PARTS_COND_STALL;  //IF
                    cond[1]<=`PARTS_COND_STALL;  //ID
                    cond[2]<=`PARTS_COND_STALL;  //EX
                    cond[3]<=`PARTS_COND_STALL;  //ME
                    cond[4]<=`PARTS_COND_STALL;  //WB
                    nextstate<=`FLOW_MULDIV;
                end
                else if (violation) begin
                    cond[0]<=`PARTS_COND_STALL;  //IF
                    cond[1]<=`PARTS_COND_ZERO;  //ID
                    cond[2]<=`PARTS_COND_FLOW;  //EX
                    cond[3]<=`PARTS_COND_FLOW;  //ME
                    cond[4]<=`PARTS_COND_FLOW;  //WB
                    nextstate<=`FLOW_NORMAL;
                end else begin
                    cond[0]<=`PARTS_COND_FLOW;  //IF
                    cond[1]<=`PARTS_COND_FLOW;  //ID
                    cond[2]<=`PARTS_COND_FLOW;  //EX
                    cond[3]<=`PARTS_COND_FLOW;  //ME
                    cond[4]<=`PARTS_COND_FLOW;  //WB
                    nextstate<=`FLOW_NORMAL;
                end
            end
            `FLOW_MULDIV: begin
                if (mult_div_over) begin
                    if (violation) begin
                        cond[0]<=`PARTS_COND_STALL;  //IF
                        cond[1]<=`PARTS_COND_ZERO;  //ID
                        cond[2]<=`PARTS_COND_FLOW;  //EX
                        cond[3]<=`PARTS_COND_FLOW;  //ME
                        cond[4]<=`PARTS_COND_FLOW;  //WB
                        nextstate<=`FLOW_NORMAL;
                    end else begin
                        cond[0]<=`PARTS_COND_FLOW;  //IF
                        cond[1]<=`PARTS_COND_FLOW;  //ID
                        cond[2]<=`PARTS_COND_FLOW;  //EX
                        cond[3]<=`PARTS_COND_FLOW;  //ME
                        cond[4]<=`PARTS_COND_FLOW;  //WB
                        nextstate<=`FLOW_NORMAL;
                    end
                end else begin
                    cond[0]<=`PARTS_COND_STALL;  //IF
                    cond[1]<=`PARTS_COND_STALL;  //ID
                    cond[2]<=`PARTS_COND_STALL;  //EX
                    cond[3]<=`PARTS_COND_STALL;  //ME
                    cond[4]<=`PARTS_COND_STALL;  //WB
                    nextstate<=`FLOW_MULDIV;
                end
            end
            default: begin
                cond[0]<=`PARTS_COND_FLOW;  //IF
                cond[1]<=`PARTS_COND_FLOW;  //ID
                cond[2]<=`PARTS_COND_FLOW;  //EX
                cond[3]<=`PARTS_COND_FLOW;  //ME
                cond[4]<=`PARTS_COND_FLOW;  //WB
                nextstate<=`FLOW_NORMAL;
            end
        endcase
    end
endmodule
