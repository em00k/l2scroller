
InitCopper
		ld 		bc, .copperend-.copper
		ld 		hl, .copper
		jp 		StartCopper	
.copper
		db 		COPPER_WAIT_H, 32,  LAYER2_XOFFSET_MSB_NR_71,0
x_scroll:
		db 		COPPER_WAIT_H, 64, LAYER2_XOFFSET_MSB_NR_71,0

		dw 		$ffff
.copperend