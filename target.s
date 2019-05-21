; -----------------------------------------------------
; Description: Target main activity file.
; Date: 20.5.2019
; Change Log: 21.5.2019 - Adding some documentation.
; -----------------------------------------------------
; -----------------------------------------------------
; Global read only vars
; -----------------------------------------------------
section	.rodata			; we define (global) read-only variables in .rodata section
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
global runTarget
global getTargetLocation
; -----------------------------------------------------
; Name: runTarget
; Purpose: Main target function, works according to the 
; algorithm given.
; -----------------------------------------------------
runTarget:
    ret
; -----------------------------------------------------
; Name: getTargetLocation
; Purpose: Function that returns the current target location.
; -----------------------------------------------------
getTargetLocation:
    ret
; -----------------------------------------------------
; Name: createTarget
; Purpose: Creates new target on the game borad.
; -----------------------------------------------------
createTarget:
    ret
; -----------------------------------------------------
; Name: mayDestroy
; Purpose: Returns true if a specific drone may destory
; the target, according to its location, else return false.
; -----------------------------------------------------
mayDestroy:
    ret