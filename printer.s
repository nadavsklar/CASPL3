; -----------------------------------------------------
; Description: Printer main activity file.
; Date: 20.5.2019
; Change Log: 21.5.2019 - Adding some documentation.
;             26.5.2019 - Compiling and adding makefile. Starting real functions and 
;                           Co routines stuff. 
; -----------------------------------------------------
; -----------------------------------------------------
; Global read only vars
; -----------------------------------------------------
section	.rodata			; we define (global) read-only variables in .rodata section
x: dd 5
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
global runPrinter
; -----------------------------------------------------
; Name: runPrinter
; Purpose: Main printer activity according to the algorithm given.
; -----------------------------------------------------
runPrinter:
    ret