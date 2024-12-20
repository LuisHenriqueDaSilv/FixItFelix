.data
	char_pos: .half 0, 0
	old_char_pos: .half, 0,0
	.include "assets/felix/idle/felixidle.s"
	.include "assets/felix/felixTile.s"

.text 
SETUP:
	li a1, 0
	li a2, 0
	li a3, 0

# a0, endereco da imagem
# a1 = x
# a2 = y
# a3 = frame

# t0 endereco do bitmap
# t1 endereco da imagem
# t2 contador de linha
# t3 contador de coluna
# t4 largura
# t5 altura

GAME_LOOP:
	call KEY2
	xori s0, s0, 1
	
	la t0, char_pos
	
	la a0, felixidle
	lh a1, 0(t0) 
	lh a2, 2(t0)
	mv a3, s0
	call PRINT
	li t0, 0xFF200604
	sw s0, 0(t0)
	
	
	la t0, old_char_pos
	la a0, felixtile
	lh a1, 0(t0) 
	lh a2, 2(t0)
	
	mv a3, s0
	xori a3, a3, 1
	call PRINT
	
	j GAME_LOOP

KEY2: 
	li t1, 0xFF200000
	lw t0, 0(t1)
	andi t0, t0, 0x0001
	beq t0, zero, FIM
	lw t2, 4(t1)
	
	li t0,'a'
	beq t2, t0, CHAR_MOVE_LEFT
	li t0,'s'
	beq t2, t0, CHAR_MOVE_DOWN
	li t0,'d'
	beq t2, t0, CHAR_MOVE_RIGHT
	li t0,'w'
	beq t2, t0, CHAR_MOVE_UP
	
FIM: ret

CHAR_MOVE_LEFT: 
	la t0, char_pos
	la t1, old_char_pos
	lw t2, 0(t0)
	sw t2, 0(t1)
	
	
	lh t1, 0(t0)
	addi t1, t1, -4
	sh t1, 0(t0)
	ret
	
CHAR_MOVE_RIGHT: 
	la t0, char_pos
	la t1, old_char_pos
	lw t2, 0(t0)
	sw t2, 0(t1)
	lh t1, 0(t0)
	addi t1, t1, 4
	sh t1, 0(t0)
	ret
CHAR_MOVE_DOWN: 
	la t0, char_pos
	la t1, old_char_pos
	lw t2, 0(t0)
	sw t2, 0(t1)
	lh t1, 2(t0)
	addi t1, t1, 4
	sh t1, 2(t0)
	ret
CHAR_MOVE_UP: 
	la t0, char_pos
	la t1, old_char_pos
	lw t2, 0(t0)
	sw t2, 0(t1)
	lh t1, 2(t0)
	addi t1, t1, -4
	sh t1, 2(t0)
	ret
	

PRINT: 
	li t0, 0xFF0
	add t0, t0, a3
	slli t0, t0, 20
	
	add t0, t0, a1	
	
	li t1, 320
	mul t1, t1, a2
	add t0, t0, t1
	
	addi t1, a0, 8
	
	mv t2, zero
	mv t3, zero
	lw t4, 0(a0)
	lw t5, 4(a0)
	
PRINT_LINHA: 
	lw t6, 0(t1)
	sw t6, 0(t0)
	
	addi t0, t0, 4
	addi t1, t1, 4
	
	addi t3, t3, 4
	blt t3, t4, PRINT_LINHA
	
	addi t0, t0, 320
	sub t0, t0, t4
	
	mv t3, zero
	addi t2, t2, 1	
	bgt t5, t2, PRINT_LINHA
	
	ret 