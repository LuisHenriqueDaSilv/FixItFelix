# Código RISC-V para desenhar uma imagem no bitmap do RARS

    .data
# Define as cores RGB (0xRRGGBB)
    red: .word 0xFF0000  # Vermelho
    green: .word 0x00FF00  # Verde
    blue: .word 0x0000FF  # Azul
    black: .word 0x000000  # Preto

    .text
    .globl main

main:
    # Ativa o bitmap
    li a7, 0x10           # Syscall para ativar o bitmap
    li a0, 1              # 1 para ativar
    ecall

    # Configuração do quadrado
    li t0, 50             # X inicial
    li t1, 50             # Y inicial
    li t2, 100            # Tamanho do quadrado

    # Cor do quadrado
    la t3, red            # Endereço da cor vermelha
    lw t4, 0(t3)          # Carrega o valor da cor vermelha em t4

    # Desenha o quadrado
draw_square:
    mv t5, t0             # Inicializa x
row_loop:
    mv t6, t1             # Inicializa y
column_loop:
    li a7, 0x11           # Syscall para desenhar pixel
    mv a0, t5             # X
    mv a1, t6             # Y
    mv a2, t4             # Cor
    ecall

    addi t6, t6, 1        # Próximo pixel na coluna
    add t1, t1, t2
    blt t6, t1, column_loop # Continua até o fim da coluna

    addi t5, t5, 1        # Próximo pixel na linha
    add t0, t0, t2
    blt t5, t0, row_loop    # Continua até o fim da linha

    # Loop infinito para manter o bitmap visível
infinite_loop:
    j infinite_loop
