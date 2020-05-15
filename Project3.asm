mfc0 $at,$15  #PrID Store at $at
addu $gp,$0,$0
ori $gp,0x7f00  #External Device Base Address
lw $t0,0x10($gp) # Read Input Device
addu $s0,$t0,$0 # Move $s0 to $s0 to operate plus
sw $t0,0x20($gp) # Write Output Device
lui $t1,0xF
ori $t1,0x4240 #Time Interval ; When upload to FPGA, change this
sw $t1,0x4($gp) #Send Interval
addu $t2,$0,$0
ori $t2,0x9 #TimeCounter CTRL register Value
sw $t2,0($gp) #Send CTRL register value
addu $t3,$0,$0
ori $t3,0x401 #SR Register Value
mtc0 $t3,$12 #move SR Register Value to SR
self:
j self
