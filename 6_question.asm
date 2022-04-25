; inverse bits circular 

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
    call input_routine ; input number  in DX
    mov AL, 0          ; AL = 0
    mov cl, 8          ; cl = 8
loop_: 

    CMP cl, 0          ; if cl == 0:
                       ; goto end_m
    jz end_m
    
    RCL DL, 1          ; left shift save carry
    RCR AL, 1          ; right shift load carry

    dec cl             ; cl --
    jmp loop_          ; continue loop
end_m:   

    mov AH, 0          ; AH = 0 for  print 
    call print         ; print AX or AL no difference
    ; my code ends here  
    MOV AH, 4CH
    MOV AL, 0
    INT 21H            
        
 
input_routine   PROC NEAR ; input int and store it in DX
    
    pushf
    push AX
    push BX
    push CX
       
    
    push 0000H   ; flaf is 0
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
        jmp end1
end1:
ret
print ENDP

    MOV AH, 4CH
    MOV AL, 0
    INT 21H            
    
CDSeg ENDS            
