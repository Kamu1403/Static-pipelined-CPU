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
