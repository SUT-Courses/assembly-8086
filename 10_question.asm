; Program description

StSeg   Segment STACK 'STACK' 
     DB 100H DUP (?) 
      
StSeg   ENDS

DtSeg   Segment       
    word_   DB  "hello2sajad18$"   ; end of the string must be declared
    num_obs   DB   0               ; flag 
    ten      DB  10                ; ten = 10 const
    ; place data here   
DtSeg   ENDS             
    
CDSeg   Segment
    ASSUME  CS: CDSeg, DS: DtSeg, SS: StSeg
       
Start:
    MOV AX, DtSeg
    MOV DS, AX
    ; my code starts here    
    lea  bx, word_                 ; bx = addr of word_
    call find_number               ; function call
    push ax                        ; store answer in stack
    
    call find_number               ; function call
    pop dx                         ; load previous ans in dx
    
    mul dx                         ; ax *= dx
    
    call print                     ; print ax
    
	; my code ends here
    MOV AH, 4CH
    MOV AL, 0
    INT 21H
    
find_number PROC   ; input address of the input string (bx)  ---->    returns first number in the string (ax)  and addr to start again (bx)
    
    pushf
    push cx
    push dx
    
    mov ax, 0                     ; ax = 0
    loop_fn:
          mov cl, DS:[bx]         ; cl <-- [ds + bx]
          
          cmp cl, 48              ; cmp cl with 0 ascii
          jns big_48              ; goto big_48 if cl-48>=0
          jmp loop_continue_fn    ; if not then continue loop
          
          big_48: 
          cmp cl, 58              ; cmp cl with 9 ascci 
          js is_number            ; goto is_number if cl - 58 < 0
          jmp loop_continue_fn    ; if not then continue loop
          
          is_number:
          mov num_obs, 1          ; num_obs = 1
          mov ch, 0               ; ch = 0
          mul ten                 ; ax *= 10
          sub cx, 48              ; cx -= 48 to convert ascii to number
          add ax, cx              ; ax += cx
          add bx, 1               ; bx += 1
          jmp loop_fn             ; goto loop_fn
          
          loop_continue_fn:   
          cmp num_obs, 1          ; num_obs - 1
          jz end_fn               ; if num_obs == 1 then goto end_fn
          add bx, 1               ; bx += 1
          jmp loop_fn             ; continue loop
          
    end_fn:   
    mov num_obs, 0                ; flag = 0
    pop dx                        
    pop cx
    popf  
    
ret
find_number  endP

 
print PROC   ; print value in ax    
    pushf
    push ax
    push bx
    push cx
    push dx
    
    add ax,0 ; sign bit = 1 iff ax is neg      
    jz is_zero  ; ax == 0 then jump
    
    
    js is_neg_print ; if is neg make it pos and print '-'
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
        je end ; if is zero go to end
        pop dx ; pop digit


        ; interrupt to print
        mov ah,02h
        int 21h

        dec cx ; cx --
        jmp print_each_digit
     is_neg_print:
        push ax ; save ax

        mov ah,02h ; print -
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
        jmp end
    end:  
    
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    
    ret
    print ENDP    
                    
                    

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
        jz is_neg_ir

        sub AL, 0DH              ; AL -= 13
        jz end_ir                   ; if AL = '\n' go to end
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
    is_neg_ir:
    push 01H                     ; flag for negative number  is 1
    JMP input_number             ; continue reading chars and convert them to int
    end_ir:                         ; final
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

CDSeg ENDS
END Start

                      
