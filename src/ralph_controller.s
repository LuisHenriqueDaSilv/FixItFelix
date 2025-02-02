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

        mv s8, s7 
        la t0, RALPH_SOUND
        jal s7, START_SOUND
        mv s7, s8 
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