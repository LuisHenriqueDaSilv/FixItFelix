.text 
SETUP:
	la a0, felixidle
	li a1, 0
	li a2, 0
	li a3, 0

# a0, endereço da imagem
# a1 = x
# a2 = y
# a3 = frame

# t0 endereço do bitmap
# t1 endereço da imagem
# t2 contador de linha
# t3 contador de coluna
# t4 largura
# t5 altura
		

PRINT: 
	li t0, 0xff0
	add t0, t0, a3
	slli t0, t0, 20
	
	add t0, t0, a1	
	li t1, 320
	mul t1, t1, a2
	
	mv t2, zero
	mv t3, zero
	lw t4, 0(a0)
	lw t5, 4(a0)
	
PRINT_LINHA: 
	sw t6, 0(t0)
	addi t0, t0, 4
	addi t1, t1, 4
	
	addi t3, t3, 4
	
	blt t3, t4, PRINT_LINHA
	addi t0, t0, 320
	sub t0, t0, t4
	mv t3, zero
	addi t2, t2, 1	
	ble t2, t5, PRINT_LINHA
	ret 
	
.data
.include "../assets/felix/idle/felixidle.s"
