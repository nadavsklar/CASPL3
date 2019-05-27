; -----------------------------------------------------
; Description: Drone main activity.
; Date: 20.5.2019
; Change Log: 21.5.2019 - Adding some documentation
;             26.5.2019 - Compiling and adding makefile. Starting real functions and 
;                           Co routines stuff. 
; -----------------------------------------------------
; -----------------------------------------------------
; Global read only vars
; -----------------------------------------------------
section	.rodata			; we define (global) read-only variables in .rodata section
extern format_int
extern format_string
; -----------------------------------------------------
; Global initialized vars.
; -----------------------------------------------------
section .data           ; we define (global) initialized variables in .data section
; -----------------------------------------------------
; Global uninitialized vars, such as buffers, structures
; and more.
; -----------------------------------------------------
section .bss			; we define (global) uninitialized variables in .bss section
section .text
; -----------------------------------------------------
; Global Functions
; -----------------------------------------------------
global runDrone
; -----------------------------------------------------
; Extern Functions
; -----------------------------------------------------
extern calculateRandomNumber
extern printf
; -----------------------------------------------------
; Name: runDrone
; Purpose: Main function of drone activity. Works according
; to the algorithm given.
; -----------------------------------------------------
runDrone:
    mov eax, 123456789
    push eax
    push format_int
    call printf
    add esp, 8
    ret
; -----------------------------------------------------
; Name: calculateNewPosition
; Purpose: Function that calculate the drone movement 
; in every new step.
; -----------------------------------------------------
calculateNewPosition:
    ret
; -----------------------------------------------------
; Name: destoryTarget
; Purpose: Function that destory the target on board and
; adds a point to the specific drone.
; -----------------------------------------------------
destoryTarget:
    ret

