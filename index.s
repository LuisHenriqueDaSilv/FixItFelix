.data
	char_pos: .half 160, 0
	old_char_pos: .half, 0,0
	.include "assets/felix/idle/felixidle.data"
	.include "assets/felix/felixTile.s"
	.include "assets/background.data"
	.include "assets/colisionmap.data"

.text 

GAME_LOOP:
	
	call GRAVITY
	call KEY2
	xori s0, s0, 1
	
	la a0, background
	li a1, 0
	li a2, 0
	mv a3, s0
	call PRINT
	
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
	li t0,'d'
	beq t2, t0, CHAR_MOVE_RIGHT
	
	
FIM: ret

# Antes de andar:
	# Se ele chegou no final do mapa
		# Esquerda: 
			# Se x for maior que 0
		#Direta 
			# se total-x for maior que 0

	# Se ele bateu em uma parede
		#Direita:
			# Se x+step for diferente de 255 em colision map
		#Esquerda:
			# Se x-step for diferente de 255 em colision map

TEST_IF_COLLIDE_WITH_LEFT_SCREEN_LIMIT:
	addi t2, t1, -4 # t4 = charX-4
	bgtz t2, CHAR_MOVE_L # if(t4 > 0){CHAR_MOVE_L}
	ret

FALL:
	la t0, char_pos
	lh t1, 2(t0) # charY
	addi t1, t1, 2
	sh t1, 2(t0)
	ret

GRAVITY:
	# endAbaixo = charX + width*(charY+charHeight)
	la t0, char_pos
	lh t1, 0(t0) # charX
	lh t2, 2(t0) # charY
	la t0, colisionmap
	la t4, felixidle
	lw t5, 4(t4) # charHeight
	add t3, t2, t5  # t3 = charY + charHeight
	li t2, 320
	mul t0, t2, t3 # t0 = width*(charY+charHeight)
	add t0, t0, t1 # t0 = t0 + charX
	la t1, colisionmap
	add t0, t0, t1 # t0 = Endere?o charX + width*(charY+charHeight) na colision map
	lbu t1, 0(t0) #Valor do pixel em t0

	bnez t1, FALL
	ret

CHAR_MOVE_LEFT: 

	la t0, char_pos
	la t1, old_char_pos
	lw t2, 0(t0)
	sw t2, 0(t1)
	
	lh t1, 0(t0)              # t1 = charX (posicao X atual do jogador)
	lh t2, 2(t0)              # t2 = charY (posicao Y atual do jogador)

    la t3, colisionmap        # t3 aponta para o inicio do mapa de colisao
    li t4, 320                # t4 = largura do mapa de colisao (em pixels)
    mul t5, t2, t4            # t5 = deslocamento da linha (y * largura)
    add t5, t5, t1            # t5 = indice do pixel atual no mapa de colisao
	addi t5, t5, 7
	
    addi t5, t5, -2            # t5 = indice do pixel a esquerda no mapa

	add t3, t3, t5            # t3 = endereco do pixel a esquerda
	lbu t6, 0(t3)              # t6 = valor do pixel a esquerda no mapa de colisao

	bne t6, t4, TEST_IF_COLLIDE_WITH_LEFT_SCREEN_LIMIT
	ret

CHAR_MOVE_L:
	addi t1, t1, -4
	sh t1, 0(t0)
	ret


TEST_IF_COLLIDE_WITH_RIGHT_SCREEN_LIMIT:
	addi t5,zero, 300
	ble t1, t5, CHAR_MOVE_R
	ret
	
CHAR_MOVE_RIGHT: 
	
	la t0, char_pos
	la t1, old_char_pos
	lw t2, 0(t0)
	sw t2, 0(t1)

	lh t1, 0(t0)              # t1 = charX (posicao X atual do jogador)
	lh t2, 2(t0)              # t2 = charY (posicao Y atual do jogador)

    la t3, colisionmap        # t3 aponta para o inicio do mapa de colisao
    li t4, 320                # t4 = largura do mapa de colisao (em pixels)
    mul t5, t2, t4            # t5 = deslocamento da linha (y * largura)
    add t5, t5, t1            # t5 = indice do pixel atual no mapa de colisao
	addi t5, t5, 7
	
    addi t5, t5, 18            # t5 = indice do pixel a esquerda no mapa

	add t3, t3, t5            # t3 = endereco do pixel a esquerda
	lbu t6, 0(t3)              # t6 = valor do pixel a esquerda no mapa de colisao
	bne t6, t4 TEST_IF_COLLIDE_WITH_RIGHT_SCREEN_LIMIT
	ret


CHAR_MOVE_R:
	addi t1, t1, 4
	sh t1, 0(t0)
	ret				

PRINT: 
#	a0 = endere?o imagem			
#	a1 = x					
#	a2 = y					
#	a3 = frame (0 ou 1)	
		
#	t0 = endereco do bitmap display		
#	t1 = endereco da imagem			
#	t2 = contador de linha			
# 	t3 = contador de coluna			
#	t4 = largura				
#	t5 = altura

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