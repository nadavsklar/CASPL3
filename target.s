; -----------------------------------------------------
; Description: Target main activity file.
; Date: 20.5.2019
; Change Log: 21.5.2019 - Adding some documentation.
;             26.5.2019 - Compiling and adding makefile. Starting real functions and 
;                           Co routines stuff. 
;             5.6.2019 - Target Co routine
;             7.6.2019 - Fixing patan, Adding CheckTerms func.
; -----------------------------------------------------
; -----------------------------------------------------
; Global read only vars
; -----------------------------------------------------
section	.rodata			; we define (global) read-only variables in .rodata section
    extern Const16
    extern Const180
; -----------------------------------------------------
; Global initialized vars.
; -----------------------------------------------------
section .data           ; we define (global) initialized variables in .data section
    global canDestroy
    extern playersArray
    extern targetPosition
    extern DroneIndex
    extern beta
    extern SchedulerCo
    extern maxDistance
    extern randomNum
    canDestroy: dd 0
    cond1: dd 0
    cond2: dd 0
    droneX: dd 0.0
    droneY: dd 0.0
    droneAlpha: dd 0.0
    targetX: dd 0.0
    targetY: dd 0.0
    deltaX: dd 0.0
    deltaY: dd 0.0
    Gamma: dd 0.0
    garbage: dd 0.0
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
extern calculateRandomNumber
extern Resume
; -----------------------------------------------------
; Name: runTarget
; Purpose: Main target function, works according to the 
; algorithm given.
; -----------------------------------------------------
runTarget:
    ; ----- Ugly things to clean stack -----------
    push    ebp
    mov     ebp, esp
    pushad
    call    createTarget
    ; ------ Return ----------------------
    popad
    mov     esp, ebp
    pop     ebp
    mov     dword ebx, SchedulerCo
    call    Resume 
    jmp     runTarget
; -----------------------------------------------------
; Name: createTarget
; Purpose: Creates new target on the game borad.
; -----------------------------------------------------
createTarget:
    mov     dword ebx, [targetPosition]
    mov     dword [ebx + 0], 0
    mov     dword [ebx + 4], 0
    mov     dword [targetX], 0
    mov     dword [targetY], 0
    ;---------------- Calculating Target X -----------------
    call    calculateRandomNumber
    fild    dword [randomNum]               ; push random number as float
    mov     dword [randomNum], 100          ; scale - moving 100
    fimul   dword [randomNum]               ; random * 100
    mov     dword [randomNum], 65535
    fidiv   dword [randomNum]               ; random * 100 / 65535
    fstp    dword [targetX]
    ;---------------- Calculating Target Y -----------------
    call    calculateRandomNumber
    fild    dword [randomNum]               ; push random number as float
    mov     dword [randomNum], 100          ; scale - moving 100
    fimul   dword [randomNum]               ; random * 100
    mov     dword [randomNum], 65535
    fidiv   dword [randomNum]               ; random * 100 / 65535
    fstp    dword [targetY]
    ;---------------- Loading into memory --------------------
    mov     dword ebx, [targetPosition]
    mov     dword ecx, [targetX]
    mov     dword [ebx + 0], ecx
    mov     dword ecx, [targetY]
    mov     dword [ebx + 4], ecx
    ret
; -----------------------------------------------------
; Name: mayDestroy
; Purpose: Returns true if a specific drone may destory
; the target, according to its location, else return false.
; -----------------------------------------------------
mayDestroy:
    ;-------------- Init vars -------------------------
    mov     dword [canDestroy], 0
    mov     dword ebx, [playersArray]
    mov     dword eax, [DroneIndex]
    mul     dword [Const16]
    add     ebx, eax                        ; ebx = playersArray[DroneIndex]
    mov     dword ecx, [ebx + 0]
    mov     dword [droneX], ecx             ; droneX = playersArray[DroneIndex].X
    mov     dword ecx, [ebx + 4]
    mov     dword [droneY], ecx             ; droneY = playersArray[DroneIndex].Y
    mov     dword ecx, [ebx + 8]
    mov     dword [droneAlpha], ecx         ; droneAlpha = playersArray[DroneIndex].alpha
    mov     dword ebx, [targetPosition]     ; ebx = targetPosition
    mov     dword ecx, [ebx + 0]
    mov     dword [targetX], ecx            ; targetX = targetPosition.X
    mov     dword ecx, [ebx + 4]
    mov     dword [targetY], ecx            ; targetY = targetPosition.Y
    fld     dword [targetX]
    fld     dword [droneX]
    fsub
    fstp    dword [deltaX]                  ; deltaX = targetX - droneX
    fld     dword [targetY]
    fld     dword [droneY]
    fsub
    fstp    dword [deltaY]                  ; deltaY = targetY - droneY
    ; ------------- Calculating Gamma ------------------
    fld     dword [deltaY]
    fld     dword [deltaX]                  ; divding delta y in delta x
    fdiv
    mov     dword [garbage], 1
    fild    dword [garbage]
    fpatan                                  ; arctan (deltaY / deltaX)
    mov     dword [garbage], 0
    fild    dword [garbage]
    fcomip
    jb      PopToGamma
    fldpi
    mov     dword [garbage], 2
    fimul   dword [garbage]
    fadd
    PopToGamma:
    fstp    dword [Gamma]
    ; ------------- Check first condition ---------------------
    CheckFirstCondition:
    ; ------------- first check if diffrence is bigger than 180 -------
    call checkDifferenceTerms
    fld     dword [droneAlpha]
    fld     dword [Gamma]
    fsub                                    ; (alpha - gamma)
    fabs                                    ; |(alpha - gamma)|
    fld     dword [beta]                  
    fcomip                                  ; (abs(alpha-gamma) < beta)   
    ja      Cond1IsTrue
    Cond1IsFalse:
    mov     dword [cond1], 0
    jmp     CheckSecondCondition
    Cond1IsTrue:
    mov     dword [cond1], 1
    ; ------------- Check second condition ---------------------
    CheckSecondCondition:
    fstp    dword [garbage]
    fld     dword [deltaX]
    fld     dword [deltaX]
    fmul                                    ; (x2-x1)^2
    fld     dword [deltaY]
    fld     dword [deltaY]
    fmul                                    ; (y2-y1)^2
    fadd                                    ; (y2-y1)^2+(x2-x1)^2
    fsqrt                                   ; sqrt((y2-y1)^2+(x2-x1)^2)
    fild    dword [maxDistance]
    fcomip                                  ; sqrt((y2-y1)^2+(x2-x1)^2) < d
    ja      Cond2IsTrue
    Cond2IsFalse:
    mov     dword [cond2], 0
    jmp     EndChecking
    Cond2IsTrue:
    mov     dword [cond2], 1
    EndChecking:
    fstp    dword [garbage]
    mov     dword eax, [cond1]
    mov     dword ecx, [cond2]
    mul     ecx
    mov     dword [canDestroy], eax
    ret
; -----------------------------------------------------
; Name: checkDifferenceTerms
; Purpose: if the difference in angles is greater than pi, we need to add 
; 2*pi to the smaller angle before doing the subtraction.
; This calculation would work as long as beta < pi/2, which we may assume.
; -----------------------------------------------------
checkDifferenceTerms:
    ; ---------------- moving alpha to degrees --------
    fld     dword [droneAlpha]
    fild    dword [Const180]
    fmul
    fldpi
    fdiv
    ; ---------------- moving gamma to degrees --------
    fld     dword [Gamma]
    fild    dword [Const180]
    fmul
    fldpi
    fdiv
    ; ---------------- Checking difference ------------
    fsub                                     ; alpha - gamma
    fabs                                     ; | (alpha - gamma) |
    fild    dword [Const180]
    fcomip
    ja      notAddingPi
    fstp    dword [garbage]
    ; ---------------- checking whos bigger -----------
    fld     dword [droneAlpha]
    fld     dword [Gamma]
    fcomi                                       ; cmp alpha, gamma
    ja      alphaIsBigger
    gammaIsBigger:
        fstp    dword [garbage]                 ; moving out gamma
        fstp    dword [garbage]                 ; its in degrees
        fld     dword [droneAlpha]
        fldpi
        mov     dword [garbage], 2
        fimul   dword [garbage]
        fadd
        fstp    dword [droneAlpha]              ; alpha = alpha + pi
        jmp endCheckTerms
    alphaIsBigger:
        fstp    dword [garbage]
        fstp    dword [garbage]
        fld     dword [Gamma]
        fldpi
        mov     dword [garbage], 2
        fimul   dword [garbage]
        fadd
        fstp    dword [Gamma]
        jmp endCheckTerms
    notAddingPi:
    fstp    dword [garbage]
    endCheckTerms:
    ret