.text 0x00004180
lw $t4,0x10($gp) #Load Input Device
beq $t0,$t4,EQUAL
addu $t0,$t4,$0 #Update origin input device register
addu $s0,$t4,$0
sw $t0,0x20($gp) #Send Output Device new number
j CONTINUE
EQUAL:
addiu $s0,$s0,1
sw $s0,0x20($gp) #Send Output Device new number
CONTINUE:
sw $t0,0($gp) #Send CTRL register value, disable interrupt & timer
sw $t1,0x4($gp) #Send Interval
sw $t2,0($gp) #Send CTRL register value, enable interrupt & timer again
eret
