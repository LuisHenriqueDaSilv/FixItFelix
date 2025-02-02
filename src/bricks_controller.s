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