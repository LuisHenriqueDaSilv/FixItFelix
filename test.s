.data   
	.include "assets/colisionmap.data"
	.include "assets/felix/idle/felixidle.data"

.text
    la a0, felixidle
    lw t0, 0(a0)
