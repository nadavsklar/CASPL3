; -----------------------------------------------------
; Description: Drone main activity.
; Date: 20.5.2019
; Change Log: 21.5.2019 - Adding some documentation
;             26.5.2019 - Compiling and adding makefile. Starting real functions and 
;                           Co routines stuff. 
;             31.5.2019 - Fixing runDrone stack options before and at the end.
; -----------------------------------------------------
; -----------------------------------------------------
; Global read only vars
; -----------------------------------------------------
section	.rodata			; we define (global) read-only variables in .rodata section
extern format_int
extern format_string
extern Const16
message: dw "Drone"
format_string_noline: db "%s", 0
format_win: db "Drone id %d: I am a winner", 10, 0
; -----------------------------------------------------
; Global initialized vars.
; -----------------------------------------------------
section .data           ; we define (global) initialized variables in .data section
    extern SchedulerCo
    extern DroneIndex
    extern randomNum
    extern playersArray
    extern canDestroy
    extern numberOfNeededTargets
    deltaAlpha: dd 0
    deltaDistance: dd 0
    tempAlpha: dd 0
    tempX: dd 0
    tempY: dd 0
    tempDrone: dd 0
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
extern Resume
extern do_Resume
extern mayDestroy
extern destoryTarget
extern endCo
; -----------------------------------------------------
; Name: runDrone
; Purpose: Main function of drone activity. Works according
; to the algorithm given.
; -----------------------------------------------------
runDrone:
    ; ----- Ugly things to clean stack -----------
    push    ebp
    mov     ebp, esp
    pushad
    ; ----- Just print ---------------------------
    push    dword message
    push    format_string_noline
    call    printf
    add     esp, 8
    push    dword [DroneIndex]
    push    format_int
    call    printf
    add     esp, 8
    ; ------------------- Calculating Random alpha ---------------------
    call    calculateRandomNumber
    fild    dword [randomNum]               ; push random number as float
    mov     dword [randomNum], 120          ; scale - moving 120
    fimul   dword [randomNum]               ; random * 120
    mov     dword [randomNum], 65535
    fidiv   dword [randomNum]               ; random * 120 / 65535
    mov     dword [randomNum], 60           ; random = random - 60
    fisub   dword [randomNum]
    fldpi                                   ; mov to radian
    fmul
    mov     dword [randomNum], 180          
    fidiv   dword [randomNum]
    fstp    dword [deltaAlpha]              ; Notice: in radians
    ; -------------------- Calculating Random distance ---------------------
    call    calculateRandomNumber           ; random number for distance
    fild    dword [randomNum]               ; push random number as float
    mov     dword [randomNum], 50           ; scale - moving 50
    fimul   dword [randomNum]               ; random * 50
    mov     dword [randomNum], 65535
    fidiv   dword [randomNum]               ; random * 50 / 65535
    fstp    dword [deltaDistance]
    ; --------------------- Calculating new angle ---------------------------
    mov     dword ebx, [playersArray]
    mov     dword eax, [DroneIndex]
    mul     dword [Const16]
    add     ebx, eax                        ; ebx = playersArray[DroneIndex]
    mov     dword eax, [ebx + 8]            ; eax = playersArray[DroneIndex].alpha
    mov     dword [tempAlpha], eax
    fld     dword [tempAlpha]               ; push playersArray[DroneIndex].alpha
    fld     dword [deltaAlpha]              ; push deltaAlpha
    fadd
    fldpi
    mov     dword [randomNum], 2
    fimul   dword [randomNum]
    fcomp
    jg      NotScalingAlpha
    fldpi
    mov     dword [randomNum], 2
    fimul   dword [randomNum]
    fsub
    mov     dword [randomNum], -1
    fimul   dword [randomNum]
    NotScalingAlpha:
    fstp    dword [ebx + 8]
    ; --------------------------- Calculating new X -------------------------
    mov     dword eax, [ebx + 0]            ; eax = playersArray[DroneIndex].x
    mov     dword [tempX], eax              ; tempX = eax
    fld     dword [ebx + 8]                 ; push current angle
    fcos                                    ; cos(alpha)
    fld     dword [deltaDistance]           ; push deltaDistance
    fmul                                    ; deltaDistance * cos(alpha)
    fld     dword [tempX]                   ; push x
    fadd                                    ; x + deltaDistance * cos(alpha)
    mov     dword [randomNum], 100
    fld     dword [randomNum]
    fcomp  
    jg      NotScalingX
    mov     dword [randomNum], 100
    fld     dword [randomNum]
    fsub
    mov     dword [randomNum], -1
    fimul   dword [randomNum]
    NotScalingX:
    fstp    dword [ebx + 0]
    ; --------------------------- Calculating new Y -------------------------
    mov     dword eax, [ebx + 4]            ; eax = playersArray[DroneIndex].y
    mov     dword [tempY], eax              ; tempY = eax
    fld     dword [ebx + 8]                 ; push current angle
    fsin                                    ; sin(alpha)
    fld     dword [deltaDistance]           ; push deltaDistance
    fmul                                    ; deltaDistance * sin(alpha)
    fld     dword [tempY]                   ; push y
    fadd                                    ; y + deltaDistance * sin(alpha)
    mov     dword [randomNum], 100
    fld     dword [randomNum]
    fcomp  
    jg      NotScalingY
    mov     dword [randomNum], 100
    fld     dword [randomNum]
    fsub
    mov     dword [randomNum], -1
    fimul   dword [randomNum]
    NotScalingY:
    fstp    dword [ebx + 4]
    ; -------------------------- Destroying the target ----------------------
    mov     dword [tempDrone], ebx
    call    mayDestroy
    cmp     dword [canDestroy], 0
    je      DontDestroy
    Destory:
    call    destoryTarget
    mov     dword ebx, [tempDrone]
    inc     dword [ebx + 12]
    mov     dword ecx, [ebx + 12]
    cmp     dword ecx, [numberOfNeededTargets]
    jne     DontDestroy
    push    dword [DroneIndex]
    push    format_win
    call    printf
    add     esp, 8
    call    endCo
    ; --------------------------- Return ---------------------
    DontDestroy:
    popad
    mov     esp, ebp
    pop     ebp
    mov     dword ebx, SchedulerCo
    call    Resume
    jmp     runDrone 
; -----------------------------------------------------
; Name: calculateNewPosition
; Purpose: Function that calculate the drone movement 
; in every new step.
; -----------------------------------------------------
calculateNewPosition:
    ret
