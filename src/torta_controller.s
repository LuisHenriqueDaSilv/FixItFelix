.text
CRIAR_TORTA:

    la t0, tempo_nao_torta
    lw t1, 0(t0)
    
    li a7, 30
    ecall # a0 = ms atual

    li t2, 10000 # Delay entre cada torta em ms
    sub t3, a0, t1
    bltu t3, t2, FIM_CRIAR_TORTA
    la t0, tem_torta
    li t1, 1
    sb t1, 0(t0)
    sb t1, 1(t0)

    FIM_CRIAR_TORTA:
        ret

LIDAR_COLISAO_TORTA:
    la t0, invencivel_torta
    li t1, 1
    sb t1, 0(t0)

    la t0, tem_torta
    sb zero, 0(t0)

    la t0, tempo_invencibilidade
    li a7, 30
    ecall
    sw a0, 0(t0)

    la t0, BACKGROUND_SOUND
    li t1, 0
    sw t1,0(t0)
    la t0, BACKGROUND_INVENCIVEL
    li t1, 1
    sw t1,0(t0)

    ret

TESTAR_FIM_INVENCIBILIDADE:
    la t0, tempo_invencibilidade
    lw t1, 0(t0)
    li a7, 30
    ecall # a0 = ms atual
    sub t2, a0, t1
    li t4, 15000
    bltu t2, t4, RETORNO_FIM_INVENCIBILIDADE
    la t0, invencivel_torta
    sb zero, 0(t0)

    la t0, BACKGROUND_SOUND
    li t1, 1
    sw t1,0(t0)
    la t0, BACKGROUND_INVENCIVEL
    li t1, 0
    sw t1,0(t0)
    RETORNO_FIM_INVENCIBILIDADE:
    ret