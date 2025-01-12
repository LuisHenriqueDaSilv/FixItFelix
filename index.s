.data
   			   #(l: 1=esquerda ou 0=direita)
				   # 0   2  4       6
				   # x   y   l, aceleracaoY
	char_pos: .half 85, 194, 1, 		0
       
         
                
        barra_vidas_pos: .half 1 , 26   #posicao que barra de vida aparce
               
        score_pos: .half  1 , 12  	#posicao em que aparcee a pontuacao
        
        VIDAS: .byte 3   		#numero maximo de vidas
     
                              
    mov_animation: .half 0, 0, 0, 0, 0 # Esta em animacao, chegou no pico y, x alvo, y alvo, caindo

	.include "assets/felix/idle/felixidle.data"
	.include "assets/felix/idle/felixjumple.data"
	.include "assets/background2.data"
	.include "assets/vidas/1vidas.data"			#vidas 1
	.include "assets/vidas/2vidas.data"			#vidas 2
	.include "assets/vidas/3vidas.data"			#vidas 3
    .include "datas/janelas.data"

    # Definiï¿½ï¿½o das janelas (posiï¿½ï¿½o x, y)


.text
GAME_LOOP:
    # Configuracao do FPS do jogo (30 fps)
    li a0, 33
    call SLEEP  # A funcao sleep faz o sistema "dormir" pela quantidade de milissegundos definido em a0
    call KEY2  # Reconhece as teclas pressionadas

    la t0, mov_animation
    lh t1, 0(t0)
    li t2, 1
    beq t1, t2, JUMP_TO_ANIMATION
    j THEN_

    JUMP_TO_ANIMATION:
        call MOVE_ANIMATION
    THEN_:
    
    # Alterna entre os frames do personagem
    xori s0, s0, 1

    # Desenhar o background
    la a0, background2  # Carrega o endereï¿½o do background
    li a1, 0           # x do background
    li a2, 0           # y do background
    mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4, 0
    call PRINT

    # Desenhar o personagem
    la t0, char_pos    # t0 = endereï¿½o do personagem (x, y)
    la t2, mov_animation
    lh t3, 0(t2)
    li t4, 1
    beq t3, t4, LOAD_JUMP
    LOAD_IDLE:
        la a0, felixidle
        j LOAD_THEN
    LOAD_JUMP:
        la a0, felixjumple   # a0 = endereï¿½o da imagem do personagem
    LOAD_THEN:
    lh a1, 0(t0)       # a1 = x do personagem
    lh a2, 2(t0)       # a2 = y do personagem
    lh a4, 4(t0)       # a4 = direcao do personagem
    mv a3, s0          # a3 = frame atual (0 ou 1)
    call PRINT  

    call PRINT_JANELAS

    # Atualiza o frame mostrado
    li t0, 0xFF200604  # Endereï¿½o onde o ï¿½ndice do frame ï¿½ armazenado
    sw s0, 0(t0)       # Salva o frame atual no endereï¿½o acima

    #desenhando as 3 vidas
    jal a4, PRINTAR_VIDAS  
    
    j GAME_LOOP

KEY2:

    la t0, mov_animation
    li t1, 1
    lh t2, 0(t0)
    beq t2, t1, FIM

    # Funcao para detectar teclas pressionadas
    li t1, 0xFF200000
    lw t0, 0(t1)
    andi t0, t0, 0x0001
    beq t0, zero, FIM  # Se a tecla nï¿½o foi pressionada, vai para o fim
    lw t2, 4(t1)

    # Detectar teclas especï¿½ficas para movimentaï¿½ï¿½o
    li t0, 'a'
    beq t2, t0, CHAR_MOVE_LEFT
    li t0, 'A'
    beq t2, t0, CHAR_MOVE_LEFT
    li t0, 'd'
    beq t2, t0, CHAR_MOVE_RIGHT
    li t0, 'D'
    beq t2, t0, CHAR_MOVE_RIGHT
    li t0, 'W'
    beq t2, t0, CHAR_MOVE_UP
    li t0, 'w'
    beq t2, t0, CHAR_MOVE_UP
    li t0, 's'
    beq t2, t0, CHAR_MOVE_DOWN
    li t0, 'S'
    beq t2, t0, CHAR_MOVE_DOWN
    
    # li t0, ' '
    # beq t2, t0, CHAR_MOVE_UP
    ret  # Retorna caso nenhuma tecla seja pressionada

FIM:
    ret
 
    ##########################################   
PRINTAR_VIDAS:
	la a7, VIDAS #VIDAS é um .byte 3 , pq tem 3 vidas
	lb s10, 0(a7) #colocando o valor de vidas em s10
	la a5 barra_vidas_pos #posicao da barra de vida
	lh s7, 0(a5) # coordenada em x
	lh s8, 2(a5) # coordenada em y
	
	li s4,1  
	li a6,2
	li s6,3
	
	beq s10, s4, PRINT_VIDA1 # se s10 = 1 , mostra 1 vida
	beq s10, a6, PRINT_VIDA2 # se s10 = 2 , mostra 2 vida
	beq s10, s6, PRINT_VIDA3 # se s10 = 3 , mostra 3 vida
	ret
PRINT_VIDA3:
	
	la a0, vidas3 #caregando a imagem das 3 vidas
	li a1, 1
	li a2, 26
	mv a3, s0          # a3 = frame atual (0 ou 1)
    	li a4, 0
	call PRINT
	jalr t1, a4, 0
	
PRINT_VIDA2:

	la a0,vidas2 #caregando a imagem das 2 vidas
	li a1, 1
	li a2, 26
	mv a3, s0          # a3 = frame atual (0 ou 1)
    	li a4, 0
	call PRINT
	jalr t1, a4, 0
	
PRINT_VIDA1:

	la a0,vidas1 #caregando a imagem da 1 vidas
	li a1, 1
	li a2, 26
	mv a3, s0          # a3 = frame atual (0 ou 1)
    	li a4, 0
	call PRINT
	jalr t1, a4, 0

	

SEARCH_WINDOW:
    # a0 x do personagem
    # a1 y do personagem
    # a2 endereco de retorno
    # a3 endereco das janelas
    # Retorno:
        #a0: endereco da janela
    addi a3, a3, 8
    lh t4, 0(a3) # X da janela atual
    lh t5, 2(a3) # Y da janela atual
    bne a0, t4, SEARCH_WINDOW
    bne a1, t5, SEARCH_WINDOW
    mv a0, a3
    jalr t1, a2, 0


###############################################
MOVE_ANIMATION:
    la t0, mov_animation
    la t3, char_pos
    lh t1, 2(t0) # chegou no pico y
    li t2, 1
    beq t2, t1, SUB_Y

    lh t2, 8(t0)
    li t1, 1
    beq t2, t1, FALL
    li t1, 2
    beq t2, t1, UP

    ADD_Y:
        lh t4, 2(t3) # t4 = y do personagem
        lh t5, 6(t0) # t5 = y alvo

        ## Calc dist

        lh t6, 0(t3) # x do personagem
        lh t1, 4(t0) # x alvo
        blt t6, t1, CALC_DIST_A
        j CALC_DIST_B

        CALC_DIST_A:
            sub t6, t1, t6
            j THEN_CALC
        CALC_DIST_B:
            sub t6, t6, t1
        THEN_CALC:

        # addi t6, t5, -0
        li t5, 16 # metade do caminho horizontal de uma janela pra outra
        
        ble t6, t5, REACHED_TOP

        addi t4, t4, -2
        sh t4, 2(t3)

        j THEN_Y
        
        REACHED_TOP:
            li t1, 1
            sh t1, 2(t0)
            j THEN_Y

    SUB_Y:
        lh t4, 2(t3) # t4 = y do personagem
        lh t5, 6(t0) # t5 = y alvo
        beq t4, t5, THEN_Y # Chegou no y alvo
        
        addi t4, t4, 2
        sh t4, 2(t3)

    THEN_Y:
    lh t4, 0(t3) # t4 = x do personagem
    lh t5, 4(t0) # x alvo
    lh t1, 4(t3) # DireÃ§Ã£o do personagem
    li t2, 1
    bne t1, t2, RIGHT_ANIMATION

    #LEFT_ANIMATION:
    ble t4, t5, END_ANIMATION
    addi t4, t4, -4
    sh t4, 0(t3)
    j THEN

    RIGHT_ANIMATION:
        bge t4, t5, END_ANIMATION
        addi t4, t4, 4
        sh t4, 0(t3)
        j THEN
    
    END_ANIMATION:
        li t1, 0
        sh t1, 0(t0) # Esta em animacao
        li t1, 0
        sh t1, 2(t0) # chegou no pico y

        sh t5, 0(t3)
        lh t5, 6(t0) # t5 = y alvo
        sh t5, 2(t3)

    THEN:
    ret

    FALL:
        lh t4, 2(t3) # t4 = y do personagem
        lh t5, 6(t0) # t5 = y alvo
        beq t4, t5, THEN_Y # Chegou no y alvo
        
        addi t4, t4, 4
        sh t4, 2(t3)
        ret
    UP:
        lh t4, 2(t3) # t4 = y do personagem
        lh t5, 6(t0) # t5 = y alvo
        beq t4, t5, THEN_Y # Chegou no y alvo
        
        addi t4, t4, -4
        sh t4, 2(t3)
        ret

CHAR_MOVE_LEFT:
    la t0, char_pos    # t0 = endereï¿½o do personagem (x, y)
    lh t1, 0(t0)       # t1 = x do personagem
    lh t6, 2(t0)       # t6 = y do personagem
    li t2, 85 # x limite da ultima janela da esquerda
    ble t1, t2, FIM

    la t3, windows
    addi t3, t3, -8
    mv a0, t1
    mv a1, t6
    mv a3, t3
    jal a2, SEARCH_WINDOW
    
    mv t3, a0
    addi t3, t3, -8 # Janela destino
    lh t4, 0(t3) # X da janela destino
    lh t5, 2(t3) # Y da janela destino

    li t3,1
    sh t3, 4(t0)

    la t0, mov_animation
    li t1, 1
    sh t1, 0(t0) # Esta em animacao
    li t1, 0
    sh t1, 2(t0) # chegou no pico y
    sh t4, 4(t0) # x alvo
    sh t5, 6(t0) # y alvo
    la t1, char_pos
    lh t1, 2(t1) # y do personagem
    li t1, 0
    sh t1, 8(t0) # caindo

    # sh t4, 0(t0)
    # sh t5, 2(t0)

    ret

CHAR_MOVE_RIGHT:
    la t0, char_pos    # t0 = endereï¿½o do personagem (x, y)
    lh t1, 0(t0)       # t1 = x do personagem
    lh t6, 2(t0)       # t6 = y do personagem
    li t2, 216 # x limite da ultima janela da esquerda
    bge t1, t2, FIM

    la t3, windows
    addi t3, t3, -8
    mv a0, t1
    mv a1, t6
    mv a3, t3
    jal a2, SEARCH_WINDOW
    
    mv t3, a0
    addi t3, t3, 8 # Janela destino
    lh t4, 0(t3) # X da janela destino
    lh t5, 2(t3) # Y da janela destino

    li t3,0
    sh t3, 4(t0)

    # Inicia a animacao:
    la t0, mov_animation
    li t1, 1
    sh t1, 0(t0) # Esta em animacao
    li t1, 0
    sh t1, 2(t0) # chegou no pico y
    sh t4, 4(t0) # x alvo
    sh t5, 6(t0) # y alvo
    la t1, char_pos
    lh t1, 2(t1) # y do personagem
    li t1, 0
    sh t1, 8(t0) # caindo

    ret

CHAR_MOVE_UP:
    la t0, char_pos    # t0 = endereï¿½o do personagem (x, y)
    lh t1, 0(t0)       # t1 = x do personagem
    lh t6, 2(t0)       # t6 = y do personagem
    li t2, 74 # y limite da ultima janela da esquerda
    ble t6, t2, FIM

    la t3, windows
    addi t3, t3, -8
    mv a0, t1
    mv a1, t6
    mv a3, t3
    jal a2, SEARCH_WINDOW
    
    mv t3, a0
    addi t3, t3, 40 # Janela destino
    lh t4, 0(t3) # X da janela destino
    lh t5, 2(t3) # Y da janela destino

    # Inicia a animacao:
    la t0, mov_animation
    li t1, 1
    sh t1, 0(t0) # Esta em animacao
    li t1, 0
    sh t1, 2(t0) # chegou no pico y
    sh t4, 4(t0) # x alvo
    sh t5, 6(t0) # y alvo
    li t1, 2
    sh t1, 8(t0) # caindo

    # sh t4, 0(t0)
    # sh t5, 2(t0)

    ret

CHAR_MOVE_DOWN:
    la t0, char_pos    # t0 = endereï¿½o do personagem (x, y)
    lh t1, 0(t0)       # t1 = x do personagem
    lh t6, 2(t0)       # t6 = y do personagem
    li t2, 203 # y limite da porta
    bge t6, t2, FIM
    li t2, 194 # y limite da janela mais baixa
    bge t6, t2, FIM

    la t3, windows
    addi t3, t3, -8
    mv a0, t1
    mv a1, t6
    mv a3, t3
    jal a2, SEARCH_WINDOW
    
    mv t3, a0
    addi t3, t3, -40 # Janela destino
    lh t4, 0(t3) # X da janela destino
    lh t5, 2(t3) # Y da janela destino

    # Inicia a animacao:
    la t0, mov_animation
    li t1, 1
    sh t1, 0(t0) # Esta em animacao
    li t1, 0
    sh t1, 2(t0) # chegou no pico y
    sh t4, 4(t0) # x alvo
    sh t5, 6(t0) # y alvo
    li t1, 1
    sh t1, 8(t0) # caindo

    # sh t4, 0(t0)
    # sh t5, 2(t0)
    ret 
    

PRINT:
    # Desenha a imagem
    li t0, 0xFF0
    add t0, t0, a3      # Endereï¿½o do frame atual (0 ou 1)
    slli t0, t0, 20     # Move 20 bits ï¿½ esquerda
    li t1, 320          # Largura da tela
    mul t1, t1, a2      # Largura da linha da imagem
    add t0, t0, t1      # Endereï¿½o da linha de imagem
    add t0, t0, a1      # Posiï¿½ï¿½o exata para desenhar a imagem
    addi t1, a0, 8      # Pula as duas primeiras palavras (info da imagem)

    # Desenha linha por linha da imagem
    mv t2, zero         # Contador de linhas
    mv t3, zero         # Contador de colunas
    lw t4, 0(a0)        # Largura da imagem
    lw t5, 4(a0)        # Altura da imagem

    beqz a4, PRINT_LINE
    bnez a4, PRINT_INVERTED_LINE
    ret

    # Funï¿½ï¿½o para desenhar a linha da imagem
    PRINT_LINE:
        lw t6, 0(t1)  # Lï¿½ uma palavra da imagem
        sw t6, 0(t0)  # Escreve no bitmap
        addi t0, t0, 4
        addi t1, t1, 4
        addi t3, t3, 4
        blt t3, t4, PRINT_LINE  # Se nï¿½o chegou ao fim da linha, continua
        addi t0, t0, 320         # Vai para a prï¿½xima linha
        sub t0, t0, t4           # Ajusta para o inï¿½cio da prï¿½xima linha
        mv t3, zero
        addi t2, t2, 1
        bgt t5, t2, PRINT_LINE
        ret

    PRINT_INVERTED_LINE:
        add t1, t1, t4  # Vai para o final da linha
        INVERTED_PRINT_LOOP:
            lb t6, 0(t1)
            sb t6, 0(t0)
            addi t0, t0, 1
            addi t1, t1, -1
            addi t3, t3, 1
            blt t3, t4, INVERTED_PRINT_LOOP
            addi t0, t0, 320
            sub t0, t0, t4
            add t1, t1, t4
            mv t3, zero
            addi t2, t2, 1
            bgt t5, t2, PRINT_INVERTED_LINE
        ret

PRINT_JANELAS:
    la t1, windows
    ret


SLEEP:
    # Funï¿½ï¿½o de delay
    li a7, 32
    ecall
    ret
