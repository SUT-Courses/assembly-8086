; Program description

StSeg   Segment STACK 'STACK'
     DB 100H DUP (?)

StSeg   ENDS

DtSeg   Segment
    ; place data here
DtSeg   ENDS

CDSeg   Segment
    ASSUME  CS: CDSeg, DS: DtSeg, SS: StSeg

Start:
    MOV AX, DtSeg
    MOV DS, AX
    ; my code starts here


    ; input 4 numbers first rows are first
    call input_routine
    push DX
    call input_routine
    push DX
    call input_routine
    push DX
    call input_routine
    push DX

    ; store numbers in registers
    pop dx
    pop cx
    pop bx
    pop ax

    mul dx ; ax *= dx
    push ax; store in stack

    mov ax, bx ; ax = bx
    mul cx     ; ax = b*c
    neg ax     ; ax = -b*c
    pop dx     ; dx = a*d
    add ax, dx ; ax = ad -  bc
    call print



    ; my code ends here

    MOV AH, 4CH
    MOV AL, 0
    INT 21H


input_routine   PROC NEAR ; input int and store it in DX

    pushf
    push AX
    push BX
    push CX

    push 0000H   ; flag is 0

    xor CX, CX   ; CX = 0
    xor DX, DX           ; DX = 0
    input_number:
        mov AH, 07H              ; read char
        INT 21H

        CMP AL, 2DH              ; AL = '-'
        jz is_neg

        sub AL, 0DH              ; AL -= 13
        jz end                   ; if AL = '\n' go to end
        sub AL, 23H              ; AL -= 35  (in fact AL -= 48 to make binary from ascii)
        Xor AH, AH               ; AH = 0

        xchg AX, CX              ; prepare for mul
        xchg DX, AX              ; store valuable values in CX to retrieve after mul

        MOV BX, 000AH            ; BX =  10
        MUL BX                   ; DX, AX =  AX * 10
        xchg AX, DX              ; retrieve values of DX and AX
        xchg AX, CX              ; retrieve values of DX and AX
        ADD DX, AX               ; DX += AX
        JMP input_number         ; continue reading chars and convert them to int
    is_neg:
    push 01H                     ; flag for negative number  is 1
    JMP input_number             ; continue reading chars and convert them to int
    end:                         ; final
    POP AX                       ; AX is the flag
    CMP AX, 0001H                ; if AX == 1 then zf = 1
    jz negate_num                ; the number is negative

    POP CX
    POP BX
    POP AX
    POPF

    RET


   negate_num:
    POP AX
    not DX                       ; 1's comp
    ADD DX, 01H                  ; 2's comp

    POP CX
    POP BX
    POP AX
    POPF

    RET
input_routine           ENDP
    ; my code ends here



print PROC
    add ax,0 ; sign bit = 1 iff ax is neg
    jz is_zero  ; ax = 0

    js is_neg1 ; if is neg make it pos and print '-'
    continue:

    mov cx,0 ; cx = dx = 0
    mov dx,0
    division:
        ; if ax is zero
        cmp ax,0
        je print_each_digit ; time to print all elements in stack

        mov bx,0AH ; bx = 10
        div bx     ; ax //= bx
        add dx,48  ; remainder:dx += 48 [ascii representation]
        push dx    ; store in stack

        inc cx     ; how much digits does the number have?
        xor dx,dx  ; dx = 0
        jmp division ; continue division
    print_each_digit:

        cmp cx,0 ; if cx == 0 code is ended
        je end1 ; if is zero go to end
        pop dx ; pop digit


        ; interrupt to print
        mov ah,02h
        int 21h

        dec cx ; cx --
        jmp print_each_digit
     is_neg1:
        push ax ; save ax

        mov ah,02h ; print '-'
        mov dx, 45
        int 21h

        pop ax ; load ax
        neg ax ; negate ax
        jmp continue ; begin division
      is_zero:
        mov dx, 48
        ; interrupt to print
        mov ah,02h
        int 21h
        jmp end1
end1:
ret
print ENDP

CDSeg ENDS
