;------------------------------------------------------------------------------
; scroller routines

init_scroller: 
        
        ; initialises the scroller 
        
        ld      hl,scroller_text-1                      ; set to refresh char on first call
        ld      (txt_position),hl
        ld      hl,glyph_slice                          ; check for new char 
        ld      (hl),1
        ret

update_scroller:
        
        ; updates the scroller 

        nextreg $50, 30                                 ; page in font 
        ld      hl,glyph_slice                          ; update pixel count
        dec     (hl)
        jr      nz,scroll_text

new_char:
        ld      (hl),8                                  ; reset pixel count
        ld      hl,(txt_position)                       ; update current character
        inc     hl
        ld      (txt_position),hl
        ld      a,(hl)                                  ; check for loop token
        or      a
        jr      nz,get_new_glyp                

        ld      hl,scroller_text                        ; loop if necessary
        ld      (txt_position),hl

get_new_glyp:
        ld      a,(hl)                                  ; collect char as ASCII
        sub     32
        ld      e, a                                    ; char * 64bytes per tile
        ld      d, 64
        mul     d, e 
        ld      (current_glyph),de                      ; points to correct letter in font

        ex      de, hl                                  ; put letter into hl for source
        ld      de, tempcahar                           ; point de to a temp buffer
        ld      bc, 63                                  ; size to copy 
        ldir  
        

scroll_text: 

        ld      hl, tempcahar                           ; point to buffer
        ld      a, (glyph_slice)                        ; which slice of the letter are we printing
        neg                                             ; glyph_slice counts down 8>0, we need 0-8
        add     a, 8                                    ; 
        add     a, l                                    ; add a as an offset into the buffer
        ld      l, a                                    ; put back into L
                                                        
        ld      d,192-8
        ld      a, (init_copper.layer2_xoffset-1)       ; we need to move x+1 with each line draw
        ld      e, a
        call    get_xy_pos_l2                           ; DE = yx, get position and L2 page in
        ld      b, 8                                    ; loop 8 times

vertical_copy:
        ld      a, (hl)                                 ; 7 copy one bye
        ld      (de), a                                 ; 7 
        ld      a, 8                                    ; 7
        add     hl, a                                   ; 8
        inc     d                                       ; 4 this is for 256x192 +h +256 
        djnz    vertical_copy

        ret 

    
txt_position:           dw 0
glyph_slice:            db 0 
current_glyph:          dw 0
xpos:                   dw 0 
tempcahar:
                        ds      64,0

scroller_text: 

        db      "HELLO ZX SPECTRUM NEXT FANS "
        db      "Here we have your classic text scroller in its simplest form. "
        db      "  We are using the copper to slide a horizontal slice of screen"
        db      "  while at the same time printing text in slices along the way."
        db      "  Anyway that's enough of that!      >>>>>  ",00


