        SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
        DEVICE ZXSPECTRUMNEXT
        CSPECTMAP "l2scroller.map"

;------------------------------------------------------------------------------
; Layer2 SCROLLER v1 - Scroller via DMA copy on Layer2
; em00k 17.03.24

        org  $8000

;------------------------------------------------------------------------------
; Includes

        include "hardware.inc"                          ; hardare equates and ports

;------------------------------------------------------------------------------
; Main Program 

main:
        
        call    setup_hardware                          ; set up
        ld      a, 0 
        call    clsL2

        ld      de, $3050 
        ld      ix, snake_emk_logo 
        call    snake_plot
        ld      de, $6050 
        ld      ix, snake_emk_logo 
        call    snake_plot


        call    init_scroller                           ; initialise the scroller

scroll_loop: 
        ld a,2 : out     ($fe), a 
        call    scroll_l2_dma                           ; copies 8x256 pixels of L2 with the DMA
        ld a,3 : out     ($fe), a 
        call    update_scroller                         ; update the scroller
        ld a,7 : out     ($fe), a         
        ld      de, $6050 
        ld      ix, snake_emk_logo 
        call    snake_plot
        ld a,0 : out     ($fe), a 
        call    wait_vblank                             ; wait for vblank
        ld a,0 : out     ($fe), a 
        jp      scroll_loop                             ; repeatsville


snake_emk_logo:
        ;       bank wdith height 
        ;       offset 
        db      32, 96, 32>>1
        dw      0

;------------------------------------------------------------------------------
; Routines

setup_hardware:
        nextreg TURBO_CONTROL_NR_07,3                   ; 28 mhz because 
        nextreg TRANSPARENCY_FALLBACK_COL_NR_4A,0       
        ;nextreg ULA_CONTROL_NR_68,1<<7                  ; turn off ULA 
        xor     a : out     ($fe), a                    ; black border 

        ret   

;------------------------------------------------------------------------------
; Includes

        include "layer2.asm"
        include "scroller.asm"
        include "utils.asm"
        include "copper.asm"
        include "dma.asm"
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
        incbin  "data/font.nxt"                          ; 256 colour font

        org     $e000
        mmu     7 n, 18 
        incbin  "data/zxnext.bmp", 1078                  ; background 
        
        org     $e000
        mmu     7 n, 31 
        incbin  "data/back64pb.snk"                        ; background 

        org     $e000
        mmu     7 n, 32
        incbin  "data/emk1.snk"                        ; background 

;------------------------------------------------------------------------------
; Output configuration

        SAVENEX OPEN "l2scroller.nex", main, stack_top 
        SAVENEX CORE 2,0,0
        SAVENEX CFG 7,0,0,0
        SAVENEX AUTO 
        SAVENEX CLOSE