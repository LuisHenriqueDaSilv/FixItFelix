.data
   			   #(l: 1=esquerda ou 0=direita)
				   # 0   2  4       6
				   # x   y   l, aceleracaoY
	char_pos: .half 85, 194, 1, 		0
               
    mov_animation: .half 0, 0, 0, 0, 0 # Esta em animacao, chegou no pico y, x alvo, y alvo, caindo

	.include "assets/felix/idle/felixidle.data"
	.include "assets/felix/idle/felixjumple.data"
	.include "assets/background.data"

    # Defini��o das janelas (posi��o x, y)
    windows: 
        #     x    y
        .half 85 , 194   # janela 1
        .half 117, 194   # janela 2
        .half 155, 202   # porta
        .half 185, 194   # janela 4
        .half 216, 194   # janela 5

        .half 85, 134    # janela 6
        .half 117, 134   # janela 7
        .half 160, 138   # sacada
        .half 185, 134   # janela 9
        .half 216, 134   # janela 10

        .half 85, 74     # janela 11
        .half 117, 74    # janela 12
        .half 151, 74    # janela 13
        .half 185, 74    # janela 14
        .half 216, 74    # janela 15

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
    la a0, background  # Carrega o endere�o do background
    li a1, 0           # x do background
    li a2, 0           # y do background
    mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4, 0
    call PRINT

    # Desenhar o personagem
    la t0, char_pos    # t0 = endere�o do personagem (x, y)
    la t2, mov_animation
    lh t3, 0(t2)
    li t4, 1
    beq t3, t4, LOAD_JUMP
    LOAD_IDLE:
        la a0, felixidle
        j LOAD_THEN
    LOAD_JUMP:
        la a0, felixjumple   # a0 = endere�o da imagem do personagem
    LOAD_THEN:
    lh a1, 0(t0)       # a1 = x do personagem
    lh a2, 2(t0)       # a2 = y do personagem
    lh a4, 4(t0)       # a4 = direcao do personagem
    mv a3, s0          # a3 = frame atual (0 ou 1)
    call PRINT

    # Atualiza o frame mostrado
    li t0, 0xFF200604  # Endere�o onde o �ndice do frame � armazenado
    sw s0, 0(t0)       # Salva o frame atual no endere�o acima

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
    beq t0, zero, FIM  # Se a tecla n�o foi pressionada, vai para o fim
    lw t2, 4(t1)

    # Detectar teclas espec�ficas para movimenta��o
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
    lh t1, 4(t3) # Direção do personagem
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
    la t0, char_pos    # t0 = endere�o do personagem (x, y)
    lh t1, 0(t0)       # t1 = x do personagem
    lh t6, 2(t0)       # t6 = y do personagem
    li t2, 85 # x limite da ultima janela da esquerda
    ble t1, t2, FIM

    la t3, windows
    addi t3, t3, -4
    SEARCH_WINDOW:
        addi t3, t3, 4
        lh t4, 0(t3) # X da janela atual
        lh t5, 2(t3) # Y da janela atual
        bne t1, t4, SEARCH_WINDOW
        bne t6, t5, SEARCH_WINDOW
    
    addi t3, t3, -4 # Janela destino
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
    la t0, char_pos    # t0 = endere�o do personagem (x, y)
    lh t1, 0(t0)       # t1 = x do personagem
    lh t6, 2(t0)       # t6 = y do personagem
    li t2, 216 # x limite da ultima janela da esquerda
    bge t1, t2, FIM

    la t3, windows
    addi t3, t3, -4
    SEARCH_WINDOW:
        addi t3, t3, 4
        lh t4, 0(t3) # X da janela atual
        lh t5, 2(t3) # Y da janela atual
        bne t1, t4, SEARCH_WINDOW
        bne t6, t5, SEARCH_WINDOW
    
    addi t3, t3, 4 # Janela destino
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
    la t0, char_pos    # t0 = endere�o do personagem (x, y)
    lh t1, 0(t0)       # t1 = x do personagem
    lh t6, 2(t0)       # t6 = y do personagem
    li t2, 74 # y limite da ultima janela da esquerda
    ble t6, t2, FIM

    la t3, windows
    addi t3, t3, -4
    SEARCH_WINDOW:
        addi t3, t3, 4
        lh t4, 0(t3) # X da janela atual
        lh t5, 2(t3) # Y da janela atual
        bne t1, t4, SEARCH_WINDOW
        bne t6, t5, SEARCH_WINDOW

    addi t3, t3, 20 # Janela destino
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
    la t0, char_pos    # t0 = endere�o do personagem (x, y)
    lh t1, 0(t0)       # t1 = x do personagem
    lh t6, 2(t0)       # t6 = y do personagem
    li t2, 203 # y limite da porta
    bge t6, t2, FIM
    li t2, 194 # y limite da janela mais baixa
    bge t6, t2, FIM

    la t3, windows
    addi t3, t3, -4
    SEARCH_WINDOW:
        addi t3, t3, 4
        lh t4, 0(t3) # X da janela atual
        lh t5, 2(t3) # Y da janela atual
        bne t1, t4, SEARCH_WINDOW
        bne t6, t5, SEARCH_WINDOW

    addi t3, t3, -20 # Janela destino
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
    add t0, t0, a3      # Endere�o do frame atual (0 ou 1)
    slli t0, t0, 20     # Move 20 bits � esquerda
    li t1, 320          # Largura da tela
    mul t1, t1, a2      # Largura da linha da imagem
    add t0, t0, t1      # Endere�o da linha de imagem
    add t0, t0, a1      # Posi��o exata para desenhar a imagem
    addi t1, a0, 8      # Pula as duas primeiras palavras (info da imagem)

    # Desenha linha por linha da imagem
    mv t2, zero         # Contador de linhas
    mv t3, zero         # Contador de colunas
    lw t4, 0(a0)        # Largura da imagem
    lw t5, 4(a0)        # Altura da imagem

    beqz a4, PRINT_LINE
    bnez a4, PRINT_INVERTED_LINE
    ret

    # Fun��o para desenhar a linha da imagem
    PRINT_LINE:
        lw t6, 0(t1)  # L� uma palavra da imagem
        sw t6, 0(t0)  # Escreve no bitmap
        addi t0, t0, 4
        addi t1, t1, 4
        addi t3, t3, 4
        blt t3, t4, PRINT_LINE  # Se n�o chegou ao fim da linha, continua
        addi t0, t0, 320         # Vai para a pr�xima linha
        sub t0, t0, t4           # Ajusta para o in�cio da pr�xima linha
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

SLEEP:
    # Fun��o de delay
    li a7, 32
    ecall
    ret
