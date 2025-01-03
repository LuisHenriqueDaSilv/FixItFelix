.data 
	.include "assets/spotsAddress.data"
	
.text
la t1, spotsAddress
lw t2, 0(t1)
lw t3, 4(t1)
addi t1, t1, 8 # Pula as duas primeiras words
LOOP:
	lbu t4, 0(t1)
	addi t1, t1, 1	
	#call LOOP
	call LOOP