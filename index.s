.data
	char_pos: .half 160, 0
	.include "assets/felix/idle/felixidle.data"
	.include "assets/background.data"
	.include "assets/colisionmap.data"

.text 

GAME_LOOP:
	# Configurando o FPS do jogo:
		# FPS = Frame per seconds
		# 1 segundo -> 30fps
		# 1000ms -> 30fps
		# 1000/30 ~= 33 entre cada frame
		li a0, 33 
		call SLEEP # A função sleep faz o sistema dormir pela quantidade de ms salvo no a0

	# Funções de comportamentos gerais do jogo:
		call GRAVITY # Faz o player cair caso ele nao esteja no chão
		call KEY2 # Reconhece as teclas pressionadas
		
	# A cada execucao da gameloop o sistema vai:
	# Desenhar um dos frames
	# Mostrar frame que foi desenhado anteriormente

	# Isso faz a alternancia entre os frames: 
		# Se o frame atual (s0) for igual a 1, fazer um xor (Ou exclusivo) dele com 1 retorna 0
		# Se for 0, retorna 1
		# Resumindo, fica trocando entre 0 e 1
	xori s0, s0, 1

	# Desenhar o background:
	la a0, background # Carrega o endereço do label background
	li a1, 0 # x do background
	li a2, 0 # y do background
	mv a3, s0 # a3 = frame atual(0 ou 1)
	call PRINT
	
	# Desenhar o personagem
	la t0, char_pos # t0 = endereco do label onde tá salvo o x e y do personagem
	la a0, felixidle # a = Endereço do label da imagem do personagem 
	lh a1, 0(t0) # a1 = x do personagem (Primeira half word)
	lh a2, 2(t0) # a2 = y do personagem (Segunda half word)
	mv a3, s0 # a3 = frame atual(0 ou 1)
	call PRINT

	# Trocar o frame que tá sendo mostrado agora:
	li t0, 0xFF200604 # Endereço onde fica salvo o indice do frame que tá sendo mostrado agora
	sw s0, 0(t0) # Salva o frame atual no endereço de cima 
	
	j GAME_LOOP

KEY2: 
	#Isso aqui ainda não tá funcionando direito
	# (Ainda não sei por que não funciona, muito menos como fazer funcionar kkkkk [Alguém lembra de tirar esse comentário depois]) 
	li t1, 0xFF200000
	lw t0, 0(t1)
	andi t0, t0, 0x0001
	beq t0, zero, FIM
	lw t2, 4(t1)
	
	li t0,'a' 
	beq t2, t0, CHAR_MOVE_LEFT # Se a tecla pressionada for 'a' o personagem move pra esquerda 
	li t0,'d'
	beq t2, t0, CHAR_MOVE_RIGHT # Se a tecla pressionada for 'd' o personagem move pra direita
	ret # Volta pra onde a funcao foi chamada
	
	
FIM: ret

GRAVITY:
	la t0, char_pos
	lh t1, 0(t0) # t1 = x do personagem
	lh t2, 2(t0) # t2 = y do personagem
	la t0, colisionmap
	la t4, felixidle
	lw t5, 4(t4) # altura do personagem
	add t3, t2, t5  # t3 = y do personagem + altura do personagem
	li t2, 320 # t1 = largura da tela
	mul t0, t2, t3 # t0 = larguradatela*(ydopersonagem +alturadopersonagem)
	add t0, t0, t1 # t0 = t0 + xdopersonagem
	la t1, colisionmap
	add t0, t0, t1 # t0 = Endereco do pixel abaixo do personagem no mapa de colisao
	lbu t1, 0(t0) # Valor do pixel em t0 (lbu = load byte unsigned)

	# Lugares onde tem colisao, no mapa de colisao eh igual a zero
	# Se t1 for diferente de zero, nao tem colisao e o personagem cai  
	bnez t1, FALL # bnez = Branch if not equal zero
	ret

	FALL:
		la t0, char_pos 
		lh t1, 2(t0) # y do personagem
		addi t1, t1, 2 # ydopersonagem = ydopersonagem +2 (Vai 2 pixels pra baixo)
		sh t1, 2(t0) # Salva o novo y do personagem
		ret

CHAR_MOVE_LEFT: 
	la t0, char_pos # t0 = endereco do label onde tá salvo o x e y do personagem
	
	lh t1, 0(t0)	# t1 = x do personagem
	lh t2, 2(t0)	# t2 = y do personagem

    la t3, colisionmap        # t3 aponta para o inicio do mapa de colisoes
    li t4, 320                # t4 = largura do mapa de colisao (em pixels)
    mul t5, t2, t4            # t5 = deslocamento da linha (y * largura)
    add t5, t5, t1            # t5 = indice do pixel atual no mapa de colisao
	addi t5, t5, 6

	add t3, t3, t5            # t3 = endereco do pixel a esquerda no mapa de colisao		
	lbu t6, 0(t3)              # t6 = valor do pixel a esquerda no mapa de colisao
	li t4, 0 # 0 eh o valor de onde tem colisao no mapa de colisoes

 	# Se o pixel a esquerda for diferente de 0, nao tem colisao com nenhuma parede
	# E o proximo teste e se o player esta no limite da tela
	bne t6, t4, TEST_IF_COLLIDE_WITH_LEFT_SCREEN_LIMIT
	# bne = Branch if not equal
	ret

	TEST_IF_COLLIDE_WITH_LEFT_SCREEN_LIMIT:
		bgtz t1, CHAR_MOVE_L # if(t2(x do personagem) > 0){CHAR_MOVE_L}
		ret
	CHAR_MOVE_L:
		addi t1, t1, -4 # t1 = x do personagem - 4 pixels (Anda 4 pixels para esquerda)
		sh t1, 0(t0) # Salva o novo x do personagem
		ret
	
CHAR_MOVE_RIGHT: 
	
	la t0, char_pos # t0 = endereco do label onde tá salvo o x e y do personagem
	
	lh t1, 0(t0)	# t1 = x do personagem
	lh t2, 2(t0)	# t2 = y do personagem

    la t3, colisionmap        # t3 aponta para o inicio do mapa de colisoes
    li t4, 320                # t4 = largura do mapa de colisao (em pixels)
    mul t5, t2, t4            # t5 = deslocamento da linha (y * largura)
    add t5, t5, t1            # t5 = indice do pixel atual no mapa de colisao
	
    addi t5, t5, 24            # t5 = indice do pixel a direita no mapa de colisoes

	add t3, t3, t5            # t3 = endereco do pixel a direita
	lbu t6, 0(t3)              # t6 = valor do pixel a direita no mapa de colisao

 	# Se o pixel a direita for diferente de 0, nao tem colisao com nenhuma parede
	# E o proximo teste e se o player esta no limite da tela
	li t4, 0
	bne t6, t4 TEST_IF_COLLIDE_WITH_RIGHT_SCREEN_LIMIT
	ret

	TEST_IF_COLLIDE_WITH_RIGHT_SCREEN_LIMIT:
		addi t5,zero, 300 # t5 = 300 (Limite da tela na direita)
		ble t1, t5, CHAR_MOVE_R # Se t1 (x do personagem) for menor que o limite, anda
		ret

	CHAR_MOVE_R:
		addi t1, t1, 4 # t1 = x do personagem + 4 (Anda 4 pixels para direita)
		sh t1, 0(t0)
		ret				



PRINT: 
	# Entradas:
	#	a0 = endereco imagem			
	#	a1 = x da imagem	
	#	a2 = y da imagem
	#	a3 = frame atual (0 ou 1)	

	li t0, 0xFF0
	add t0, t0, a3 # t0 = t0 + frameAtual(0 ou 1)
	# A soma acima vai resultar em 0xFF0 ou 0xFF1, dependendo do frameAtual
	# O endereco dos frames no bitmap sao 0xFF000000 ou 0xFF100000
	# Para transformar o resultado da soma no endereco desejado, jogamos o resultado 20 bits para a direita 
	# Que é o mesmo que adicionar 5 zeros no final
	slli t0, t0, 20
	
	li t1, 320 # t1 = largura da tela
	mul t1, t1, a2 # t1 = t1* yDeOndeAImagemComeca

	add t0, t0, t1 # t0 = EnderecoBaseDoBitmap(t0) + enderecoDaLinhaOndeAImagemComeca(t1)
	add t0, t0, a1 # t0 = EnderendoDaLinhaOndeAImagemComeca(t0) + xDeOndeAImagemComeca(a1)
	addi t1, a0, 8 # Pula as duas words no comeco do arquivo da imagem (Cada word tem 4 bytes)
	
	# t2 = contador que vai contar qual linha da imagem ta sendo desenhado
	# t3 = contador que vai contar qual coluna da imagem ta sendo desenhado
	mv t2, zero  # Inicia t2 como zero
	mv t3, zero # Inicia t3 como zero
	lw t4, 0(a0) # t4 = largura da imagem (Primeira word do arquivo da imagem)
	lw t5, 4(a0) # t5 = altura da imagem (Primeira word do arquivo da imagem)

	# Como nao tem um ret aqui, o label PRINT_LINE eh executado sem ser chamado
	PRINT_LINE: 
		lw t6, 0(t1) # Le uma word da imagem (4 bytes de uma vez)
		sw t6, 0(t0) # Escreve a word lida no bitmap
		
		addi t0, t0, 4 # Anda 4 bytes no endereco do bitmap (Os 4 bytes que ja foram desenhados) 
		addi t1, t1, 4 # Anda 4 bytes no endereco da imagem (Os 4 bytes que ja foram desenhados)
		addi t3, t3, 4 # Adiciona 4 bytes no contador de colunas desenhadas
		
		# Se o contador de colunas for menor que a largura da imagem
		# Volta la pro inicio da PRINT_LINE (Desenhando mais 4 bytes na mesma linha atual)  
		blt t3, t4, PRINT_LINE  

		# Quando o contador maior que a largura, devemos passar para a proxima linha
		
		addi t0, t0, 320 # Soma a largura da tela no endereco do bitmap (Joga exatamente uma linha pra baixo)
		# A soma anterior resulta em onde vai ser o final da linha de baixo, para voltar para o comeco
		# subtraimos a largura da imagem do resultado
		sub t0, t0, t4  
		
		mv t3, zero # Zera o contador de colunas
		addi t2, t2, 1	# Soma 1 no contador de linhas
		bgt t5, t2, PRINT_LINE # Se o contador de linhas for menor que a altura da imagem, tem mais linhas pra desenhar, entao volta la para o inicio  
		
		ret 


SLEEP:
	# Entradas:
	# 	a0 = tempo de sleep em milisegundos
	li a7, 32
	ecall
    ret