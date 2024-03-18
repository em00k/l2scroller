COPPER_HORIZONTAL_OFFSET 	= 0
;===========================================================================
; hl = copper list
; bc = length
;===========================================================================
StartCopper
		nextreg COPPER_CONTROL_HI_NR_62, 0	; stop
		nextreg COPPER_CONTROL_LO_NR_61, 0

		push 	bc
		ld 		bc, TBBLUE_REGISTER_SELECT_P_243B
		ld 		a, COPPER_DATA_NR_60
		out 	(c),a
		pop 	bc	; select copper data port
		call 	TransferDMAPort

		nextreg COPPER_CONTROL_HI_NR_62, %11000000 ; start
		nextreg COPPER_CONTROL_LO_NR_61, %00000000
		ret
;===========================================================================
;
;===========================================================================
StopCopper
		nextreg COPPER_CONTROL_HI_NR_62, 0	; stop
		nextreg COPPER_CONTROL_LO_NR_61, 0
		ret
;===========================================================================
;
;===========================================================================
