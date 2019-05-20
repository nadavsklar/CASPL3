; -----------------------------------------------------
; Description: 
; Date: 20.5.2019
; Change Log:
; -----------------------------------------------------

section	.rodata			; we define (global) read-only variables in .rodata section
    droneSize: dd 20

section .data           ; we define (global) initialized variables in .data section

section .bss			; we define (global) uninitialized variables in .bss section
    struc drone                 ; we define drone structure
        x: resd 1               ; x coordinate
        y: resd 1               ; y coordinate
        alpha: resd 1           ; angle with x-axis
        numOfTargets: resd 1    ; amount of targes destoryed by a drone
        next: resd 1            ; next drone in the array
    endstruc

section .text
global runScheduler

runScheduler:
    ret



