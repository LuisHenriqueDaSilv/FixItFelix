PRINT:
    # a0 = endereco da imagem
    # a1 = x
    # a2 = y
    # a3 = frame
    # a4 = sentido da imagem
    # Desenha a imagem

    li t0, 0xFF0
    add t0, t0, a3      # Endereco do frame atual (0 ou 1)
    slli t0, t0, 20     # Move 20 bits a esquerda
    li t1, 320          # Largura da tela
    mul t1, t1, a2      # Largura da linha da imagem
    add t0, t0, t1      # Endereco da linha de imagem
    add t0, t0, a1      # Posicao exata para desenhar a imagem
    addi t1, a0, 8      # Pula as duas primeiras palavras (info da imagem)


    # Desenha linha por linha da imagem
    mv t2, zero         # Contador de linhas
    mv t3, zero         # Contador de colunas
    lw t4, 0(a0)        # Largura da imagem
    lw t5, 4(a0)        # Altura da imagem

    LOOP_IGNORA_LINHA:
        # li t6, 0  
        bge a2, zero, POS_IGNORA_LINHA
        addi t0, t0, 320 # Pula uma linha no endereco da tela
        add t1, t1, t4
        addi t5, t5 -1
        
        addi a2, a2, 1
        # li a7, 10
        # ecall 
        j LOOP_IGNORA_LINHA
    POS_IGNORA_LINHA:

    beqz a4, PRINT_LINE
    bnez a4, PRINT_INVERTED_LINE
    ret

    # Fun??o para desenhar a linha da imagem
    PRINT_LINE:
        lw t6, 0(t1)  # L? uma palavra da imagem
        sw t6, 0(t0)  # Escreve no bitmap
        addi t0, t0, 4
        addi t1, t1, 4
        addi t3, t3, 4
        blt t3, t4, PRINT_LINE  # Se n?o chegou ao fim da linha, continua
        addi t0, t0, 320         # Vai para a pr?xima linha
        sub t0, t0, t4           # Ajusta para o in?cio da pr?xima linha
        mv t3, zero
        addi t2, t2, 1
        bgt t5, t2, PRINT_LINE
        ret

    PRINT_INVERTED_LINE:
        add t1, t1, t4  # Vai para o final da linha
        INVERTED_PRINT_LOOP:
            lb t6, 0(t1)
            sb t6, 0(t0)
            addi t0, t0, 1
            addi t1, t1, -1
            addi t3, t3, 1
            blt t3, t4, INVERTED_PRINT_LOOP
            addi t0, t0, 320
            sub t0, t0, t4
            add t1, t1, t4
            mv t3, zero
            addi t2, t2, 1
            bgt t5, t2, PRINT_INVERTED_LINE
    ret