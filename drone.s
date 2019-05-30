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
    extern SchedulerCo
; -----------------------------------------------------
; Global uninitialized vars, such as buffers, structures
; and more.
; -----------------------------------------------------
section .bss			; we define (global) uninitialized variables in .bss section
    extern MainSP

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
extern Resume
extern do_Resume
; -----------------------------------------------------
; Name: runDrone
; Purpose: Main function of drone activity. Works according
; to the algorithm given.
; -----------------------------------------------------
runDrone:
    mov eax, 10
    push eax
    push format_int
    call printf
    add esp, 8
    pushad
    mov     dword ebx, SchedulerCo
    call    Resume 
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

