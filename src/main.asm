        SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
        DEVICE ZXSPECTRUMNEXT
        CSPECTMAP "l2scroller.map"

;------------------------------------------------------------------------------
; Layer2 SCROLLER v2 - Scroller on Layer2 via COPPER & DMA copy
; em00k 17.03.24

        org  $8000

;------------------------------------------------------------------------------
; Includes

        include "hardware.inc"                          ; hardare equates and ports

;------------------------------------------------------------------------------
; Main Program 

main:
        
        call    setup_hardware                          ; set up hardware registers 
        ld      a, 0 
        call    clsL2                                   ; clear layer2 with 0/black

        ; blit some test patterns 
        ; 
        ld      de, $0000                               ; de = yx position on screen 
        ld      ix, test_logo_128                       ; ix points to source table
        call    straight_plot                           ; draw using straight plot
         
        ld      de, $00c0                               ; something different
        ld      ix, parrot_64        
        call    straight_plot

        ld      de, $0080                               ; and so on 
        ld      ix, test_logo_64 
        call    straight_plot

        ld      de, $8000                               ; some more 
        ld      ix, test_logo_64 
        call    straight_plot

        ld      de, $80c0                               ; last one 
        ld      ix, test_logo_64 
        call    straight_plot

        call    init_copper                             ; initialise the copper 
        call    init_scroller                           ; initialise the scroller

scroll_loop: 

        
        ld a,2 : out     ($fe), a                       ; colour bar to monitor performance 
        call    update_scroller                         ; update the scroller
        ld a,7 : out     ($fe), a   
        call    update_copper                           ; update the copper code 
        ld a,0 : out     ($fe), a 
        call    wait_vblank  
                                   ; wait for vblank
        
        jp      scroll_loop                             ; repeatsville


;------------------------------------------------------------------------------
; Routines

setup_hardware:
        nextreg TURBO_CONTROL_NR_07,3                   ; 28 mhz because 
        nextreg TRANSPARENCY_FALLBACK_COL_NR_4A,0       ; transparency black 
        xor     a : out     ($fe), a                    ; black border 

        ret   

;------------------------------------------------------------------------------
; Includes

        include "layer2.asm"
        include "scroller.asm"
        include "utils.asm"
        include "copper.asm"
        include "dma.asm"
        include "tables.asm"
        include "copper_settings.asm"

;------------------------------------------------------------------------------
; Stack reservation
STACK_SIZE      equ     100

stack_bottom:
        defs    STACK_SIZE * 2
stack_top:
        defw    0

;------------------------------------------------------------------------------
; Banked includes

        org     $e000
        mmu     7 n, 30 
        incbin  "data/font.nxt"                         ; 256 colour font 

        org     $e000
        mmu     7 n, 32
        incbin  "data/emk1.snk"                         ; snake format
        incbin  "data/ZXNEXT_64x64.snk"                        

        org     $e000
        mmu     7 n, 33
        incbin  "data/emk1.raw"                         ; em00k logo
        incbin  "data/ZXNEXT_64x64.raw"                 ; test pattern 64x6x
        org     $e000                      

        mmu     7 n, 34
        incbin  "data/ZXNEXT_128x128.raw"               ; test pattern 128x128
        org     $e000     

        mmu     7 n, 36
        incbin  "data/ZX NEXT_256x192.raw"              ; test pattern 256x192 

        mmu     7 n, 37
        incbin  "data/RGB_s.raw"                        ; squawk! 
              

;------------------------------------------------------------------------------
; Output configuration

        SAVENEX OPEN "l2scroller.nex", main, stack_top 
        SAVENEX CORE 2,0,0
        SAVENEX CFG 7,0,0,0
        SAVENEX AUTO 
        SAVENEX CLOSE