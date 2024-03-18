; scroller routines 

init_scroller: 

        ld      hl,scroller_text-1                      ; set to refresh char on first call
        ld      (txt_position),hl
        ld      hl,char_count                           ; check for new char 
        ld      (hl),1
        ret

update_scroller:

        nextreg $50, 30                                 ; page in font 
        ld      hl,char_count                           ; update pixel count
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

loop_msg:

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
        ld      a, (char_count)                         ; which slice of the letter are we printing
        neg                                             ; char_count counts down 8>0, we need 0-8
        add     a, 8                                    ; 
        add     a, l                                    ; add as an offset into the buffer
        ld      l, a                                    ; put back into L
        
        ld      e, 255                                  ; x position to draw pixel line 
        ld      d, 0
        
        call    get_xy_pos_l2                           ; DE = yx, get position and L2 page in
        ld      b, 7                                    ; loop 7 times

vertical_copy:
        ld      a, (hl)                                 ; 7 copy one bye
        ld      (de), a                                 ; 7 
        ld      a, 8                                    ; 7
        add     hl, a                                   ; 8
        inc     d                                       ; 4 this is for 256x192 +h +256 
        djnz    vertical_copy

        ret 

    
txt_position:           dw 0
char_count:             db 0
glyph_slice:            db 0 
current_glyph:          dw 0
xpos:                   dw 0 
tempcahar:
                        ds      64,0

scroller_text: 

        db      "HELLO ZX SPECTRUM NEXT FANS "
        db      "HELLO ZX SPECTRUM NEXT FANS ",00



scroll_l2_dma:

        nextreg MMU0_0000_NR_50,18
        ld      hl, 1
        ld      de, 0
        ld      bc, 7*256
        call    TransferDMA
        ret 