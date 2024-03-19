clsL2:
	; Clears L2 320x256 with A as colour 
	; IN A > colour 
	; USES : hl, de, bc, a 	
	 
		ld		(.colour+1), a 
		ld		a, $12 				; $12 is L2 RAM start bank register 
		call	getRegister 		; get L2 ram bank in a 
		add		a, a                ; A = start of L2 ram, we need to *2 
		ld		b, 5                ; 3 blocks to do 

.L2loop:
		push	bc 					; save loop counter 

		nextreg	MMU0_0000_NR_50, a  ; set 0 - $1fff 
		inc		a 
		nextreg	MMU1_2000_NR_51, a  ; set 0 - $1fff 
		inc		a 

		ld		hl, 0 				; start at address 0 
		ld		de, 1 
.colour: 
		ld		(hl), 20            ; smc colour from above 
		ld		bc, $3fff			; bytes to clear 
		ldir 
		pop		bc 					; bring back loop counter 
		djnz	.L2loop 			; repeat until b = 0 
		
		; restore ROMS 

		nextreg	MMU0_0000_NR_50, $ff 
		nextreg	MMU1_2000_NR_51, $ff 

		; clear ULA 
		ld		hl, 16384
		ld		de, 16385
		ld		bc, 6912
		ld		(hl), 0 
		ldir 

		ret     


LAYER2_ACCESS_PORT 	EQU $123B

plot_l2:  ; (byVal X as ubyte, byval Y as ubyte, byval T as ubyte)
    ; hl = XY , a colour 

        ld		bc,LAYER2_ACCESS_PORT
        push	af      								; save colour 
        ld		a,h     								; put y into A 
        and		$c0     								; yy00 0000

        or		3       								; yy00 0011
        out		(c),a   								; select 8k-bank    
        ld		a,h     								; yyyy yyyy
        and		63      								; 00yy yyyy	
        ld		h,a
        pop		af      								; pop back colour
        ld		(hl),a									; set pixel value

        ld		a,2     								; 0000 0010
        out		(c),a   								; Layer2 writes off 
        ret 


set_coords:

        pop     hl : call set_xy: jp (hl)
set_xy: ld      a,(hl)       ; X   
        ld      (L2_coords), a
        inc     hl 
        ld      a,(hl)       ; Y
        ld      (L2_coords+1), a
        inc     hl 
        ld      a,(hl)       ; C 
        ld      (L2_coords+2), a
        ret     

     
L2Line:  ; (byVal Y as ubyte, byval W as ubyte, byval A as ubyte)
        ; XY from coords, a = width 

        push    af 
		ld   	bc,LAYER2_ACCESS_PORT
        ld      hl, (L2_coords)
		ld   	a,h     ; put y into A 
		and  	$c0     ; yy00 0000

		or   	3       ; yy00 0011
		out  	(c),a   ; select 8k-bank    
		ld   	a,h     ; yyyy yyyy
		and  	63      ; 00yy yyyy	
		ld   	h,a
        pop     bc 
        ld      c, 32
.lineloop2 
        ld      b, 32
        ld      l, 0 
.lineloop: 
        ;push    bc 
		ld      a, (L2_coords+2)      ; get colour/map value off stack 
		ld  	(hl),a   ; set pixel value
        inc     l 
        ld      a, b 
        or      a 
        jr      nz,.lineloop 
        inc     h 
        dec     c 
        ld      a, c 
        or      a 
        jr      nz,.lineloop2

		ld   	a,2     ; 0000 0010
        ld   	bc,LAYER2_ACCESS_PORT
		out  	(c),a   ; Layer2 writes off 

        ret 

L2_coords:      ;  X  Y  C 
        DB      0 , 0 , 0 


get_xy_pos_l2:
; input d = y, e = x
; uses de a bc 
        push    bc 
        ld   	bc,LAYER2_ACCESS_PORT
        ld   	a,d     ; put y into A 
        and  	$c0     ; yy00 0000

        or   	3       ; yy00 0011
        out  	(c),a   ; select 8k-bank    
        ld   	a,d     ; yyyy yyyy
        and  	63      ; 00yy yyyy	
        ld   	d,a
        pop     bc 
        ret

get_xy_pos_l2_hl:
; input h = y, l = x
; uses hl a bc 
        ld   	bc,LAYER2_ACCESS_PORT
        ld   	a,h     ; put y into A 
        and  	$c0     ; yy00 0000

        or   	3       ; yy00 0011
        out  	(c),a   ; select 8k-bank    
        ld   	a,h     ; yyyy yyyy
        and  	63      ; 00yy yyyy	
        ld   	h,a
        ret

; snake draw L2 

snake_plot:

; de = xy, ix = snake_data

        ld      a,(ix+0)
        nextreg $50, a

        call    get_xy_pos_l2
        ; hl now position an mapped in 
        ld      l, (ix+3)
        ld      h, (ix+4) 
        inc     hl 
        inc     hl 
        ;ex      de, hl                      ; hl now snake_data, de = destination on l2
        ld      a, (ix+2)                   ; height 
.line1: ld      c, (ix+1)                   ; width 
        ld      b, 0
        ldir 
        inc     d                           ; next line down 
        ld      c, a 
        call    .check_line
        ld      b, (ix+1)                   ; width 
.line2: dec     e 
        inc     hl 
        ld      a, (hl)
        ld      (de), a  
        djnz    .line2   
        inc     d
        call    .check_line     
        ld      a, c 
        dec     a
        jr      nz, .line1
        ld      bc, LAYER2_ACCESS_PORT
        ld      a, 2 
        out     (c), a 
        ret 

.check_line:

        ld      a, d 
        cp      $40
        call    z, get_xy_pos_l2
        cp      $80
        call    z, 1F
        ret 
1:      call    get_xy_pos_l2
        ret

straight_plot:
; de = yx, ix = source_data
        ; break
        ld      a, (ix+0)
        nextreg $50, a
        inc     a
        nextreg $51, a 
        ld      l, (ix+3)       ; source 
        ld      h, (ix+4)
        inc hl
        inc hl
        ld      b, (ix+2)       ; height
        ld      (.add1+1), de   ; save address 
.add1:
        ld      de, 0000
.line1:  
        call    get_xy_pos_l2
        push    bc
        ld      b, 0 
        ld      c,(ix+1)        ; width
        ldir 
        ld      a, h 
        cp      $40
        call    z,.nextbanks
        pop     bc 
        ld      de, (.add1+1)
        inc     d
        ld      (.add1+1), de 
        dec     b
        jr      nz, .line1
        ld      bc, LAYER2_ACCESS_PORT
        ld      a, 2 
        out     (c), a 
        ret 
.nextbanks
        ld      a, (ix+0)
        add     a, a
        add     a, a
        nextreg $50, a
        inc     a
        nextreg $51,a 
        ld      a, h 
        and     127
        ld      a, h 
        
        ret