
;------------------------------------------------------------------------------
; Utils 

getRegister:

; IN A > Register to read 
; OUT A < Value of Register 
    
        push    bc
        ld      bc, TBBLUE_REGISTER_SELECT_P_243B
        out     (c), a 
        inc     b 
        in      a, (c) 
        pop     bc 
        ret 

; Vsync wait 

wait_vblank:	
        ld      hl, 1
.readline:	
        ld      a,VIDEO_LINE_LSB_NR_1F
        ld      bc,TBBLUE_REGISTER_SELECT_P_243B
        out     (c),a
        inc 	b
        in      a,(c)
        cp      192								; line to wait for 250
        jr      nz,.readline
        ;dec 	hl 
        ;ld 		a,h
        ;or 		l 
        ;jr 		nz,.readline 
        ret 