; -----------------------------------------------------
; Description: Scheduler file, manages program flow.
; Date: 20.5.2019
; Change Log: 21.5.2019 - Adding some documentation
;             26.5.2019 - Compiling and adding makefile. Starting real functions and 
;                           Co routines stuff. 
; -----------------------------------------------------
; -----------------------------------------------------
; Global read only vars
; -----------------------------------------------------
section	.rodata			; we define (global) read-only variables in .rodata section
    extern Const8
    extern FunctionOffset
    droneSize: dd 20    ; Drone structure size
    StackOffset equ 4
; -----------------------------------------------------
; Global initialized vars.
; -----------------------------------------------------
section .data           ; we define (global) initialized variables in .data section
    extern numOfDrones
    extern printSteps
    extern DronesArrayPointer
    extern PrinterCo
    DroneIndex: dd 0
; -----------------------------------------------------
; Global uninitialized vars, such as buffers, structures
; and more.
; -----------------------------------------------------
section .bss			; we define (global) uninitialized variables in .bss section
extern Curr
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
global Resume
global do_Resume
; -----------------------------------------------------
; Name: runScheduler
; Purpose: Main loop function of the program. Schedule 
; between every co-routine we have such as drone and print,
; according to the algorithm given.
; -----------------------------------------------------
runScheduler:
    StartLoopingRoundRobinDroneCoRoutines:
        inc     dword [DroneIndex]
        mov     dword ecx, [numOfDrones]
        cmp     dword ecx, [DroneIndex]
        jge     Nothing
        mov     dword [DroneIndex], 0

    Nothing:
        mov     dword edi, [printSteps]
        cmp     dword [DroneIndex], edi
        je      SwitchingToPrinterCoRoutine
        jmp     SwitchingToDroneCoRotine

    SwitchingToDroneCoRotine:
        mov     dword ebx, [DronesArrayPointer]
        mov     dword eax, [DroneIndex]
        mul     dword [Const8]
        add     dword ebx, eax
        c:
        call    Resume
        jmp     StartLoopingRoundRobinDroneCoRoutines

    SwitchingToPrinterCoRoutine:
        mov     dword ebx, PrinterCo
        call    Resume
    ret

; -----------------------------------------------------
; Name: Resume & do_Resume
; Purpose: 2 main functions that handles the co-routine changes.
; Taken from PS.
; -----------------------------------------------------
Resume:
    pushfd
    pushad
    mov     dword edx, [Curr]               ; edx = &currentCoRoutineStruct
    mov     dword [edx + StackOffset], esp  ; save current esp
do_Resume:
    mov     dword esp, [ebx + StackOffset]
    e1:
    mov     dword [Curr], ebx               ; Curr points to the struct of the current co-routine
    e2:
    popad
    popfd
    e:
    ret     


