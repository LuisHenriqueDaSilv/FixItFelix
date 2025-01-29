# Registradores globais (Nao pode usar)
# s0=Frame atual
# s7=Ponteiro para retorno em algumas funcoes (Para onde o programa deve voltar depois da chamada)

###########################################################
.macro MACRO_PRINT_LEVEL 
	li a1, 304
	li a2, 1
	mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4,0
	call PRINT
.end_macro

.macro MACRO_PRINT_GAMEOVER_VITORIA
	li a1, 40
	li a2, 66
	mv a3, s0          # a3 = frame atual (0 ou 1)
    	li a4,0
	call PRINT
.end_macro

###########################################################
.macro MACRO_PRINT_LIFES 
    li a1, 1
	li a2, 26
	mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4,0
	call PRINT
.end_macro

#############################################################
.data
   			   
	#			    x   y   l, aceleracaoY, fixing (l: 1=esquerda ou 0=direita)
	char_data: .half 85, 194, 1, 		0,     0
    fases_pos: .half 304, 1
    barra_vidas_pos: .half 1 , 26   #posicao que barra de vida aparece
    score_pos: .half  1 , 12  	#posicao em que aparcee a pontuacao
    VIDAS: .byte 3   		#numero maximo de vidas
    FASES: .byte 1 #numero da fase inicial
    char_animation_data: .half 0, 0, 0, 0, 0 # Esta em animacao, chegou no pico y, x alvo, y alvo, caindo
    Pontos: .half 0

    .eqv tela 0xff0

	.include "assets/felix/idle/felixidle.data"
	.include "assets/felix/idle/felixjumple.data"
	.include "assets/felix/idle/felixfix.data"
	.include "assets/felix/fix/fix1.data"
	.include "assets/felix/fix/fix2.data"
	.include "assets/sounds/music.data"
    .include "assets/background2.data"
    .include "assets/fase1.data"
    .include "assets/fase2.data"
    .include "assets/tijolos.data"
	.include "assets/vidas/1vidas.data"
	.include "assets/vidas/2vidas.data"
	.include "assets/vidas/3vidas.data"
    .include "assets/janelas/janela0.data"
    .include "assets/janelas/janela1.data"
    .include "assets/janelas/janela2.data"
    .include "assets/ralph/RalphIdle.data"
    .include "assets/ralph/walk/RalphWalk1.data"
    .include "assets/ralph/walk/RalphWalk2.data"
    .include "assets/ralph/attack/RalphAttack2.data"
    .include "assets/ralph/attack/RalphAttack1.data"
    .include "nums.data"
    .include "assets/vitoria/vitoriafase1.data"


    .include "assets/vidas/0vidas.data"
    .include "assets/gameover.data"

    .include "datas/janelas.data"
    .include "datas/ralph.data"
    .include "datas/bricks.data"

.text
GAME_LOOP:
    call TOCA_MUSICA

    # Configuracao do FPS do jogo (30 fps)
    li a0, 24
    call SLEEP  # A funcao sleep faz o sistema "dormir" pela quantidade de milissegundos definido em a0
    call KEY2  # Reconhece as teclas pressionadas

    la t0, char_animation_data
    lh t1, 0(t0)
    li t2, 1
    beq t1, t2, CALL_MOVE_ANIMATION
    j AFTER_MOVE_ANIMATION

    CALL_MOVE_ANIMATION:
        call MOVE_ANIMATION
    AFTER_MOVE_ANIMATION:
    
    # Alterna entre os frames do personagem
    xori s0, s0, 1

    # Desenhar o background
    la a0, background2  # Carrega o endereco do background
    li a1, 0           # x do background
    li a2, 0           # y do background
    mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4, 0
    call PRINT
    jal a6, PRINT_JANELAS

    jal s7, PRINT_AND_MOVE_BRICKS

    # Movimentacao do Ralph
    jal s7, MOVE_RALPH

    la t0, ralph_animation_data
    lh t1, 0(t0)
    li t2, 0
    beq t2, t1, PRINT_RALPH_IDLE

    jal s7, RALPH_ANIMATION
    j AFTER_PRINT_RALPH
    
    PRINT_RALPH_IDLE:
        # Desenhar o Ralph
        la t2, ralph_data
        la a0, RalphIdle  # Carrega o endereco do ralph
        lh a1, 0(t2)           # x do ralph
        lh a2, 2(t2)          # y do ralph
        mv a3, s0          # a3 = frame atual (0 ou 1)
        li a4, 0
        call PRINT
    AFTER_PRINT_RALPH:

    # Desenhar o personagem
    la t0, char_data    # t0 = endereco do personagem (x, y)
    lh t1, 8(t0)
    li t2, 1
    la a6, AFTER_PRINT_CHAR
    beq t1, t2, FIX_ANIMATION

    la t2, char_animation_data
    lh t3, 0(t2)
    li t4, 1
    beq t3, t4, LOAD_CHAR_JUMP_SPRITE
    LOAD_CHAR_IDLE_SPRITE:
        la a0, felixidle
        j AFTER_LOAD_CHAR_SPRITE
    LOAD_CHAR_JUMP_SPRITE:
        la a0, felixjumple   # a0 = endereco da imagem do personagem
    AFTER_LOAD_CHAR_SPRITE:
    lh a1, 0(t0)       # a1 = x do personagem
    lh a2, 2(t0)       # a2 = y do personagem
    lh a4, 4(t0)       # a4 = direcao do personagem
    mv a3, s0          # a3 = frame atual (0 ou 1)
    call PRINT
    AFTER_PRINT_CHAR:

    # Atualiza o frame mostrado
    li t0, 0xFF200604  # Endereco onde o indice do frame eh armazenado
    sw s0, 0(t0)       # Salva o frame atual no endereco acima

    #desenhando as 3 vidas
    jal s7, PRINTAR_VIDAS  
    #desenhando o numero das fases
    jal s7, PRINTAR_FASES

    jal s7, TEST_BRICK_COLISION_WITH_CHAR

    #desenhando os pontos
    la a0, Pontos
    lh a0, 0(a0)
    li a1, 4	
    li a3, 18			
    li a4, 10	
    jal s7, PRINTAR_PONTUACAO
    
    j GAME_LOOP

KEY2:

    la t0, char_animation_data
    li t1, 1
    
    lh t2, 0(t0) # Se o personagem esta em animacao
    beq t2, t1, FIM # Se estiver em animacao, ignora qualquer tecla
    la t0, char_data
    li t1, 1
    lh t2, 8(t0)  #t2 = 1 se o personagem esta concertando uma janela, 0 caso nao
    beq t2, t1, FIM# Se o personagem estiver concertando uma janela, ignora qualquer tecla

    # Funcao para detectar teclas pressionadas
    li t1, 0xFF200000
    lw t0, 0(t1)
    andi t0, t0, 0x0001
    beq t0, zero, FIM  # Se a tecla nao foi pressionada, vai para o fim
    lw t2, 4(t1)

    # Detectar teclas espec?ficas para movimenta??o
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
    li t0, 'l'
    beq t2, t0, FIX
    li t0, 'L'
    beq t2, t0, FIX 


    ret  # Retorna caso nenhuma tecla seja pressionada

FIM:
    ret
 ##########################################
DIMINUI_VIDAS:
    la t0, VIDAS       # Carrega o endereÃ§o da variÃ¡vel VIDAS
    lb t1, 0(t0)       # Carrega o valor de VIDAS
    beqz t1, FIM       # Se VIDAS jÃ¡ for 0, nÃ£o decrementar
    addi t1, t1, -1    # Decrementa VIDAS
    sb t1, 0(t0)       # Atualiza VIDAS na memÃ³ria
    jal PRINTAR_VIDAS  # Atualiza o HUD de vidas
    ret
PRINTAR_FASES:
    la t0, FASES #FASES eh um .byte 1 , pq come?a na fase 1
	lb t1, 0(t0) #t1 = numero da fase atual
	li t2,1 
	li t3,2
	beq t1, t2, PRINT_FASE1 # se t1 = 1 , mostra numero 1
	beq t1, t3, PRINT_FASE2 # se t1 = 2 , mostra numero 2
	ret
	
PRINT_FASE1:
	la a0, fase1
	MACRO_PRINT_LEVEL
	jalr t1, s7, 0
	
PRINT_FASE2:
    la a0, fase2
    MACRO_PRINT_LEVEL
  
     jalr t1, s7, 0

    ##########################################   
PRINTAR_VIDAS:
	la t0, VIDAS #VIDAS ? um .byte 3 , pq tem 3 vidas
	lb t1, 0(t0) #colocando o valor de vidas em t1
	
	li t2,1  
	li t3,2
	li t4,3
	beq t1, t2, PRINT_VIDA1 # se s10 = 1 , mostra 1 vida
	beq t1, t3, PRINT_VIDA2 # se s10 = 2 , mostra 2 vida
	beq t1, t4, PRINT_VIDA3 # se s10 = 3 , mostra 3 vida
    	beqz t1, PRINT_GAMEOVER 
	ret
PRINT_VIDA3:
	la a0, vidas3 #caregando a imagem das 3 vidas
	MACRO_PRINT_LIFES
	jalr t1, s7, 0
	
PRINT_VIDA2:
	la a0,vidas2 #caregando a imagem das 2 vidas
	MACRO_PRINT_LIFES
	jalr t1, s7, 0
	
PRINT_VIDA1:
	la a0,vidas1 #  caregando a imagem da 1 vidas
	MACRO_PRINT_LIFES
	jalr t1, s7, 0

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
    bne a0, t4, SEARCH_WINDOW # Se o x da janela for diferente do que ta procurando, continua procurando
    bne a1, t5, SEARCH_WINDOW # Se o y da janela for diferente do que ta procurando, continua procurando
    mv a0, a3
    jalr t1, s7, 0

###############################################
MOVE_ANIMATION:
    la t0, char_animation_data
    la t3, char_data
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
            j AFTER_CALC_DIST
        CALC_DIST_B:
            sub t6, t6, t1
        AFTER_CALC_DIST:
        li t5, 16 # metade do caminho horizontal de uma janela pra outra
        ble t6, t5, REACHED_TOP
        addi t4, t4, -2
        sh t4, 2(t3)
        j AFTER_CHANGE_Y
        
        REACHED_TOP:
            li t1, 1
            sh t1, 2(t0)
            j AFTER_CHANGE_Y

    SUB_Y:
        lh t4, 2(t3) # t4 = y do personagem
        lh t5, 6(t0) # t5 = y alvo
        beq t4, t5, AFTER_CHANGE_Y # Chegou no y alvo
        
        addi t4, t4, 2
        sh t4, 2(t3)

    AFTER_CHANGE_Y:
    lh t4, 0(t3) # t4 = x do personagem
    lh t5, 4(t0) # x alvo
    lh t1, 4(t3) # Direcao do personagem
    li t2, 1
    bne t1, t2, RIGHT_ANIMATION

    LEFT_ANIMATION:
    ble t4, t5, END_ANIMATION
    addi t4, t4, -4
    sh t4, 0(t3)
    j END_OF_ANIMATION_FUNCTION

    RIGHT_ANIMATION:
        bge t4, t5, END_ANIMATION
        addi t4, t4, 4
        sh t4, 0(t3)
        j END_OF_ANIMATION_FUNCTION
    
    END_ANIMATION:
        li t1, 0
        sh t1, 0(t0) # Esta em animacao
        li t1, 0
        sh t1, 2(t0) # chegou no pico y

        sh t5, 0(t3)
        lh t5, 6(t0) # t5 = y alvo
        sh t5, 2(t3)

    END_OF_ANIMATION_FUNCTION:
    ret

    FALL:
        lh t4, 2(t3) # t4 = y do personagem
        lh t5, 6(t0) # t5 = y alvo
        beq t4, t5, AFTER_CHANGE_Y # Chegou no y alvo
        
        addi t4, t4, 4
        sh t4, 2(t3)
        ret
    UP:
        lh t4, 2(t3) # t4 = y do personagem
        lh t5, 6(t0) # t5 = y alvo
        beq t4, t5, AFTER_CHANGE_Y # Chegou no y alvo
        
        addi t4, t4, -4
        sh t4, 2(t3)
        ret

CHAR_MOVE_LEFT:
    la t0, char_data    # t0 = endereco do personagem (x, y)
    lh t1, 0(t0)       # t1 = x do personagem
    lh t6, 2(t0)       # t6 = y do personagem
    li t2, 85        # x limite da ultima janela da esquerda
    ble t1, t2, FIM

    la t3, windows
    addi t3, t3, -8
    mv a0, t1
    mv a1, t6
    mv a3, t3
    jal s7, SEARCH_WINDOW
    
    mv t3, a0
    addi t3, t3, -8 # Janela destino
    lh t4, 0(t3) # X da janela destino
    lh t5, 2(t3) # Y da janela destino

    li t3,1
    sh t3, 4(t0)

    la t0, char_animation_data
    li t1, 1
    sh t1, 0(t0) # Esta em animacao
    li t1, 0
    sh t1, 2(t0) # chegou no pico y
    sh t4, 4(t0) # x alvo
    sh t5, 6(t0) # y alvo
    la t1, char_data
    lh t1, 2(t1) # y do personagem
    li t1, 0
    sh t1, 8(t0) # caindo
    ret

CHAR_MOVE_RIGHT:
    la t0, char_data    # t0 = enderenco do personagem (x, y)
    lh t1, 0(t0)       # t1 = x do personagem
    lh t6, 2(t0)       # t6 = y do personagem
    li t2, 216 # x limite da ultima janela da esquerda
    bge t1, t2, FIM

    la t3, windows
    addi t3, t3, -8
    mv a0, t1
    mv a1, t6
    mv a3, t3
    jal s7, SEARCH_WINDOW
    
    mv t3, a0
    addi t3, t3, 8 # Janela destino
    lh t4, 0(t3) # X da janela destino
    lh t5, 2(t3) # Y da janela destino
    li t3,0
    sh t3, 4(t0)

    # Inicia a animacao:
    la t0, char_animation_data
    li t1, 1
    sh t1, 0(t0) # Esta em animacao
    li t1, 0
    sh t1, 2(t0) # chegou no pico y
    sh t4, 4(t0) # x alvo
    sh t5, 6(t0) # y alvo
    la t1, char_data
    lh t1, 2(t1) # y do personagem
    li t1, 0
    sh t1, 8(t0) # caindo
    ret

CHAR_MOVE_UP:
    la t0, char_data    # t0 = endere?o do personagem (x, y)
    lh t1, 0(t0)       # t1 = x do personagem
    lh t6, 2(t0)       # t6 = y do personagem
    li t2, 74 # y limite da ultima janela da esquerda
    ble t6, t2, FIM

    la t3, windows
    addi t3, t3, -8
    mv a0, t1
    mv a1, t6
    mv a3, t3
    jal s7, SEARCH_WINDOW
    
    mv t3, a0
    addi t3, t3, 40 # Janela destino
    lh t4, 0(t3) # X da janela destino
    lh t5, 2(t3) # Y da janela destino

    # Inicia a animacao:
    la t0, char_animation_data
    li t1, 1
    sh t1, 0(t0) # Esta em animacao
    li t1, 0
    sh t1, 2(t0) # chegou no pico y
    sh t4, 4(t0) # x alvo
    sh t5, 6(t0) # y alvo
    li t1, 2
    sh t1, 8(t0) # caindo
    ret

CHAR_MOVE_DOWN:
    la t0, char_data    # t0 = endere?o do personagem (x, y)
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
    jal s7, SEARCH_WINDOW
    
    mv t3, a0
    addi t3, t3, -40 # Janela destino
    lh t4, 0(t3) # X da janela destino
    lh t5, 2(t3) # Y da janela destino

    # Inicia a animacao:
    la t0, char_animation_data
    li t1, 1
    sh t1, 0(t0) # Esta em animacao
    li t1, 0
    sh t1, 2(t0) # chegou no pico y
    sh t4, 4(t0) # x alvo
    sh t5, 6(t0) # y alvo
    li t1, 1
    sh t1, 8(t0) # caindo
    ret 
    

PRINT:
    # a0 = endereco da imagem
    # a1 = x
    # a2 = y
    # a3 = frame
    # a4 = sentido da imagem
    # Desenha a imagem
    li t0, 0xFF0
    add t0, t0, a3      # Endereco do frame atual (0 ou 1)
    slli t0, t0, 20     # Move 20 bits a esquerda
    li t1, 320          # Largura da tela
    mul t1, t1, a2      # Largura da linha da imagem
    add t0, t0, t1      # Endereco da linha de imagem
    add t0, t0, a1      # Posicao exata para desenhar a imagem
    addi t1, a0, 8      # Pula as duas primeiras palavras (info da imagem)

    # Desenha linha por linha da imagem
    mv t2, zero         # Contador de linhas
    mv t3, zero         # Contador de colunas
    lw t4, 0(a0)        # Largura da imagem
    lw t5, 4(a0)        # Altura da imagem

    beqz a4, PRINT_LINE
    bnez a4, PRINT_INVERTED_LINE
    ret

    # Fun??o para desenhar a linha da imagem
    PRINT_LINE:
        lw t6, 0(t1)  # L? uma palavra da imagem
        sw t6, 0(t0)  # Escreve no bitmap
        addi t0, t0, 4
        addi t1, t1, 4
        addi t3, t3, 4
        blt t3, t4, PRINT_LINE  # Se n?o chegou ao fim da linha, continua
        addi t0, t0, 320         # Vai para a pr?xima linha
        sub t0, t0, t4           # Ajusta para o in?cio da pr?xima linha
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
    # parametros:
        #a0: ENDERECO DE RETORNO
    la s1, windows
    addi s1, s1, -8
    li s2, 0 # Contador de quantas janelas foram desenhadas
    NEXT_WINDOW:

        addi s1, s1, 8
        lh t2, 0(s1) # t2 = x da janela
        lh t3, 2(s1) # t3 = y da janela
        lh t1, 4(s1) # Se eh janela
        lh t6, 6(s1) # status da janela
        li t0, 12
        bne t0, s2, AFTER_SOMA
        addi t2, t2, -5
        AFTER_SOMA:

        li t5, 1
        bne t1, t5, END_OF_ANIMATION_FUNCTION_PRINT_WINDOW
        li t1, 0
        beq t6, t1, LOAD_WINDOW_0
        li t1, 1
        beq t6, t1, LOAD_WINDOW_1
        j LOAD_WINDOW_2
        LOAD_WINDOW_0:
            la t4, janela0
            j END_OF_ANIMATION_FUNCTION_LOAD
        LOAD_WINDOW_1:
            la t4, janela1
            j END_OF_ANIMATION_FUNCTION_LOAD
        LOAD_WINDOW_2:
            la t4, janela2
            j END_OF_ANIMATION_FUNCTION_LOAD


        END_OF_ANIMATION_FUNCTION_LOAD:
        addi a1, t2, -6
        addi a2, t3, -6
        mv a0, t4
        li a4, 1

        call PRINT

        END_OF_ANIMATION_FUNCTION_PRINT_WINDOW:
            addi s2, s2, 1
            li t1, 15
            bne s2, t1, NEXT_WINDOW
        
    jalr t0, a6, 0


FIX:

    la t0, char_data    # t0 = endereco do personagem (x, y)
    li t1, 1
    li s9, 0
    sh t1, 8(t0)

    ret

FIX_ANIMATION:
    la t0, char_data
    addi s9, s9, 1
    li t1, 5
    bgt s9, t1, SECOND_FRAME_FIX

    FIRST_FRAME_FIX:
        la a0, fix1   # a0 = endereco da imagem do personagem
        lh a1, 0(t0)       # a1 = x do personagem
        lh a2, 2(t0)       # a2 = y do personagem
        lh a4, 4(t0)       # a4 = direcao do personagem
        mv a3, s0          # a3 = frame atual (0 ou 1)
        addi a2, a2, -5
        call AFTER_LOAD_FIX_FRAME

    SECOND_FRAME_FIX:
        la a0, fix2   # a0 = endereco da imagem do personagem
        lh a1, 0(t0)       # a1 = x do personagem
        lh a2, 2(t0)       # a2 = y do personagem
        lh a4, 4(t0)       # a4 = direcao do personagem
        mv a3, s0          # a3 = frame atual (0 ou 1)
        li t1, 0
        beq t1, a4, AFTER_LOAD_FIX_FRAME
        addi a1, a1, -18
    AFTER_LOAD_FIX_FRAME:
    addi a2, a2, -5

    call PRINT
    li t1, 8
    bge s9, t1, END_FIX_ANIMATION
    jalr t0, a6, 0
    
    END_FIX_ANIMATION:
        la t2, char_data
        li t1, 0,
        sh t1, 8(t2)

        la t3, windows
        addi t3, t3, -8
        lh t6, 2(t2)
        lh t1, 0(t2)
        mv a0, t1
        mv a1, t6
        mv a3, t3
        jal s7, SEARCH_WINDOW # a0 = janela atual
        lh t1, 6(a0)
        addi t1, t1, 1
        sh t1, 6(a0)

        la t4, Pontos
        lh t5, 0(t4)
        addi t5, t5, 100
        sh t5, 0(t4) 

        jalr t0, a6, 0

MOVE_RALPH:

    la t5, ralph_animation_data
    li t0, 1
    lh t2, 0(t5)
    beq t2, t0, END_RALPH_MOVE # Se ja esta em movimento, nao inicia outro

    li a7, 30
    ecall

    la t4, ralph_animation_delay
    lw t0, 0(t4) # Ms do fim da ultima movimentacao
    sub t1, a0, t0

    lh t6, 10(t5)
    li t0, 1
    beq t6, t0, LOAD_WALK_DELAY
    LOAD_ATTACK_DELAY:
        li t2, 200 # Intervalo em ms entre cada movimentacao
        j AFTER_LOAD_DELAY
    LOAD_WALK_DELAY:
        li t2, 500 # Intervalo em ms entre cada movimentacao
    AFTER_LOAD_DELAY:
    bltu t1, t2, END_RALPH_MOVE # Se nao passou 1000ms desde a ultima movimentacao, fica parado

    lh t6, 10(t5)
    li t0, 1
    beq t0, t6, INICIO_ANDAR

    INICIAR_ATAQUE:
        # Se ultimo movimento foi andar, proximo eh ataque:
        # Salvar como atacando
        # zerar todas as variaveis
        li t0, 0
        sh t0, 10(t5)
        li t0, 1
        sh t0, 0(t5)
        j END_RALPH_MOVE 

    INICIO_ANDAR:
    li t0, 1
    la t1, ralph_animation_data
    lh t2, 0(t1)
    beq t2, t1, END_RALPH_MOVE
    sw a0, 0(t4) # Salva o ms do ultimo 

    SORTEAR:   
        li a0, 0
        li a1, 5
        li a7, 42
        ecall
        li t1, 2 
        mul t0, a0, t1
        la t1, ralph_positions_x
        add t1, t1, t0 # t1 = endereco da janela sorteada
        lh t2, 0(t1) # t2 = x da janela sorteada
        la t1, ralph_data
        lh t3, 0(t1) # x atual do personagem
        beq t3, t2, SORTEAR # Sorteia ate achar uma janela diferente da atual

    la t0, ralph_animation_data
    li t1, 1
    sh t1, 0(t0)
    sh t2, 2(t0) # X do ralph

    bge t2, t3, SET_DIRECTION_0

    SET_DIRECTION_1: # Se nao cair no 0, seta como 1
        li t2, 1
        sh t2, 4(t0)
        j AFTER_SAVE_DIRECTION

    SET_DIRECTION_0:
        li t2, 0
        sh t2, 4(t0)

    AFTER_SAVE_DIRECTION:

    END_RALPH_MOVE: 
	    jalr t1, s7, 0

RALPH_ANIMATION:
    la t2, ralph_data
    lh a1, 0(t2)           # x do ralph
    lh a2, 2(t2)          # y do ralph
    mv a3, s0          # a3 = frame atual (0 ou 1)
    la t0, ralph_animation_data
    lh a4, 4(t0)

    lh t1, 10(t0)
    li t3, 0
    beq t1, t3, ATTACK_ANIMATION

    # Se nao cair no attack animation:
    WALK_ANIMATION:    
        lh t1, 6(t0)
        addi t1, t1, 1
        sh t1, 6(t0)
        li t4, 5
        blt t1, t4, AFTER_CHANGE_RALPH_SPRITE

        li t1, 0
        sh t1, 6(t0)
        
        lh t1, 8(t0)
        li t4, 1
        beq t4, t1, SET_IMAGE_0
        SET_IMAGE_1:
            sh t4, 8(t0)
            j AFTER_CHANGE_RALPH_SPRITE
        SET_IMAGE_0:
            li t4, 0
            sh t4, 8(t0)

        AFTER_CHANGE_RALPH_SPRITE:

        li t1, 0
        lh t4, 8(t0)
        beq t1, t4, LOAD_RALPH_WALK_2

        LOAD_RALPH_WALK_1:
            la a0, RalphWalk1  # Carrega o endereco da imagem do ralph
            j AFTER_LOAD_RALPH_WALK
        LOAD_RALPH_WALK_2:
            la a0, RalphWalk2  # Carrega o endereco da imagem do ralph
        AFTER_LOAD_RALPH_WALK:

        lh t1, 2(t0) # X alvo da animacao
        beq t1, a1, END_RALPH_ANIMATION

        bge a1, t1, SUB_X
        SUM_X:  
            addi t0, a1, 3 # t0 = novo x
            bge t0, t1, END_RALPH_ANIMATION # Se passar do ponto alvo, acaba a animacao
            j AFTER_CALC_NEW_X

        SUB_X:
            addi t0, a1, -3 # t0 = novo x
            ble t0, t1, END_RALPH_ANIMATION # Se passar do ponto alvo, acaba a animacao
            j AFTER_CALC_NEW_X

        AFTER_CALC_NEW_X:
        sh t0, 0(t2)
        call PRINT
        jalr t1, s7, 0

    ATTACK_ANIMATION:
        lh t1, 6(t0)
        addi t1, t1, 1
        sh t1, 6(t0)
        li t4, 5
        beq t1, t4, CHANGE_RALPH_ATTACK_SPRITE
        li t4, 10
        beq t1, t4, CHANGE_RALPH_ATTACK_SPRITE
        li t4, 15
        beq t1, t4, CHANGE_RALPH_ATTACK_SPRITE 
        li t4, 16
        beq t1, t4, CALL_CREATE_BRICK 
        li t4, 20
        beq t1, t4, CHANGE_RALPH_ATTACK_SPRITE
        li t4, 25
        beq t1, t4, CHANGE_RALPH_ATTACK_SPRITE
        li t4, 30
        beq t1, t4, END_RALPH_ATTACK

        j AFTER_CHANGE_RALPH_ATTACK_SPRITE

        CALL_CREATE_BRICK:
            lh a0, 0(t2)
            call CREATE_BRICK
            
        j AFTER_CHANGE_RALPH_ATTACK_SPRITE
        
        CHANGE_RALPH_ATTACK_SPRITE:
            sh t1, 6(t0)
            lh t1, 8(t0)
            li t4, 1
            beq t4, t1, SET_IMAGE_0_ATTACK
            SET_IMAGE_1_ATTACK:
                sh t4, 8(t0)
                j AFTER_CHANGE_RALPH_ATTACK_SPRITE
            SET_IMAGE_0_ATTACK:
                li t4, 0
                sh t4, 8(t0)

        AFTER_CHANGE_RALPH_ATTACK_SPRITE:

        li t1, 0
        lh t4, 8(t0)
        beq t1, t4, LOAD_RALPH_ATTACK_2

        LOAD_RALPH_ATTACK_1:
            la a0, RalphAttack1  # Carrega o endereco da imagem do ralph
            j AFTER_LOAD_RALPH_ATTACK
        LOAD_RALPH_ATTACK_2:
            la a0, RalphAttack2  # Carrega o endereco da imagem do ralph
        AFTER_LOAD_RALPH_ATTACK:
        addi a1, a1, -10
        call PRINT
	    jalr t1, s7, 0

    END_RALPH_ATTACK:
        la t0, ralph_animation_data
        li t2, 0
        sh t2, 0(t0) # Salva animacao como 0
        li t2, 1
        sh t2, 10(t0) # Salva animacao como 0

        la t2, ralph_animation_delay
        li a7, 30
        ecall 
        sw a0, 0(t2)

	    jalr t1, s7, 0


    END_RALPH_ANIMATION:
        la t0, ralph_animation_data
        li t2, 0
        sh t2, 0(t0) # Salva animacao como 0
        li t2, 0
        sh t2, 10(t0) # Salva animacao como 0

        la t2, ralph_animation_delay
        li a7, 30
        ecall 
        sw a0, 0(t2)

        la t2, ralph_data
        sh t1, 0(t2)
	    jalr t1, s7, 0

CREATE_BRICK:
    la t0, bricks
    lh t1, 0(t0) 
    li t2, -1 # cont
    addi t0, t0, -2
    FIND_SLOT_TO_BRICK: beq t1, t2, RET_WITHOUT_CREATE_BRICK
        addi t2, t2, 1
        addi t0, t0, 4
        lh t3, 0(t0) # t3 = x da janela
        bnez t3, FIND_SLOT_TO_BRICK
        lh t3, 2(t0) # t3 = y da janela
        bnez t3, FIND_SLOT_TO_BRICK
    AFTER_FIND_SLOT_TO_BRICK:
        la t6, windows
        addi t6, t6, -8
        SEARCH_REAL_WINDOW:
            addi t6, t6, 8
            lh t4, 0(t6) # X da janela atual
            la t5, ralph_data
            lh t5, 0(t5) # x do ralph
            sub t5, t4, t5 # x da janela - x do ralph
            li a6, 18
            bgeu t5, a6, SEARCH_REAL_WINDOW

        sh t4, 0(t0) # x do novo tijolo
        li t5, 10
        sh t5, 2(t0) # y do novo tijolo

    RET_WITHOUT_CREATE_BRICK:
        ret

PRINT_AND_MOVE_BRICKS:  
    la s11, bricks
    # lh t1, 0(s11) 
    li t1, 4 # Remover esta linha
    li s10, 0 # cont
    addi s11, s11, -2
    NEXT_BRICK: 
        beq t1, s10, END_OF_BRICKS
        addi s10, s10, 1
        addi s11, s11, 4
        lh t3, 0(s11) # t3 = x da janela
        beqz t3, NEXT_BRICK
        lh t3, 2(s11) # t3 = y da janela
        beqz t3, NEXT_BRICK
        
        lh t5, 0(s11)# x do tijolo
        lh t6, 2(s11)# y do tijolo

        addi t6, t6, 2
        li t0, 240
        ble t6, t0, PRINT_BRICK
        DELETE_BRICK:
            li t0, 0
            sh t0, 0(s11)
            sh t0, 2(s11)
            j NEXT_BRICK

        PRINT_BRICK: 
        sh t6, 2(s11)
        la a0, tijolos
        mv a1, t5
        mv a2, t6
        mv a3, s0
        li a4, 0

        call PRINT
        j NEXT_BRICK

    END_OF_BRICKS:
        jalr t1, s7, 0

TEST_BRICK_COLISION_WITH_CHAR:
    la t4, char_data
    lh t4, 0(t4) # x do felix

    la t0, bricks
    lh t1, 0(t0) 
    li t2, -1 # cont
    addi t0, t0, -2
    FIND_BRICK_IN_THE_SAME_COLUMN: beq t1, t2, END_TEST_BRICK_COLISION
        addi t2, t2, 1
        addi t0, t0, 4
        lh t3, 0(t0) # t3 = x da janela
        bne t3, t4, FIND_BRICK_IN_THE_SAME_COLUMN


    lh t1, 2(t0) # y do tijolo
    addi t1, t1, 20 # y do tijolo + altura dele (y da parte de baixo do tijolo)
    la t4, char_data
    lh t4, 2(t4) # y do personagem
    blt t1, t4, END_TEST_BRICK_COLISION # Se a parte de baixo do tijolo estiver mais alta que o personagem, nao tem colisao
    

    addi t4, t4, 20 # y do personagem + altura do personagem (y da parte de baixo do personagem)
    lh t1, 2(t0) # y do tijolo
    bgt t1, t4, END_TEST_BRICK_COLISION

    li t2, 0
    sh t2, 0(t0)
    sh t2, 2(t0)
    call DIMINUI_VIDAS

    
    END_TEST_BRICK_COLISION:

    jalr t1, s7, 0

PRINT_GAMEOVER:
	la a0, vidas0
	MACRO_PRINT_LIFES
	la a0,gameover
	MACRO_PRINT_GAMEOVER_VITORIA
	li a0, 5000
	call SLEEP
	call FIM_DO_JOGO

SLEEP:
    # Funcao de delay
    li a7, 32
    ecall
    ret

FIM_DO_JOGO:
    li a7,10
    ecall

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

jalr t1, s7, 0
 ret
ATINGIU_2600:
    # Mudar FASES para 2
    la t0, FASES             # Carrega o endereço de FASES
    li t2, 2                 # Carrega o valor 2 (fase 2)
    sb t2, 0(t0)             # Armazena 2 em FASES
    
     la a0,vitoriafase1
	MACRO_PRINT_GAMEOVER_VITORIA
	li a0, 1500
	call SLEEP
    jalr t1, s7, 0           # Continua o fluxo normal
    ret
    
renderDigit:
la s5, nums
li s1, 128		
mul s1, s1, a0		
add s1, s1, s5	 
li s2, tela	
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



.include "musica.s" 

FIMZAO:
li a7,10
ecall
