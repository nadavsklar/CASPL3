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
    extern format_int
    extern format_string
    extern Const16
    format_position: db "%.6f,%.6f", 10, 0
    format_player: db "%d,%.6f,%.6f,%.6f,%d", 10, 0    
; -----------------------------------------------------
; Global initialized vars.
; -----------------------------------------------------
section .data           ; we define (global) initialized variables in .data section
    extern SchedulerCo
    extern numOfDrones
    extern playersArray
    extern targetPosition
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
; Extern Functions
; -----------------------------------------------------
extern calculateRandomNumber
extern printf
extern Resume
extern do_Resume
; -----------------------------------------------------
; Name: runPrinter
; Purpose: Main printer activity according to the algorithm given.
; -----------------------------------------------------
runPrinter:
    ; ----- Ugly things to clean stack -----------
    push    ebp
    mov     ebp, esp
    pushad
    ; ----- Just print ---------------------------
    ; mov     eax, 232323                     ; Try to print.
    ; push    eax
    ; push    format_int
    ; call    printf
    ; add     esp, 8
    ; -------------- Printing Location ---------------
    mov     dword ebx, [targetPosition]         ; ebx = targetPosition
	fld 	dword [ebx + 4]                     ; Pushing targetPosition.Y
	sub 	esp, 8
	fstp 	qword [esp]
    fld     dword [ebx + 0]                     ; Pushing targetPosition.X
    sub 	esp,8
	fstp 	qword [esp]
    push    format_position
    call    printf
    add     esp, 20
    ; ------------- Printing Players ------------------
    mov     dword edi, 0                        ; edi is the index of each player
    PrintingPlayersLoop:
    mov     dword ebx, [playersArray]           ; ebx = playersArray
    cmp     dword edi, [numOfDrones]
    je      PrintingPlayersEnd
    mov     dword eax, edi
    mul     dword [Const16]
    add     ebx, eax                            ; ebx = playersArray[edi]
    push    dword [ebx + 12]                    ; Pushing playersArray[edi].numOfTargets
    fld     dword [ebx + 8]                     ; Pushing playersArray[edi].Alpha
    sub     esp, 8
    fstp    qword [esp]
    fld     dword [ebx + 4]                     ; Pushing playersArray[edi].Y
    sub     esp, 8
    fstp    qword [esp]
    fld     dword [ebx + 0]                     ; Pushing playersArray[edi].X
    sub     esp, 8
    fstp    qword [esp]
    mov     ecx, edi
    inc     ecx
    push    ecx                                 ; Pushing playersArray index
    push    format_player
    call    printf
    add     esp, 36
    inc     edi
    jmp     PrintingPlayersLoop
    PrintingPlayersEnd:
    ; ------ Return ----------------------
    popad
    mov     esp, ebp
    pop     ebp
    mov     dword ebx, SchedulerCo
    call    Resume 
    jmp     runPrinter