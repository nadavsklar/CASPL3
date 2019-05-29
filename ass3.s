; -----------------------------------------------------
; Description: Main file. Init the game.
; Date: 20.5.2019
; Change Log: 21.5.2019 - Adding some documentation
;             26.5.2019 - Compiling and adding makefile. Starting real functions and 
;                           Co routines stuff. 
; -----------------------------------------------------
; -----------------------------------------------------
; Global read only vars
; -----------------------------------------------------
section	.rodata			        ; we define (global) read-only variables in .rodata section
    global StackOffset
    global FunctionOffset
    global Const8
    global format_int
    global format_string
    StackSizeDrone: dd 16384
    taps: dd 11, 13, 14, 16     ; Unique taps for LFSR
    format_int: db "%d", 10, 0  ; format int printf
    format_string: db "%s", 10, 0   ; format string printf
    FunctionOffset equ 0                 ; offset of pointer to co-routine function in co-routine struct 
    StackOffset equ 4                   ; offset of pointer to co-routine stack in co-routine struct
    Const8: dd 8
; -----------------------------------------------------
; Global uninitialized vars, such as buffers, structures
; and more.
; -----------------------------------------------------
section .bss			        ; we define (global) uninitialized variables in .bss section
    global Curr
    LFSR: resw 1                ; register for randon numbers
    StackSize equ 16*1024             ; 16 kb, for stack size
    PrinterStack: resb StackSize          ; stack for each co-routine
    TargetStack: resb StackSize
    SchedulerStack: resb StackSize
    DroneStack: resb StackSize
    Curr: resd 1
    TempSP: resd 1
    MainSP: resd 1
; -----------------------------------------------------
; Global initialized vars.
; -----------------------------------------------------
section .data                   ; we define (global) initialized variables in .data section
    global numOfDrones
    global printSteps
    global DronesArrayPointer
    global PrinterCo
    numOfDrones: dd 0            ; number of drones on the board
    numberOfNeededTargets: dd 0     ; number of targets to win the game
    printSteps: dd 0                ; how many steps in order to print the game board
    beta: dd 0                      ; field of wiew
    maxDistance: dd 0               ; the maximum distance from the target in order to destroy it
    seed: dd 0                      ; init for the LFSR
    PrinterCo:  dd runPrinter       ; Printer Co struct
                dd PrinterStack + StackSize
    SchedulerCo: dd runScheduler    ; Scheculer Co struct
                 dd SchedulerStack + StackSize
    TargetCo: dd runTarget          ; Target Co struct
              dd TargetStack + StackSize
    DroneCos: dd runDrone           ; Drone Cos struct
              dd DroneStack + StackSize
    DronesArrayPointer: dd 0        ; Drones array pointer
section .text
; -----------------------------------------------------
; Global Functions
; -----------------------------------------------------
global main
extern printf
extern malloc
extern runTarget
extern runDrone
extern runPrinter
extern runScheduler
extern do_Resume
extern Resume
global startCo
global endCo
; -----------------------------------------------------
; Name: main
; Purpose: main function, called from start. 
; Init the program details using argv arguments and the other
; functions below.
; //TODO: Enter every arg into its var. Using sscanf
; -----------------------------------------------------
main:
    ; mov ecx, [esp+4] ; argc
    ; mov edx, [esp+8] ; argv
    ; top:
    ; push ecx ; save registers that printf wastes
    ; push edx

    ; push dword [edx] ; the argument string to display
    ; push format_string ; the format string
    ; call printf
    ; add esp, 8 ; remove the two parameters

    ; pop edx ; restore registers printf used
    ; pop ecx

    ; add edx, 4 ; point to next argument
    ; dec ecx ; count down
    ; jnz top ; if not done counting keep going

    ; mov dword ecx, [numOfDrones]
    ; push ecx
    ; push format_int
    ; call printf
    ; add esp, 8

    mov     dword [numOfDrones], 3
    call    initCoRoutines
    call    startCo

    mov    ebx,eax
    mov    eax,1
    int    0x80
    nop
; -----------------------------------------------------
; Name: initBoard
; Purpose: Function that init the board size and array.
; -----------------------------------------------------
initBoard:
    ret
; -----------------------------------------------------
; Name: initLFSR
; Purpose: Function that init the LFSR register according
; to the taps vars and the seed given.
; -----------------------------------------------------
initLFSR:
    ret
; -----------------------------------------------------
; Name: initCoRoutines
; Purpose: Function that init the Threads (Co-Routines)
; in the board game. 
; -----------------------------------------------------
initCoRoutines:
    ;---------Init Printer Co-Routine------------------
    call initPrinter
    ;----------Init Scheduler Co-Routine----------------
    call initScheduler
    ;----------Init Target Co-Routine----------------
    call initTarget
    ;----------Init Drones Co-Routines----------------
    mov     dword eax, [numOfDrones]
    mul     dword [Const8]
    push    eax
    call    malloc
    mov     dword [DronesArrayPointer], eax     ; DronesArrayPointer = malloc(numOfDrones * 8)
    mov     edi, 0
    StartingLoopInitDrones:
        cmp     dword edi, [numOfDrones]            ; Checking if every drone is initiated
        je      EndingLoopInitDrones            
        mov     eax, edi                            ; Doing some stupid stuff for mul 8
        mov     dword edx, [Const8]             
        mul     edx
        mov     dword ebx, [DronesArrayPointer] 
        add     ebx, eax                            ; ebx = DronesArrayPointer[edi]
        mov     dword ecx, [runDrone]
        mov     dword [ebx], ecx                    ; DronesArrayPointer[i].func = runDrone
        push    dword [StackSizeDrone]
        call    malloc
        add     dword ebx, StackOffset
        mov     dword [ebx], eax                    ; DronesArrayPointer[i].stack = malloc(StackSize)
        mov     eax, edi
        mov     dword edx, [Const8]
        mul     edx
        mov     dword ecx, [DronesArrayPointer] 
        add     ecx, eax
        mov     dword eax, [ecx + FunctionOffset]   ; eax = DronesArrayPointer[i].func
        mov     dword esp, [ecx + StackOffset]      ; esp = DronesArrayPointer[i].stack
        push    eax
        pushfd
        pushad
        mov     dword [ecx + StackOffset], esp      ; saving returning address
        mov     dword esp, [TempSP]
        inc     edi
        jmp     StartingLoopInitDrones
    EndingLoopInitDrones:
        mov     dword esp, [TempSP]                 ; esp = return address
        ret
; -----------------------------------------------------
; Name: initPrinter
; Purpose: Function that init the Printer-Co-Routine
; -----------------------------------------------------
initPrinter:
    mov     dword ebx, [PrinterCo]              ; get Pointer to PrinterCo struct
    mov     dword eax, [ebx + FunctionOffset]   ; get initial EIP value - pointer to CO function
    mov     dword [TempSP], esp                 ; save esp value
    mov     esp, [ebx + StackOffset]            ; get initial ESP value – pointer to COi stack
    push    eax                                ; push return address
    pushfd                                  ; push flags
    pushad                                  ; push registers
    mov     [ebx + StackOffset], esp            ; save new SPi value
    mov     dword esp, [TempSP]                 ; restore esp value
    ret
; -----------------------------------------------------
; Name: initTarget
; Purpose: Function that init the Target-Co-Routine
; -----------------------------------------------------
initTarget:
    mov     dword ebx, [TargetCo]               ; get Pointer to PrinterCo struct
    mov     dword eax, [ebx + FunctionOffset]   ; get initial EIP value - pointer to CO function
    mov     dword [TempSP], esp                 ; save esp value
    mov     esp, [ebx + StackOffset]            ; get initial ESP value – pointer to COi stack
    push    eax                                ; push return address
    pushfd                                  ; push flags
    pushad                                  ; push registers
    mov     [ebx + StackOffset], esp            ; save new SPi value
    mov     dword esp, [TempSP]                 ; restore esp value
    ret
; -----------------------------------------------------
; Name: initScheduler
; Purpose: Function that init the Scheduler-Co-Routine
; -----------------------------------------------------
initScheduler:
    mov     dword ebx, [SchedulerCo]               ; get Pointer to PrinterCo struct
    mov     dword eax, [ebx + FunctionOffset]   ; get initial EIP value - pointer to CO function
    mov     dword [TempSP], esp                 ; save esp value
    mov     esp, [ebx + StackOffset]            ; get initial ESP value – pointer to COi stack
    push    eax                                ; push return address
    pushfd                                  ; push flags
    pushad                                  ; push registers
    mov     [ebx + StackOffset], esp            ; save new SPi value
    mov     dword esp, [TempSP]                 ; restore esp value
    ret
; -----------------------------------------------------
; Name: initPlayers
; Purpose: Function that init the drones in the game
; according to the numOfDrones given at argv.
; -----------------------------------------------------
initPlayers:
    ret
; -----------------------------------------------------
; Name: calculateRandomNumber
; Purpose: LFSR main function, calculate a random number.
; -----------------------------------------------------
calculateRandomNumber:
    ret
; -----------------------------------------------------
; Name: startCo
; Purpose: We start scheduling by suspending main() and resuming a scheduler co-routine.
; -----------------------------------------------------
startCo:
    pushad
    mov     dword [MainSP], esp
    mov     dword ebx, [SchedulerCo]
    jmp     do_Resume
; -----------------------------------------------------
; Name: endCo
; Purpose: We end scheduling and go back to main().
; -----------------------------------------------------
endCo:
    mov     dword esp, [MainSP]
    popad


