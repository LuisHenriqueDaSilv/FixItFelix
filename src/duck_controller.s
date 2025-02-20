DUCK_CONTROLLER:
    la t0, DUCKS_DATA
    lh t1, 0(t0) # t1 = tem pato
    beqz t1, CREATE_DUCK
    j PRINT_AND_MOVE_DUCK
    END_DUCK_CONTROLLER:
	jalr t1, s7, 0


CREATE_DUCK:
    li a7, 30
    ecall
    la t4, DUCK_DELAY
    lw t0, 0(t4) # Ms do fim do ultimo pato
    sub t1, a0, t0
    li t2, 2000
    bltu t1, t2, END_DUCK_CONTROLLER

    li a0, 0
    li a1, 3
    li a7, 42
    ecall # a0 = numero aleatorio entre 0 e 2
    la t0, DUCKS_Y
    li t2, 2
    mul t2, t2, a0
    add t0, t0, t2 # t0 = endereco do y que o passaro vai ser criado
    lh t1, 0(t0) # y que o passaro vai ser criado

    la t0, DUCKS_DATA
    li t2, 1
    sh t2, 0(t0)
    sh t1, 4(t0)
    li t2, 300
    sh t2, 2(t0)
    j END_DUCK_CONTROLLER

PRINT_AND_MOVE_DUCK:
    la t0, DUCKS_DATA
    lh a1, 2(t0) # x 
    lh a2, 4(t0) # y
    lh t1, 6(t0) # contador de frames
    addi t1, t1, 1
    sh t1, 6(t0)

    la t2, char_data
    lh t3, 0(t2)
    blt a1, t3, DEPOIS_TESTAR_COLISAO
    addi t3, t3, 10
    bgt a1, t3, DEPOIS_TESTAR_COLISAO
    lh t3, 2(t2)
    blt a2, t3, DEPOIS_TESTAR_COLISAO
    addi t3, t3, 32
    bgt a2, t3, DEPOIS_TESTAR_COLISAO

    call DIMINUI_VIDAS

    j DELETE_DUCK

    DEPOIS_TESTAR_COLISAO:
    addi a1, a1, -2
    sh a1, 2(t0)
    li t4, -20
    blt a1, t4, DELETE_DUCK

    li t4, 5
    blt t1, t4, LOAD_DUCK_1
    li t4, 10
    blt t1, t4, LOAD_DUCK_2
    sh zero, 6(t0)
    LOAD_DUCK_1:
        la a0, duck1
        j AFTER_LOAD_DUCK
    LOAD_DUCK_2:
        la a0, duck2
    AFTER_LOAD_DUCK:
    li a4, 1
    mv a3, s0
    call PRINT

    li t2, 30
    bgt a1, t2, NAO_PRINTA_FUNDO
    la a0, black
    li a1, 259
    li a2, 0
    mv a3, s0
    li a4, 0
    call PRINT

    la a0, stage
    li a1, 256           # x do background
    li a2, 1           # y do background
    mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4, 0
    call PRINT
    
    NAO_PRINTA_FUNDO:

    j END_DUCK_CONTROLLER

DELETE_DUCK:
    li t0, DUCKS_DATA
    li t2, 0
    sh t2, 0(t0)

    li a7, 30
    ecall
    la t4, DUCK_DELAY
    sw a0, 0(t4) # Ms do fim do ultimo pato
    
    j END_DUCK_CONTROLLER