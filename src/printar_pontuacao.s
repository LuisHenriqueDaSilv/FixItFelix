PRINTAR_PONTUACAO:
			
addi a1, a1, -1			
jal pow

mv a5, a4 
mv a4, a3 
mv a3, a0 
mv s10, a2 

li s4, 10
li t0, 1

LP32:
	beq s10, t0, LE32		
	#---------------
	div t5, a3, s10			
	rem a3, a3, s10			

	mv a0, t5
	mv a1, a4
	mv a2, a5
	jal renderDigit			

	addi a4, a4, 8			
	#---------------
	div s10, s10, s4		
	jal zero, LP32			
LE32:

mv a0, a3					
mv a1, a4
mv a2, a5
jal renderDigit

    # Verificar a pontuação
    la t0, Pontos            # Carrega o endereço de Pontos
    lh t1, 0(t0)             # Lê a pontuação atual de Pontos como half (16 bits)
    li t2, 2600              # Carrega o valor 2600 (pontuação de 2600)
    beq t1, t2, ATINGIU_2600  # Se a pontuação for maior ou igual a 2600, pula para ATINGIU_2600
    li t2, 5700              # Carrega o valor 2600 (pontuação de 2600)
    beq t1, t2, ATINGIU_5700  # Se a pontuação for maior ou igual a 2600, pula para ATINGIU_2600
	jalr t1, s7, 0
ATINGIU_2600:
	call START_PHASE_TRANSITION
    jalr t1, s7, 0           # Continua o fluxo normal
    ret
ATINGIU_5700:
	call START_PHASE_TRANSITION_2
    jalr t1, s7, 0           # Continua o fluxo normal
    ret
    
renderDigit:
la s5, nums
li s1, 128		
mul s1, s1, a0		
add s1, s1, s5	 
li s2, 0xff0	
add s2, s2, s0
slli s2, s2, 20	
li s3, 320		

mul t1, s3, a2		
add t1, t1, a1		
add t1, t1, s2		
li t2, 5120		
add t2, t2, t1		

LP29:
	bge t1, t2, LE29	
	#---------------
	addi t3, t1, 8	
	LP30:
		bge t1, t3, LE30	
		#---------------
		lb t4, 0(s1)	
		sb t4, 0(t1)	
		addi s1, s1, 1	
		#---------------
		addi t1, t1, 1	
		jal zero, LP30 	
	LE30: 
	#---------------
	addi t1, t1, 312	
	jal zero, LP29	
LE29:
ret

pow:
li t0, 0
li t1, 1
li t2, 10
LP31:
	bge t0, a1, LE31		
	#---------------
	mul t1, t1, t2		
	#---------------
	addi t0, t0, 1			
	jal zero, LP31			
LE31:
mv a2, t1				
ret

jalr t1, s7, 0