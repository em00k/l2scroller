;------------------------------------------------------------------------------
; copper routines

start_copper:
		; hl = copper list
		; bc = length

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

stop_copper:
		nextreg COPPER_CONTROL_HI_NR_62, 0	; stop
		nextreg COPPER_CONTROL_LO_NR_61, 0
		ret

update_copper:
        
		
		ld		a, (init_copper.layer2_xoffset-1)
		inc     a   
		
		ld      (init_copper.layer2_xoffset-1),a

		call    init_copper
		ret 
.xpos: 
        db      0

