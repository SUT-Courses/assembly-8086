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
    push 5     ; n  
    push 2      ; r
    call C_nr   ; call function to calc C(n, r) and store it in ax
    call print  ; call print  function
	; my code ends here
    MOV AH, 4CH
    MOV AL, 0
    INT 21H
    
    
C_nr PROC  ; input two numbers in stack first r and second n, return c(n, r) in ax
     pop bx ; return addr
     
     pop cx ; r
     pop dx ; n
     
     push bx ; return address
     
     add cx, 0   ; cx += 0
     jz return_1 ; if cx == 0 goto return_1
     
     cmp dx, cx  ; dx-cx
     jz return_1 ; if dx - cx == 0goto return_1
           
     push dx     ;  store dx
     push cx     ;  store cx
           
     dec dx      ; dx--
     push dx     ; store new inputs   (n-1)
     push cx     ; store new inputs   (r)
     call C_nr   ; calc c(n-1, r)
     
     pop cx      ; load r
     pop dx      ; load n
     
     push ax     ; store ans of c(n-1, r)
     
     push dx     ; store dx
     push cx     ; store cx
     
     dec cx      ; r-1
     dec dx      ; n-1
     push dx     ; store new inputs (n-1)
     push cx     ; store new inputs (r-1)
     call C_nr   ; call function to calc c(n-1, r-1)
     
     pop cx      ; load r
     pop dx      ; load n
     
     pop bx      ; load ans of c(n-1, r)
     add ax, bx  ; c(n,r) = c(n-1, r) + c(n-1,r-1)
     
     jmp e       ; goto e
     
     return_1:
     mov ax, 1   ; ax = 1
    e:  
ret
C_nr  endP

 
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

                      
