###########################################################
.macro MACRO_PRINT_LEVEL 
	li a1, 304
	li a2, 1
	mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4,0
	call PRINT
.end_macro

.macro MACRO_PRINT_GAMEOVER_VITORIA
	li a1, 40
	li a2, 66
	mv a3, s0          # a3 = frame atual (0 ou 1)
    	li a4,0
	call PRINT
.end_macro

###########################################################
.macro MACRO_PRINT_LIFES 
    li a1, 1
	li a2, 26
	mv a3, s0          # a3 = frame atual (0 ou 1)
    li a4,0
	call PRINT
.end_macro