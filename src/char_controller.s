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

    li t1, 1
    la t0, FELIX_WALK_SOUND
    sw t1, 0(t0) 
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
    
    li t1, 1
    la t0, FELIX_WALK_SOUND
    sw t1, 0(t0) 
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
    
    li t1, 1
    la t0, FELIX_WALK_SOUND
    sw t1, 0(t0) 
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
    
    li t1, 1
    la t0, FELIX_WALK_SOUND
    sw t1, 0(t0) 
    ret 
    
FIX:

    la t0, char_data    # t0 = endereco do personagem (x, y)
    li t1, 1
    li s9, 0
    sh t1, 8(t0)
    la t0, FIX_SOUND
    jal s7, START_SOUND
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
        li t6, 2
        beq t6, t1, POS_SOMA_JANELA
        addi t1, t1, 1
        sh t1, 6(a0)

        la t4, Pontos
        lh t5, 0(t4)
        addi t5, t5, 100
        sh t5, 0(t4) 

        POS_SOMA_JANELA:
        jalr t0, a6, 0