.data
#Musica
CONTADOR_NOTAS: .word 0
TEMPO_ULTIMA_NOTA: .word 0
TEMPO_REST: .word 0


# Wreck it Ralph
TAMANHO: 48
NOTAS: 60,234,59,234,60,234,55,351,48,351,55,468,60,234,59,234,60,234,55,351,50,351,48,468,60,234,59,234,60,234,55,351,48,351,55,468,60,234,59,234,60,234,55,351,48,351,50,468,60,234,59,234,60,234,55,351,48,351,55,468,60,234,59,234,60,234,55,351,50,351,48,468,60,234,59,234,60,234,55,351,48,351,55,468,60,234,59,234,60,234,55,351,48,351,50,234

#Ducktales:
# TAMANHO: 98
# NOTAS: 60,246,60,82,60,246,60,82,64,328,60,328,53,328,53,328,57,328,60,328,60,164,60,328,60,164,64,328,60,328,64,328,65,328,64,328,60,328,60,328,62,164,62,164,62,328,64,328,66,328,64,328,62,328,64,328, 72,328,72,574,72,82,79,328,76,328,60,328,64,246,67,82,69,328,72,328,71,328,68,328,71,328,72,328,71,328,68,328,71,328,72,328,72,574,72,82,79,328,76,656,75,82,74,82,72,82,69,328,72,410,71,328,68,328,71,328,72,328,71,328,68,328,71,328, 60,335,64,335,67,335,69,335,71,335,71,167,69,335,67,167,65,335,65,502,64,837,65,502,64,837,60,335,64,335,67,335,69,335,71,335,71,167,69,335,67,167,65,335,71,502,69,837,71,502,69,1172,62,335,65,335,69,335,69,502,67,1172,69,335,72,335,74,335,76,502,74,837




.text

TOCA_MUSICA:
	csrr t0,time
	la t1,TEMPO_ULTIMA_NOTA
	lw t1,0(t1)
	sub t0,t0,t1
	la t1,TEMPO_REST
	lw t1,0(t1)
	
	bgeu t0,t1,TOCA_NOTA #verifica se já passou o tempo necessario para tocar a nota
	ret
	
TOCA_NOTA:
	la t0,CONTADOR_NOTAS
	mv t2,t0
	la t1,TAMANHO	
	lw t0,0(t0)	#t0 = contador de notas
	lw t1,0(t1)	#t1 = tamanho
	
	bne t0,t1,DIFERENTE #verifica se o contador já passou do tamanho da musica
	sw zero,0(t2)
	
DIFERENTE:
	li t1,8
	mul t1,t0,t1 #ajusta  aposicao da nota
	
	la t3,NOTAS
	add t3,t3,t1
	
	addi sp,sp,-8
	sw t3,0(sp) #guarda a posicao da nota
	sw ra,4(sp)
	
	
	
	#ecall para tocar musica
	
	lw a0,0(t3) #pitch
	lw a1,4(t3) #duracao
	li a2,4 #instrumento
	li a3,100 #volume
	li a7,31 #comentar
	ecall #comentar
	
	#funcao para tocar musica na placa
#	jal MIDI_SAVE #nao funciona no rars
	
	#recupera posicao nota
	
	lw t3,0(sp)
	lw ra,4(sp)
	addi sp,sp,8
	
	lw t4,4(t3)
	la t0,TEMPO_REST
	sw t4,0(t0)
	
	csrr t0,time
	la t1,TEMPO_ULTIMA_NOTA
	sw t0,0(t1)
	
	
	la t1,CONTADOR_NOTAS
	lw t2,0(t1)
	addi t2,t2,1
	sw t2,0(t1)
	
	ret
	