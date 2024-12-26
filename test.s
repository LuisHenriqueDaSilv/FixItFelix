    .data
msg_no_button: .asciiz "Nenhum botao pressionado\n"
msg_button:     .asciiz "Botao pressionado: "
newline:        .asciiz "\n"

    .text
    .globl main

main:
main_loop:
    # Ler o estado dos bot�es no endere�o MMIO (0x10008000)
    li t0, 0xFF200000       # Endere�o do MMIO (substitua pelo correto)
    lw t1, 0(t0)            # Carrega o estado dos bot�es em t1

    # Verificar se algum bot�o est� pressionado
    beqz t1, no_button      # Se t1 == 0, nenhum bot�o pressionado

    # Determinar qual bot�o est� pressionado
    mv t2, t1               # Copiar o valor lido para t2
    li t3, 0                # �ndice inicial do bot�o (t3)

find_button:
    andi t4, t2, 1          # Extrair o bit menos significativo (estado do bot�o atual)
    bnez t4, button_found   # Se t4 != 0, bot�o pressionado encontrado
    srli t2, t2, 1          # Deslocar t2 para a direita (pr�ximo bit)
    addi t3, t3, 1          # Incrementar o �ndice do bot�o
    bnez t2, find_button    # Continuar enquanto t2 != 0

button_found:
    # Exibir mensagem "Bot�o pressionado: "
    la a0, msg_button       # Carregar mensagem base
    li a7, 4                # syscall para print_string
    ecall

    # Exibir o �ndice do bot�o pressionado
    mv a0, t3               # Colocar �ndice do bot�o em a0
    li a7, 1                # syscall para print_int
    ecall

    # Nova linha
    la a0, newline          # Carregar nova linha
    li a7, 4                # syscall para print_string
    ecall

    j main_loop             # Voltar ao loop principal

no_button:
    # Exibir mensagem de nenhum bot�o pressionado
    la a0, msg_no_button    # Carregar mensagem "Nenhum bot�o pressionado"
    li a7, 4                # syscall para print_string
    ecall

    j main_loop             # Voltar ao loop principal
