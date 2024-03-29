; -----------------------------------------------------
; Description: Scheduler file, manages program flow.
; Date: 20.5.2019
; Change Log: 21.5.2019 - Adding some documentation
;             26.5.2019 - Compiling and adding makefile. Starting real functions and 
;                           Co routines stuff. 
;             31.5.2019 - Fixing runScheduler - according to the algorithm given.
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
    global currentSteps
    global DroneIndex
    DroneIndex: dd 0
    currentSteps: dd 0
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
    ; ------- Switching to the i's drone co routine ----
    SwitchingToDroneCoRotine:
        mov     dword ebx, [DronesArrayPointer]
        mov     dword eax, [DroneIndex]
        mul     dword [Const8]
        add     dword ebx, eax
        call    Resume
    StartLoopingRoundRobinDroneCoRoutines:
        inc     dword [DroneIndex]              ; Moving to next Drone
        inc     dword [currentSteps]            ; Now moving with steps counter
        mov     dword ecx, [numOfDrones]
        cmp     dword ecx, [DroneIndex]
        jne     ContinueToNextDrone
        ; ---------- returning to first Drone --------
        mov     dword [DroneIndex], 0
    ContinueToNextDrone:
        mov     dword edi, [printSteps]
        cmp     dword [currentSteps], edi
        je      SwitchingToPrinterCoRoutine
        jmp     SwitchingToDroneCoRotine
    SwitchingToPrinterCoRoutine:
        mov     dword ebx, PrinterCo
        call    Resume
        mov     dword [currentSteps], 0
        jmp     SwitchingToDroneCoRotine
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
    mov     dword [Curr], ebx               ; Curr points to the struct of the current co-routine
    popad
    popfd
    ret     