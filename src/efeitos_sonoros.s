TOCAR_EFEITOS_SONOROS:
    la t0, BACKGROUND_SOUND
    lh t1, 0(t0)
    li t2, 1
    beq t1, t2, TOCAR_BACKGROUND
    POS_TOCAR_BACKGROUND:
        la t0, FIX_SOUND
        lh t1, 0(t0)
        beq t1, t2, TOCAR_FIX_SOUND
    POS_TOCAR_FIX:
        la t0, RALPH_SOUND
        lh t1, 0(t0)
        beq t1, t2, TOCAR_RALPH_SOUND
    POS_TOCAR_RALPH:
        la t0, WIN_SOUND
        lh t1, 0(t0)
        beq t1, t2, TOCAR_WIN_SOUND
    POS_TOCAR_WIN_SOUND:
    #     la t0, FELIX_WALK_SOUND
    #     lh t1, 0(t0)
    #     # beq t1, t2, TOCAR_WALK_FELIX_SOUND
    POS_TOCAR_FELIX_WALK:
    j POS_SONS
    TOCAR_BACKGROUND:
        la a4, BACKGROUND_SOUND
        la a5, TAMANHO_MUSICA_DE_FUNDO
        la a6, NOTAS_MUSICA_DE_FUNDO
        call TOCA_MUSICA
        j POS_TOCAR_BACKGROUND
    TOCAR_FIX_SOUND:
        la a4, FIX_SOUND
        la a5, TAMANHO_FIX_SOUND
        la a6, NOTAS_FIX_SOUND
        call TEST_END_SOUND
        call TOCA_MUSICA
        j POS_TOCAR_FIX
    TOCAR_RALPH_SOUND:
        la a4, RALPH_SOUND
        la a5, TAMANHO_RALPH_SOUND
        la a6, NOTAS_RALPH_SOUND
        call TEST_END_SOUND
        call TOCA_MUSICA
        j POS_TOCAR_RALPH
    TOCAR_WALK_FELIX_SOUND:
        la a4, FELIX_WALK_SOUND
        la a5, TAMANHO_FELIX_WALK_SOUND
        la a6, NOTAS_FELIX_WALK_SOUND
        call TEST_END_SOUND
        call TOCA_MUSICA
        j POS_TOCAR_FELIX_WALK
    TOCAR_WIN_SOUND:
        la a4, WIN_SOUND
        la a5, TAMANHO_WIN_SOUND
        la a6, NOTAS_WIN_SOUND
        call TEST_END_SOUND
        call TOCA_MUSICA
        j POS_TOCAR_WIN_SOUND
    POS_SONS:
    jalr t1, s7, 0


START_SOUND:
    li t1, 1
    sw t1, 0(t0)
    sw zero, 4(t0)
    sw zero, 8(t0) 
    sw zero, 12(t0) 
	jalr t1, s7, 0

TEST_END_SOUND:
    lw t0, 4(a4)
    lw t1, 0(a5)
    beq t0, t1, END_SOUND
    ret
    END_SOUND:
        sw zero, 0(a4)
        sw zero, 4(a4)
        sw zero, 8(a4) 
        sw zero, 12(a4) 
    ret