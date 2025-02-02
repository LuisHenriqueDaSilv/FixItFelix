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