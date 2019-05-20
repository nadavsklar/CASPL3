; -----------------------------------------------------
; Description: 
; Date: 20.5.2019
; Change Log:
; -----------------------------------------------------

section	.rodata			; we define (global) read-only variables in .rodata section

section .data           ; we define (global) initialized variables in .data section

section .bss			; we define (global) uninitialized variables in .bss section

section .text
global runTarget
global getTargetLocation

runTarget:
    ret

getTargetLocation:
    ret

createTarget:
    ret

mayDestroy:
    ret