; -----------------------------------------------------
; Description: Scheduler file, manages program flow.
; Date: 20.5.2019
; Change Log: 21.5.2019 - Adding some documentation
; -----------------------------------------------------
; -----------------------------------------------------
; Global read only vars
; -----------------------------------------------------
section	.rodata			; we define (global) read-only variables in .rodata section
    droneSize: dd 20    ; Drone structure size
; -----------------------------------------------------
; Global initialized vars.
; -----------------------------------------------------
section .data           ; we define (global) initialized variables in .data section
; -----------------------------------------------------
; Global uninitialized vars, such as buffers, structures
; and more.
; -----------------------------------------------------
section .bss			; we define (global) uninitialized variables in .bss section
    struc drone                 ; we define drone structure
        x: resd 1               ; x coordinate
        y: resd 1               ; y coordinate
        alpha: resd 1           ; angle with x-axis
        numOfTargets: resd 1    ; amount of targes destoryed by a drone
        next: resd 1            ; next drone in the array
    endstruc

section .text
; -----------------------------------------------------
; Global Functions
; -----------------------------------------------------
global runScheduler
; -----------------------------------------------------
; Name: runScheduler
; Purpose: Main loop function of the program. Schedule 
; between every co-routine we have such as drone and print,
; according to the algorithm given.
; -----------------------------------------------------
runScheduler:
    ret



