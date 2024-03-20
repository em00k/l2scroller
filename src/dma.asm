
;------------------------------------------------------------------------------
; DMA routines

;===========================================================================
; hl = source
; bc = length
; set port to write to with NEXTREG_REGISTER_SELECT_PORT
; prior to call
;===========================================================================
TransferDMAPort
        ld      (.dmaSource),hl
        ld      (.dmaLength),bc
        ld      hl,.dmaCode
        ld      b,.dmaCodeLen
        ld      c,Z80_DMA_PORT_DATAGEAR
        otir
        ret
;===========================================================================
;
;===========================================================================
.dmaCode	
        db      DMA_DISABLE
        db      %01111101				;R0-Transfer mode, A -> B, write adress + block length
.dmaSource			
        dw      0					;R0-Port A, Start address				(source address)
.dmaLength			
        dw 	0					;R0-Block length					(length in bytes)
        db 	%01010100				;R1-read A time byte, increment, to memory, bitmask
        db 	%00000010				;R1-Cycle length port A
        db 	%01101000				;R2-write B time byte, increment, to memory, bitmask
        db 	%00000010				;R2-Cycle length port B
        db 	%10101101 				;R4-Continuous mode  (use this for block tansfer), write dest adress
        dw 	$253b					;R4-Dest address					(destination address)
        db 	%10000010				;R5-Restart on end of block, RDY active LOW
        db 	DMA_LOAD				;R6-Load
        db 	DMA_ENABLE				;R6-Enable DMA
.dmaCodeLen	equ $-.dmaCode
