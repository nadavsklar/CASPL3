; -----------------------------------------------------
; Description: Main file. Init the game.
; Date: 20.5.2019
; Change Log:
; -----------------------------------------------------

section	.rodata			        ; we define (global) read-only variables in .rodata section
    droneSize: dd 20
    taps: dd 11, 13, 14, 16

section .data                   ; we define (global) initialized variables in .data section
    numberOfDrones: dd 0            ; number of drones on the board
    numberOfNeededTargets: dd 0     ; number of targets to win the game
    printSteps: dd 0                ; how many steps in order to print the game board
    beta: dd 0                      ; field of wiew
    maxDistance: dd 0               ; the maximum distance from the target in order to destroy it
    seed: dd 0                      ; init for the LFSR

section .bss			        ; we define (global) uninitialized variables in .bss section
    struc drone                 ; we define drone structure
        x: resd 1               ; x coordinate
        y: resd 1               ; y coordinate
        alpha: resd 1           ; angle with x-axis
        numOfTargets: resd 1    ; amount of targes destoryed by a drone
        next: resd 1            ; next drone in the array
    endstruc

    LFSR: resw 1                ; register for randon numbers

section .text
global main
_start:
    pop     dword ecx       ; ecx = argc    
    mov     esi,esp         ; esi = argv 
    mov     eax,ecx         ; put the num of argument to ecx
    shl     eax,2           ; compute the size of argv in bytes
    add     eax,esi         ; add the size to the address of argv 
    add     eax,4           ; skip NULL at the end of argv
    push    dword eax       ; char* envp[]
    push    dword esi       ; char* argv[]
    push    dword ecx       ; int argc

    call    main            ; call main

    mov     ebx,eax
    mov    eax,1
    int     0x80
    nop

main:

initBoard:
    ret

initLFSR:
    ret

initCoRoutines:
    ret

initPlayers:
    ret

calculateRandomNumber:
    ret
 
