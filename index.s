# Registradores globais (Nao pode usar)
# s0=Frame atual
# s7=Ponteiro para retorno em algumas funcoes (Para onde o programa deve voltar depois da chamada)
.data
   			   
    .include "datas/game.data"

	.include "assets/felix/idle/felixidle.data"
	.include "assets/felix/idle/felixjumple.data"
	.include "assets/felix/idle/felixfix.data"
	.include "assets/felix/fix/fix1.data"
	.include "assets/felix/fix/fix2.data"
	.include "assets/sounds/music.data"
    .include "assets/background.data"
    .include "assets/backgroundFase2.data"
    .include "assets/backgroundFase3.data"
    
    .include "assets/NovoBackgroundFase1.data"
    .include "assets/NovoBackgroundFase2.data"
    .include "assets/fase2Consertado.data"
    

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
    .include "assets/ralph/scream/RalphScream1.data"
    .include "assets/ralph/scream/RalphScream2.data"
    .include "assets/ralph/RalphClimb.data"
    .include "assets/nums.data"
    .include "assets/vitoriafase1.data"
    .include "assets/cabecaoDoLamar.data"
    .include "assets/torta.data"


    .include "assets/duck/duck1.data"
    .include "assets/duck/duck2.data"

    .include "assets/vidas/0vidas.data"
    .include "assets/gameover.data"
    .include "assets/black.data"

    .include "assets/stage.data"
    .include "assets/score.data"

    .include "datas/dados_torta.data"
    .include "datas/bricks.data"
    .include "datas/janelas.data"
    .include "datas/ralph.data"
    .include "datas/efeitos_sonoros.data"
    .include "datas/cutscenes.data"
                     #Tem pato, x, y, contador de frames
    DUCKS_DATA: .half 0,        0, 0, 0
    DUCKS_Y: .half 194, 134, 74
    DUCK_DELAY: .word 0

.text

.include "src/macros.s"

GAME_LOOP:
    jal s7, TOCAR_EFEITOS_SONOROS

    # Configuracao do FPS do jogo (30 fps)
    li a0, 27
    call SLEEP  # A funcao sleep faz o sistema "dormir" pela quantidade de milissegundos definido em a0

    la t0, CUTSCENE_DATA
    lh t1, 0(t0)
    bnez t1, CUTSCENE

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
    
    la t0, FASES
    lb t1, 0(t0)
    li t2, 2
    beq t1, t2, LOAD_BACKGROUND_FASE2
    # Desenhar o background
    LOAD_BACKGROUND_FASE1:
        la a0, background  # Carrega o endereco do background
        j POS_LOAD_BACKGROUND
    LOAD_BACKGROUND_FASE2:
        la a0, backgroundFase2  # Carrega o endereco do background
    POS_LOAD_BACKGROUND:
    li a1, 0           # x do background
    li a2, 0           # y do background
    mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4, 0
    call PRINT

    jal a6, PRINT_JANELAS

    la a0, stage
    li a1, 256           # x do background
    li a2, 1           # y do background
    mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4, 0
    call PRINT

    la a0, score
    li a1, 10           # x do background
    li a2, 0           # y do background
    mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4, 0
    call PRINT

    la t0, FASES
    lb t1, 0(t0)
    li t2, 2
    bne t1, t2, DEPOIS_TORTA # Caso nao esteja na fase 2
    la t0, tem_torta
    lb t1, 0(t0)
    li t2, 1
    beq t1, t2, PRINT_TORTA # Se tem torta
    lb t1, 1(t0)
    li t2, 0
    beq t1, t2, CALL_CRIAR_TORTA # Se ainda nao teve torta
    # Se nao tem torta mas ja teve
    j DEPOIS_TORTA
    PRINT_TORTA:
        la t2, torta_pos
        lh a1, 0(t2)
        addi a1, a1, -4
        lh a2, 2(t2)
        addi a2, a2, 14
        la a0, torta
        mv a3, s0
        call PRINT
        addi a1, a1, 4
        addi a2, a2, -14
        la t0, char_data
        lh t1, 0(t0)
        bne t1, a1, DEPOIS_TORTA
        lh t1, 2(t0)
        bne t1, a2, DEPOIS_TORTA
        call LIDAR_COLISAO_TORTA
        j DEPOIS_TORTA
    CALL_CRIAR_TORTA:
        call CRIAR_TORTA
    DEPOIS_TORTA:

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
    lh t1, 8(t0) # se esta concertando
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


    la t0, invencivel_torta
    lb t1, 0(t0)
    beqz t1, DEPOIS_PRINTAR_CABECA_INVENCIVEL

    la a0, cabecaoDoLamar
    la t0, char_data
    lh a1, 0(t0) # x
    lh a2, 2(t0)    
    addi a1, a1, -5
    addi a2, a2, -10
    mv a3, s0          # a3 = frame atual (0 ou 1)
    lh t2, 4(t0)
    xori a4, t2, 1

    la t0, char_data    # t0 = endereco do personagem (x, y)
    lh t1, 8(t0) # se esta concertando

    beqz t1, IMPRIMIR_CABECA
    addi a1, a1, -3
    bnez a4, IMPRIMIR_CABECA
    addi a1, a1, 6

    IMPRIMIR_CABECA:       
    call PRINT
    
    call TESTAR_FIM_INVENCIBILIDADE
    DEPOIS_PRINTAR_CABECA_INVENCIVEL:


    la t0, FASES
    lb t1, 0(t0)
    li t2, 2
    beq t1, t2, CALL_DUCK_CONTROLLER
    j POS_CALL_DUCK_CONTROLLER
    CALL_DUCK_CONTROLLER:
        jal s7, DUCK_CONTROLLER
    POS_CALL_DUCK_CONTROLLER: 

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
    li a4, 15	
    jal s7, PRINTAR_PONTUACAO

    call KEY2  # Reconhece as teclas pressionadas
    
    j GAME_LOOP

 ##########################################
DIMINUI_VIDAS:
    la t0, invencivel_torta
    lb t1, 0(t0)
    bnez t1, RETORNO_DIMINUI_VIDAS
    la t0, VIDAS       # Carrega o endereÃ§o da variÃ¡vel VIDAS
    lb t1, 0(t0)       # Carrega o valor de VIDAS
    beqz t1, FIM       # Se VIDAS jÃ¡ for 0, nÃ£o decrementar
    addi t1, t1, -1    # Decrementa VIDAS
    sb t1, 0(t0)       # Atualiza VIDAS na memÃ³ria
    # jal PRINTAR_VIDAS  # Atualiza o HUD de vidas
    RETORNO_DIMINUI_VIDAS:
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
	beq t1, t2, PRINT_VIDA1 # se t1 = 1 , mostra 1 vida
	beq t1, t3, PRINT_VIDA2 # se t1 = 2 , mostra 2 vida
	beq t1, t4, PRINT_VIDA3 # se t1 = 3 , mostra 3 vida
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

.include "musica.s" 

PHASE_BYPASS:
    la t0, Pontos
    lh t3, 0(t0)
    li t1, 2700
    bgt t3, t1, BY_PASS_FASE_2# ja ta na fase 2
    beq t3, t1, BY_PASS_FASE_2# ja ta na fase 2
    li t1, 2600
    sh t1, 0(t0)
    ret
    BY_PASS_FASE_2:
        li t1, 5700
        sh t1, 0(t0)
        ret

FIMZAO:
li a7,10
ecall

.include "src/key2.s"
.include "src/char_controller.s"
.include "src/printar_pontuacao.s"
.include "src/bricks_controller.s"
.include "src/ralph_controller.s"
.include "src/print.s"
.include "src/windows_controller.s"
.include "src/efeitos_sonoros.s"
.include "src/phase_transition.s"
.include "src/duck_controller.s"
.include "src/torta_controller.s"