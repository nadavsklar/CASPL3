; -----------------------------------------------------
; Description: Target main activity file.
; Date: 20.5.2019
; Change Log: 21.5.2019 - Adding some documentation.
;             26.5.2019 - Compiling and adding makefile. Starting real functions and 
;                           Co routines stuff. 
; -----------------------------------------------------
; -----------------------------------------------------
; Global read only vars
; -----------------------------------------------------
section	.rodata			; we define (global) read-only variables in .rodata section
; -----------------------------------------------------
; Global initialized vars.
; -----------------------------------------------------
section .data           ; we define (global) initialized variables in .data section
    global canDestroy
    canDestroy: dd 0
; -----------------------------------------------------
; Global uninitialized vars, such as buffers, structures
; and more.
; -----------------------------------------------------
section .bss			; we define (global) uninitialized variables in .bss section
section .text
; -----------------------------------------------------
; Global Functions
; -----------------------------------------------------
global mayDestroy
global runTarget
global getTargetLocation
global destoryTarget
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
; Name: destoryTarget
; Purpose: Function that destroy a target.
; -----------------------------------------------------
destoryTarget:
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