.macro PRINT_FELIX
    la t0, char_data    # t0 = endereco do personagem (x, y)
    lh a1, 0(t0)       # a1 = x do personagem
    lh a2, 2(t0)       # a2 = y do personagem
    # li a2, -10       # a2 = y do personagem
    lh a4, 4(t0)       # a4 = direcao do personagem
    mv a3, s0          # a3 = frame atual (0 ou 1)
    call PRINT
.end_macro

.macro PRINT_RALPH 
    la t2, ralph_data
    lh a1, 0(t2)           # x do ralph
    lh a2, 2(t2)          # y do ralph
    mv a3, s0          # a3 = frame atual (0 ou 1)
    call PRINT
.end_macro

.macro PRINT_TWO_BACKGROUND
    # a5 = y do segundo background 
    # a6 = y do primeiro background 
    la a0, BackgroundLamar  # Carrega o endereco do background
    li a1, 0           # x do background
    addi a2, a5, 0           # y do background
    mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4, 0
    call PRINT

    la a0, background  # Carrega o endereco do background
    li a1, 0           # x do background
    addi a2, a6, 0           # y do background
    mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4, 0
    call PRINT
.end_macro

.macro PRINT_BACKGROUND
    la a0, background  # Carrega o endereco do background
    li a1, 0           # x do background
    li a2, 0          # y do background
    mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4, 0
    call PRINT
.end_macro

.macro PRINT_BACKGROUND_PHASE_2
    la a0, BackgroundLamar  # Carrega o endereco do background
    li a1, 0           # x do background
    li a2, 0          # y do background
    mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4, 0
    call PRINT
.end_macro

START_PHASE_TRANSITION:
    la t0,CUTSCENE_DATA
    li t1, 1
    sh t1, 0(t0)
    la t0, FASES             # Carrega o endereço de FASES
    li t2, 2                 # Carrega o valor 2 (fase 2)
    sb t2, 0(t0)             # Armazena 2 em FASES
    ret

CUTSCENE:
    li t0, 0xFF200604  # Endereco onde o indice do frame eh armazenado
    sw s0, 0(t0)       # Salva o frame atual no endereco acima
    xori s0, s0, 1

    la t0, CUTSCENE_DATA
    lh t2, 2(t0)
    li t1, 0
    beq t1, t2, SCENE1
    li t1, 1
    beq t1, t2, SCENE2
    li t1, 2
    beq t1, t2, SCENE3
    li t1, 3
    beq t1, t2, SCENE4
    j GAME_LOOP

SCENE1:
    la t0, WIN_SOUND
    li t1, 1
    sw t1, 0(t0) 
    la t0, BACKGROUND_SOUND
    sw zero, 0(t0) 


    PRINT_BACKGROUND
    la a0, felixidle
    PRINT_FELIX

    la t0, CUTSCENE_DATA
    lh t1, 4(t0) # Frame counter
    addi t1, t1, 1
    sh t1, 4(t0)

    li t2, 7
    blt t1, t2, LOAD_RALPH_SCREAM_1
    li t2, 14
    blt t1, t2, LOAD_RALPH_SCREAM_2
    li t2, 21
    blt t1, t2, LOAD_RALPH_SCREAM_1
    li t2, 28
    blt t1, t2, LOAD_RALPH_SCREAM_2
    li t2, 35
    blt t1, t2, LOAD_RALPH_SCREAM_1
    li t2, 42
    blt t1, t2, LOAD_RALPH_SCREAM_2
    li t2, 49
    blt t1, t2, LOAD_RALPH_SCREAM_1
    li t2, 56
    blt t1, t2, LOAD_RALPH_SCREAM_2
    li t2, 63
    blt t1, t2, LOAD_RALPH_SCREAM_1
    li t2, 70
    blt t1, t2, LOAD_RALPH_SCREAM_2
    li t2, 77
    blt t1, t2, LOAD_RALPH_SCREAM_1
    li t2, 84
    blt t1, t2, LOAD_RALPH_SCREAM_2
    li t2, 91
    blt t1, t2, LOAD_RALPH_SCREAM_1
    li t2, 98
    blt t1, t2, LOAD_RALPH_SCREAM_2
    la a0, RalphScream2

    la t0, CUTSCENE_DATA
    lh t2, 2(t0)
    addi t2, t2, 1
    sh t2, 2(t0)
    sh zero, 4(t0)

    j POS_LOAD_RALPH
    LOAD_RALPH_SCREAM_1:
        la a0, RalphScream1
        j POS_LOAD_RALPH    
    LOAD_RALPH_SCREAM_2:
        la a0, RalphScream2
        j POS_LOAD_RALPH

    POS_LOAD_RALPH:
    li a4, 0
    PRINT_RALPH

	la a0,vitoriafase1
    MACRO_PRINT_GAMEOVER_VITORIA

    j GAME_LOOP

SCENE2:
    PRINT_BACKGROUND

    la t0, CUTSCENE_DATA
    lh t1, 4(t0) # Frame counter
    addi t1, t1, 1
    sh t1, 4(t0)

    li t2, 5
    blt t1, t2, INVERT_RALPH_CLIMB
    li t2, 10
    blt t1, t2, DONT_INVERT_RALPH_CLIMB
    li t2, 15
    blt t1, t2, INVERT_RALPH_CLIMB
    li t2, 20
    blt t1, t2, DONT_INVERT_RALPH_CLIMB
    li t2, 25
    blt t1, t2, INVERT_RALPH_CLIMB
    li t2, 30
    blt t1, t2, DONT_INVERT_RALPH_CLIMB
    li t2, 35
    blt t1, t2, INVERT_RALPH_CLIMB
    li t2, 40
    blt t1, t2, DONT_INVERT_RALPH_CLIMB

    la t0, CUTSCENE_DATA
    lh t2, 2(t0)
    addi t2, t2, 1
    sh t2, 2(t0)
    sh zero, 4(t0)

    INVERT_RALPH_CLIMB:
        li a4, 1
        j POS_INVERT_RALPH_CLIMB
    DONT_INVERT_RALPH_CLIMB:
        # li a7, 10 
        # ecall
        li a4, 0
        j POS_INVERT_RALPH_CLIMB
    POS_INVERT_RALPH_CLIMB:

    la t2, ralph_data
    lh a2, 2(t2)          # y do ralph
    addi a2, a2, -3
    sh a2, 2(t2)

    la a0, RalphClimb
    PRINT_RALPH
    la a0, felixidle
    PRINT_FELIX
    j GAME_LOOP

SCENE3:
# li a7, 10 
# ecall
    la t0, PHASE_BACKGROUND_TRANSITION
    lh t1, 0(t0)
    addi t1, t1, 2
    sh t1, 0(t0)
    mv a6, t1

    lh t1, 2(t0)
    addi t1, t1, 2
    sh t1, 2(t0)
    mv a5, t1
    PRINT_TWO_BACKGROUND
    beqz a5, END_SCENE3 
    j GAME_LOOP

    END_SCENE3:
        la t0, CUTSCENE_DATA
        lh t2, 2(t0)
        addi t2, t2, 1
        sh t2, 2(t0)
        sh zero, 4(t0)
        j GAME_LOOP

SCENE4:
    PRINT_BACKGROUND_PHASE_2
    j GAME_LOOP