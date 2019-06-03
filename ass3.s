; -----------------------------------------------------
; Description: Main file. Init the game.
; Date: 20.5.2019
; Change Log: 21.5.2019 - Adding some documentation
;             26.5.2019 - Compiling and adding makefile. Starting real functions and 
;                           Co routines stuff. 
;             31.5.2019 - Communication working until Printer
;             3.6.2019 - Comminication working with drones > 3
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
    global Const16
    StackSizeDrone: dd 16384
    taps: dd 11, 13, 14, 16     ; Unique taps for LFSR
    format_int: db "%d", 10, 0  ; format int printf
    format_string: db "%s", 10, 0   ; format string printf
    FunctionOffset equ 0                 ; offset of pointer to co-routine function in co-routine struct 
    StackOffset equ 4                   ; offset of pointer to co-routine stack in co-routine struct
    Const8: dd 8
    Const16: dd 16
; -----------------------------------------------------
; Global uninitialized vars, such as buffers, structures
; and more.
; -----------------------------------------------------
section .bss			        ; we define (global) uninitialized variables in .bss section
    global Curr
    global MainSP
    global TempSP
    StackSize equ 16*1024             ; 16 kb, for stack size
    PrinterStack: resb StackSize          ; stack for each co-routine
    TargetStack: resb StackSize
    SchedulerStack: resb StackSize
    DroneStack: resb StackSize
    Curr: resd 1
    TempSP: resd 1
    MainSP: resd 1
    LFSR: resw 0
; -----------------------------------------------------
; Global initialized vars.
; -----------------------------------------------------
section .data                   ; we define (global) initialized variables in .data section
    global numOfDrones
    global numberOfNeededTargets
    global printSteps
    global DronesArrayPointer
    global playersArray
    global PrinterCo
    global SchedulerCo
    global randomNum
    extern currentSteps
    playerIndex: dd 0
    X: dd 0.0
    Y: dd 0.0
    alpha: dd 0.0
    beta: dd 0                      ; field of wiew
    seed: dw 0                      ; init for the LFSR
    LFSR16bit: dd 0
    LFSR14bit: dd 0
    LFSR13bit: dd 0
    LFSR11bit: dd 0
    randomNum: dd 0
    numOfDrones: dd 0            ; number of drones on the board
    numberOfNeededTargets: dd 0     ; number of targets to win the game
    printSteps: dd 0                ; how many steps in order to print the game board
    maxDistance: dd 0               ; the maximum distance from the target in order to destroy it
    TmpDronesArrayPointer: dd 1     ; Tmp drones array pointer
    PrinterCo:  dd runPrinter       ; Printer Co struct
                dd PrinterStack + StackSize
    SchedulerCo: dd runScheduler    ; Scheculer Co struct
                 dd SchedulerStack + StackSize
    TargetCo: dd runTarget          ; Target Co struct
              dd TargetStack + StackSize
    DroneCos: dd runDrone           ; Drone Cos struct
              dd DroneStack + StackSize             
    playersArray: dd 0              ; players Array -- each player - according to drone - have x,y,alpha
    DronesArrayPointer: dd runDrone ; Drones array pointer
section .text
; -----------------------------------------------------
; Global & Extern Functions
; -----------------------------------------------------
    global main
    extern printf
    extern sscanf
    extern malloc
    extern runTarget
    extern runDrone
    extern runPrinter
    extern runScheduler
    extern do_Resume
    extern Resume
    global startCo
    global endCo
    global calculateRandomNumber
; -----------------------------------------------------
; Name: main
; Purpose: main function, called from start. 
; Init the program details using argv arguments and the other
; functions below.
; //TODO: Enter every arg into its var. Using sscanf
; -----------------------------------------------------
main:
    mov     ecx, [esp + 4] ; argc
    mov     edx, [esp + 8] ; argv
    ; ----------- Gettings program args ---------------
    add     edx, 4
    ; ----------- Num of drones -----------------------
    pushad                         ; sscanf use edx
    push    dword numOfDrones
    push    format_int
    push    dword [edx]
    call    sscanf
    add     esp, 12
    popad                         ; restore
    add     edx, 4
    ; ----------- Num of Targets ----------------------
    pushad
    push    dword numberOfNeededTargets
    push    format_int
    push    dword [edx]
    call    sscanf
    add     esp, 12
    popad
    add     edx, 4
    ; ----------- Print steps ----------------------
    pushad
    push    dword printSteps
    push    format_int
    push    dword [edx]
    call    sscanf
    add     esp, 12
    popad
    add     edx, 4
    ; ----------- Field of view ----------------------
    pushad
    push    dword beta
    push    format_int
    push    dword [edx]
    call    sscanf
    add     esp, 12
    popad
    add     edx, 4
    ; ----------- MaxDistance ----------------------
    pushad
    push    dword maxDistance
    push    format_int
    push    dword [edx]
    call    sscanf
    add     esp, 12
    popad
    add     edx, 4
    ; ----------- Seed ----------------------
    pushad
    push    dword LFSR
    push    format_int
    push    dword [edx]
    call    sscanf
    add     esp, 12
    popad
    
    call    initCoRoutines
    call    initPlayers
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
; Name: initCoRoutines
; Purpose: Function that init the Threads (Co-Routines)
; in the board game. 
; --------------------------------------mov ebx, [ebp+8]---------------
initCoRoutines:
;---------Init Printer Co-Routine------------------
    call initPrinter
    ;----------Init Scheduler Co-Routine----------------
    call initScheduler
    ;----------Init Target Co-Routine----------------
    call initTarget
    ;----------Init Drones Co-Routines----------------
    mov     dword [TempSP], esp
    mov     dword eax, [numOfDrones]
    mul     dword [Const8]
    push    eax
    call    malloc
    add     esp, 4
    mov     dword [DronesArrayPointer], eax             ; DronesArrayPointer = malloc(numOfDrones * 8)
    mov     edi, 0
    StartingLoopInitDrones:
        cmp     dword edi, [numOfDrones]                ; Checking if every drone is initiated
        je      EndingLoopInitDrones            
        mov     eax, edi                                ; Doing some stupid stuff for mul 8
        mov     dword edx, [Const8]             
        mul     edx
        mov     dword ebx, [DronesArrayPointer]
        add     ebx, eax                                ; ebx = DronesArrayPointer[edi]
        mov     dword ecx, runDrone
        mov     dword [ebx], ecx                        ; DronesArrayPointer[i].func = runDrone
        push    dword [StackSizeDrone]
        call    malloc
        add     esp, 4
        add     dword ebx, StackOffset
        mov     dword [ebx], eax                        ; DronesArrayPointer[i].stack = malloc(StackSize)
        sub     ebx, 4
        mov     dword eax, [ebx + FunctionOffset]       ; eax = DronesArrayPointer[i].func
        mov     dword [TempSP], esp
        mov     dword esp, [ebx + StackOffset]          ; esp = DronesArrayPointer[i].stack
        push    eax
        pushfd
        pushad
        mov     dword [ebx + StackOffset], esp          ; saving returning address
        mov     dword esp, [TempSP]
        inc     edi
        jmp     StartingLoopInitDrones
    EndingLoopInitDrones:
        mov     dword ebx, [DronesArrayPointer]
        mov     dword ecx, runDrone
        mov     dword [ebx], ecx
        push    dword [StackSizeDrone]
        call    malloc
        add     esp, 4
        add     dword ebx, StackOffset
        mov     dword [ebx], eax                        ; DronesArrayPointer[i].stack = malloc(StackSize)
        sub     ebx, 4
        mov     dword eax, [ebx + FunctionOffset]       ; eax = DronesArrayPointer[i].func
        mov     dword [TempSP], esp
        mov     dword esp, [ebx + StackOffset]          ; esp = DronesArrayPointer[i].stack
        push    eax
        pushfd
        pushad
        mov     dword [ebx + StackOffset], esp          ; saving returning address
        mov     dword esp, [TempSP]                     ; esp = return address
        ret

; -----------------------------------------------------
; Name: initPrinter
; Purpose: Function that init the Printer-Co-Routine
; -----------------------------------------------------
initPrinter:
    mov     dword ebx, PrinterCo                ; get Pointer to PrinterCo struct
    mov     dword eax, [ebx + FunctionOffset]   ; get initial EIP value - pointer to CO function
    mov     dword [TempSP], esp                 ; save esp value
    mov     esp, [ebx + StackOffset]            ; get initial ESP value – pointer to COi stack
    push    eax                                 ; push return address
    pushfd                                      ; push flags
    pushad                                      ; push registers
    mov     [ebx + StackOffset], esp            ; save new SPi value
    mov     dword esp, [TempSP]                 ; restore esp value
    ret
; -----------------------------------------------------
; Name: initTarget
; Purpose: Function that init the Target-Co-Routine
; -----------------------------------------------------
initTarget:
    mov     dword ebx, TargetCo                 ; get Pointer to PrinterCo struct
    mov     dword eax, [ebx + FunctionOffset]   ; get initial EIP value - pointer to CO function
    mov     dword [TempSP], esp                 ; save esp value
    mov     esp, [ebx + StackOffset]            ; get initial ESP value – pointer to COi stack
    push    eax                                 ; push return address
    pushfd                                      ; push flags
    pushad                                      ; push registers
    mov     [ebx + StackOffset], esp            ; save new SPi value
    mov     dword esp, [TempSP]                 ; restore esp value
    ret
; -----------------------------------------------------
; Name: initScheduler
; Purpose: Function that init the Scheduler-Co-Routine
; -----------------------------------------------------
initScheduler:
    mov     dword ebx, SchedulerCo              ; get Pointer to PrinterCo struct
    mov     dword eax, [ebx + FunctionOffset]   ; get initial EIP value - pointer to CO function
    mov     dword [TempSP], esp                 ; save esp value
    mov     esp, [ebx + StackOffset]            ; get initial ESP value – pointer to COi stack
    push    eax                                 ; push return address
    pushfd                                      ; push flags
    pushad                                      ; push registers
    mov     [ebx + StackOffset], esp            ; save new SPi value
    mov     dword esp, [TempSP]                 ; restore esp value
    ret
; -----------------------------------------------------
; Name: initPlayers
; Purpose: Function that init the drones in the game
; according to the numOfDrones given at argv.
; TODO: alpha dosent working for some reason
; -----------------------------------------------------
initPlayers:
    mov     dword eax, [numOfDrones]
    mul     dword [Const16]
    push    eax
    call    malloc
    add     esp, 4
    mov     dword [playersArray], eax           ; playersArray = malloc(numOfDrones * 12)
    mov     dword [playerIndex], 0
    playersLoop:
        mov     dword ecx, [numOfDrones]
        cmp     dword ecx, [playerIndex]
        je      endPlayersLoop
        pushad
        ; -------------- X ------------------------
        call    calculateRandomNumber           ; random number for x
        fild    dword [randomNum]               ; push random number as float
        mov     dword [randomNum], 100          ; scale - moving 100
        fimul   dword [randomNum]               ; random * 100
        mov     dword [randomNum], 65535
        fidiv   dword [randomNum]               ; random * 100 / 65535
        fstp    dword [X]
        ; -------------- Y ------------------------
        call    calculateRandomNumber           ; random number for y
        fild    dword [randomNum]               ; push random number as float
        mov     dword [randomNum], 100          ; scale - moving 100
        fimul   dword [randomNum]               ; random * 100
        mov     dword [randomNum], 65535
        fidiv   dword [randomNum]               ; random * 100 / 65535
        fstp    dword [Y]
        ; ------------- alpha ---------------------
        call    calculateRandomNumber           ; random number for x
        fild    dword [randomNum]               ; push random number as float
        mov     dword [randomNum], 360          ; scale - moving 100
        fimul   dword [randomNum]               ; random * 360
        mov     dword [randomNum], 65535
        fidiv   dword [randomNum]               ; random * 360 / 65535
        fldpi                                   ; mov to radian
        fmul
        mov     dword [randomNum], 180          
        fidiv   dword [randomNum]
        fstp    dword [alpha]                   ; Notice: in radians
        popad
        ; ----------- moving data to players -------------
        mov     dword eax, [Const16]
        mul     dword [playerIndex]                             ; eax = 12 * index
        mov     dword ecx, [playersArray]
        add     ecx, eax                                        ; ecx = players[index]
        mov     dword ebx, [X]
        mov     dword [ecx], ebx
        mov     dword ebx, [Y]
        mov     dword [ecx + 4], ebx
        mov     dword ebx, [alpha]
        mov     dword [ecx + 8], ebx
        mov     dword [ecx + 12], 0
        ; ----------- next player -------------
        inc     dword [playerIndex]
        jmp     playersLoop
    endPlayersLoop:
    ret
; -----------------------------------------------------
; Name: calculateRandomNumber
; Purpose: LFSR main function, calculate a random number.
; -----------------------------------------------------
calculateRandomNumber:
    ; ---- first getting taps position bits -------
    mov     dword eax, [LFSR] 
    mov     dword [randomNum], 0
    mov     dword [randomNum], eax           
    ; -------- 16 ------------
    mov     dword ecx, 0
    mov     dword ecx, [LFSR]   
    and     ecx, 1
    mov     dword [LFSR16bit], 0
    mov     dword [LFSR16bit], ecx
    ; -------- 14 ------------
    mov     dword ecx, 0
    mov     dword ecx, [LFSR] 
    and     ecx, 4
    shr     ecx, 2
    mov     dword [LFSR14bit], 0
    mov     dword [LFSR14bit], ecx
    ; -------- 13 ------------
    mov     dword ecx, 0
    mov     dword ecx, [LFSR] 
    and     ecx, 8
    shr     ecx, 3
    mov     dword [LFSR13bit], 0
    mov     dword [LFSR13bit], ecx
    ; -------- 11 ------------
    mov     dword ecx, 0
    mov     dword ecx, [LFSR] 
    and     ecx, 32
    shr     ecx, 5
    mov     dword [LFSR11bit], 0
    mov     dword [LFSR11bit], ecx
    ; -------- Xor -----------

    mov     dword ecx, [LFSR16bit]
    mov     dword edx, [LFSR14bit]
    xor     ecx, edx                ; ecx = ecx XOR edx. 16bit Xor 14bit
    mov     dword edx, [LFSR13bit]
    xor     ecx, edx                ; ecx = ecx Xor edx. (16 xor 14) xor 13
    mov     dword edx, [LFSR11bit]  ; ecx = ecx Xor edx. ((16 xor 14) xor 13) xor 11
    xor     ecx, edx
    mov     dword edx, [LFSR]
    shr     edx, 1
    cmp     ecx, 1
    jne     returnRandomNumber
    addToLFSR:
        add     edx, 32768
    returnRandomNumber:
        mov     dword [LFSR], edx
    ; ------------ Return number in randomNum ---------------
    ret
; -----------------------------------------------------
; Name: startCo
; Purpose: We start scheduling by suspending main() and resuming a scheduler co-routine.
; -----------------------------------------------------
startCo:
    pushad
    mov     dword [MainSP], esp
    mov     dword ebx, SchedulerCo
    jmp     do_Resume

; -----------------------------------------------------
; Name: endCo
; Purpose: We end scheduling and go back to main().
; -----------------------------------------------------
endCo:
    mov     dword esp, [MainSP]
    popad
    ret