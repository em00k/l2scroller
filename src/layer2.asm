;------------------------------------------------------------------------------
; layer2 routines

clsL2:
	; Clears L2 320x256 with A as colour 
	; IN A > colour 
	; USES : hl, de, bc, a 	
	 
        ld	(.colour+1), a 
        ld	a, $12                                  ; $12 is L2 RAM start bank register 
        call	getRegister                             ; get L2 ram bank in a 
        add	a, a                                    ; A = start of L2 ram, we need to *2 
        ld	b, 5                                    ; 3 blocks to do 

.L2loop:
        push	bc 					; save loop counter 

        nextreg	MMU0_0000_NR_50, a                      ; set 0 - $1fff 
        inc	a 
        nextreg	MMU1_2000_NR_51, a                      ; set 0 - $1fff 
        inc	a 

        ld	hl, 0                                   ; start at address 0 
        ld	de, 1 
.colour: 
        ld	(hl), 20                                ; smc colour from above 
        ld	bc, $3fff                               ; bytes to clear 
        ldir 
        pop	bc                                      ; bring back loop counter 
        djnz	.L2loop                                 ; repeat until b = 0 
        
        ; restore ROMS 

        nextreg	MMU0_0000_NR_50, $ff 
        nextreg	MMU1_2000_NR_51, $ff 

        ; clear ULA 
        ld      hl, 16384
        ld	de, 16385
        ld	bc, 6912
        ld	(hl), 0 
        ldir 

        ret     


LAYER2_ACCESS_PORT 	EQU $123B

plot_l2:  ; (byVal X as ubyte, byval Y as ubyte, byval T as ubyte)
    ; hl = XY , a colour 

        ld	bc,LAYER2_ACCESS_PORT
        push	af      				; save colour 
        ld	a,h     				; put y into A 
        and	$c0     				; yy00 0
        or	3       				; yy00 0011
        out	(c),a   				; select 8k-bank    
        ld	a,h     				; yyyy yyyy
        and	63      				; 00yy yyyy	
        ld	h,a
        pop	af      				; pop back colour
        ld	(hl),a					; set pixel value

        ld	a,2     				; 0000 0010
        out	(c),a   				; Layer2 writes off 
        ret 


set_coords:
        ; sets co-ords
        ; call set_coords: db x,y 

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
        ld   	a,h             
        and  	$c0             

        or   	3               
        out  	(c),a     
        ld   	a,h     
        and  	63      
        ld   	h,a
        pop     bc 
        ld      c, 32
.lineloop2 
        ld      b, 32
        ld      l, 0 
.lineloop: 
        ;push    bc 
        ld      a, (L2_coords+2)                        ; get colour/map value off stack 
        ld  	(hl),a                                  ; set pixel value
        inc     l 
        ld      a, b 
        or      a 
        jr      nz,.lineloop 
        inc     h 
        dec     c 
        ld      a, c 
        or      a 
        jr      nz,.lineloop2

        ld   	a,2                                     ; 0000 0010
        ld   	bc,LAYER2_ACCESS_PORT
        out  	(c),a                                   ; Layer2 writes off 

        ret 

L2_coords:      ;  X  Y  C 
        DB      0 , 0 , 0 


get_xy_pos_l2:
        ; input d = y, e = x
        ; uses de a bc 
        push    bc 
        ld   	bc,LAYER2_ACCESS_PORT
        ld   	a,d                                     ; put y into A 
        and  	$c0                                     ; yy00 0000

        or   	3                                       ; yy00 0011
        out  	(c),a                                   ; select 8k-bank    
        ld   	a,d                                     ; yyyy yyyy
        and  	63                                      ; 00yy yyyy	
        ld   	d,a
        pop     bc 
        ret

get_xy_pos_l2_hl:
; input h = y, l = x
; uses hl a bc 
        ld   	bc,LAYER2_ACCESS_PORT
        ld   	a,h                                     ; put y into A 
        and  	$c0                                     ; yy00 0000

        or   	3                                       ; yy00 0011
        out  	(c),a                                   ; select 8k-bank    
        ld   	a,h                                     ; yyyy yyyy
        and  	63                                      ; 00yy yyyy	
        ld   	h,a
        ret

; snake draw L2 

snake_plot:
        ; draws a tile with snake formatted data 
        ; de = xy, ix = snake_data

        ld      a,(ix+0)
        nextreg $50, a

        call    get_xy_pos_l2
        ; hl now position an mapped in 
        ld      l, (ix+3)
        ld      h, (ix+4) 
        inc     hl 
        inc     hl 
        ;ex      de, hl                                 ; hl now snake_data, de = destination on l2
        ld      a, (ix+2)                               ; height 
.line1: ld      c, (ix+1)                               ; width 
        ld      b, 0
        ldir 
        inc     d                                       ; next line down 
        ld      c, a 
        call    .check_line
        ld      b, (ix+1)                               ; width 
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
        ; typwriter plots large tile
        ; de = yx, ix = source_data
        ; break
        ld      a, (ix+0)                               ; get the bank the source date is in from table
        nextreg $50, a                                  ; set slot 0
        inc     a                                       ; next bank 
        nextreg $51, a                                  ; set slot 1
        ld      l, (ix+3)                               ; source 
        ld      h, (ix+4)
        inc hl                                          ; add 2 because the first 2 bytes are WxH
        inc hl
        ld      b, (ix+2)                               ; height
        ld      (.add1+1), de                           ; save yx address 
.add1:
        ld      de, 0000                                ; will hold yx with self mod code
.line1:  
        call    get_xy_pos_l2                           ; get position and l2 bank in place
        push    bc                                      ; save bc / height 
        ld      b, 0                                    ; clear b 
        ld      c,(ix+1)                                ; width
        ldir                                            ; copy line 
        ld      a, h                                    ; did we pass 16kb?
        or      $80 | $40
        call    z,.nextbanks                            ; yes go to next bank 
        pop     bc                                      ; get back height
        ld      de, (.add1+1)                           ; get back yx 
        inc     d                                       ; inc y 
        ld      (.add1+1), de                           ; save yx again
        dec     b                                       ; decrease height 
        jr      nz, .line1                              ; was height 0? no then loop to line1
        ld      bc, LAYER2_ACCESS_PORT                  ; turn off layer 2 writes
        ld      a, 2 
        out     (c), a 
        ret 
.nextbanks
        ld      a, (ix+0)                               ; fetch bank 
        add     a, a                                    ; x2
        add     a, a
        nextreg $50, a                                  ; set new banks
        inc     a
        nextreg $51,a 
        ld      a, h                                    ; wrap h 
        and     127
        ld      a, h 
        ret