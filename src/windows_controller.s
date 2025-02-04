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
        beq t0, s2, SOMA
        li t0, 7
        beq t0, s2, SOMA
        li t0, 2
        beq t0, s2, SOMA

        j AFTER_SOMA
        SOMA:
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