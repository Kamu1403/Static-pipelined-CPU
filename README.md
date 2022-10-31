# Static-pipelined-CPU

## Introduction
  54-instruction static pipeline CPU for mips architecture.

## Our work
- Used Verilog HDL to implement RAM, ALU, multiplier, divider, and other modules
- Designed the control module connecting the CPU components and data streams to facilitate 
  the increase and decrease of instructions
- Tested the CPU on ModelSim, and then implemented the CPU on the Digilent Nexys4 FPGA board
- For more information, refer to [Project report](./resources/Report.pdf).

## Dependencies
- Vivado 2016.2
- Digilent Nexys 4 DDR FPGA board
- [Mars 4.5](http://www.cs.missouristate.edu/MARS/): Mips Assembly and Runtime Simulator

## Test program
We verify cpu correctness and efficiency on a benchmark program
1) Algorithm model
- Use the dichotomy method to find the location corresponding to the drop resistance value, 
  and stop when the range is narrowed down to two levels. At this time, select a higher 
  layer to test the egg and get the final result.
- drop_cnt is the number of broken eggs, drop_egg is the number of broken eggs, and a 
  drop_final value of 0 means that the last egg was broken.
2) Algorithm C language program
```
int main()
{
	int total_level = 987654321, break_level = 123456789;
	int drop_cnt = 0, drop_egg = 0, drop_final;
 
	int low = 0, high = total_level, center;
	while (1)
	{
		if (low +1 == high){
			if (high > break_level)
			{
				drop_final = 0;
				drop_egg++;
			}
			else
				drop_final = 1;
 
			drop_cnt++;
			break;
		}
		center = (low + high) / 2;
		if (center > break_level) {
			high = center;
			drop_egg++;
		}
		else
			low = center;
 
		drop_cnt++;
	}
	return 0;
}
```
3) Algorithm 54 instructions MIPS program
- The number of broken eggs, the number of broken eggs, and the result of the last drop 
  are stored in the $12, $13, and $14 registers.
```
.text
sll $0,$0,0
 
addiu $10,$0,987654321	#total_level
addiu $11,$0,123456789	#break_level
addiu $12,$0,0	#drop_cnt
addiu $13,$0,0	#drop_egg
#addiu $14,$0,0	#drop_final
 
addiu $2,$0,0	#low
addu $3,$0,$10	#high
#addu $4,$0,0	#center
loop:
addiu $1,$2,1
beq $1,$3,end_loop
 
#drop egg
addu $1,$2,$3
srl $4,$1,1		#center
sub $1,$11,$4
bgez $1,no_break
 
#break
addu $3,$0,$4
addiu $13,$13,1
j end_break
no_break:
addu $2,$0,$4
end_break:
addiu $12,$12,1
j loop
 
end_loop:
sub $1,$11,$3
bgez $1,final_no_break
 
#final_break
addiu $14,$0,0	#drop_final
addiu $13,$13,1
j final_end
final_no_break:
addiu $14,$0,1	#drop_final
final_end:
addiu $12,$12,1
exc:	#jump_out
j exc
```


## How to use
1) Include all the files in [code](./code) directory.
2) Use Vivado to synthesis, implementation, generate bitstream and program to board, 
   remember to load the [test program](./code/test_prog.coe) file.

<img src=".\resources\1.png" width="600"/>

3) Press button N17 to reset, and release to get the results of the program

<img src=".\resources\2.jpg" width="600"/>

The final result is 001f0004 (drop_cnt and drop_egg), and the V11 light in the lower left 
corner is off (egg_break=0). The result was correct.
4) We provide Mips cource code [here](./code/test_prog.asm), you can alter it and generate 
   binary file(COE) of your own program with [Mars 4.5](http://www.cs.missouristate.edu/MARS/).



