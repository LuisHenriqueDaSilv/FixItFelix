.text

TOCA_MUSICA:
	# Livres: 
		# a4  Endereco da data da musica
		# a5  Quantidade de notas 
		# a6  Endereco das notas
	csrr t0,time
	lw t1,8(a4)
	sub t0,t0,t1
	# la t1,TEMPO_REST
	lw t1,12(a4)
	
	bgeu t0,t1,TOCA_NOTA #verifica se já passou o tempo necessario para tocar a nota
	ret
	
TOCA_NOTA:
	# la t1,TAMANHO	
	lw t0,4(a4)	#t0 = contador de notas
	lw t1,0(a5)	#t1 = tamanho
	
	bne t0,t1,DIFERENTE #verifica se o contador já passou do tamanho da musica
	sw zero,4(a4)
	
DIFERENTE:
	li t1,8
	mul t1,t0,t1 #ajusta  aposicao da nota
	
	# la a6,NOTAS
	add a6,a6,t1
	
	addi sp,sp,-8
	sw a6,0(sp) #guarda a posicao da nota
	sw ra,4(sp)
	
	
	
	#ecall para tocar musica
	
	lw a0,0(a6) #pitch
	lw a1,4(a6) #duracao
	lw a2, 16(a4) #4 #instrumento
	lw a3, 20(a4) #volume
	li a7,31 #comentar
	ecall #comentar
	
	#funcao para tocar musica na placa
#	jal MIDI_SAVE #nao funciona no rars
	
	#recupera posicao nota
	
	lw t3,0(sp)
	lw ra,4(sp)
	addi sp,sp,8
	
	lw t4,4(t3)
	# la t0,TEMPO_REST
	sw t4,12(a4)
	
	csrr t0,time
	# la t1,TEMPO_ULTIMA_NOTA
	sw t0,8(a4)
	
	
	# la t1,CONTADOR_NOTAS
	lw t2,4(a4)
	addi t2,t2,1
	sw t2,4(a4)
	
	ret
	