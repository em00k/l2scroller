;------------------------------------------------------------------------------
; copper settings

COPPER_WAIT				= %10000000

init_copper:
        ld      bc, .copperend-.copper
        ld      hl, .copper
        jp      start_copper	
.copper
        db      COPPER_WAIT, 0,  LAYER2_XOFFSET_NR_16 ,0
 ;       db      COPPER_WAIT, 1,  TRANSPARENCY_FALLBACK_COL_NR_4A ,55
 ;       db      COPPER_WAIT, 5,  TRANSPARENCY_FALLBACK_COL_NR_4A ,155
        db      COPPER_WAIT, 192-8,  LAYER2_XOFFSET_NR_16 ,0
.layer2_xoffset:

        db      COPPER_WAIT, 192, LAYER2_XOFFSET_NR_16,0

        dw      $ffff
.copperend