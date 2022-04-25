; Program description

StSeg   Segment STACK 'STACK' 
     DB 100H DUP (?) 
      
StSeg   ENDS

DtSeg   Segment  
    l1   dw  0              ; l1 = len of #1
    l2   dw  0              ; l2 = len of #2
    i    dw  0
    j    dw  0
arr_coef  dw 100 DUP(0)    ; final coef array
arr1      dw 50 DUP(0)     ; #1 coef
arr2      dw 50 DUP(0)     ; #2 coef
sum       dw 0            
q         dw 0
    ; place data here   
DtSeg   ENDS             
    
CDSeg   Segment
    ASSUME  CS: CDSeg, DS: DtSeg, SS: StSeg
       
Start:
    MOV AX, DtSeg
    MOV DS, AX
    ; my code starts here  
    call coef_calc        ; function call
	; my code ends here
    MOV AH, 4CH
    MOV AL, 0
    INT 21H
                  

coef_calc  PROC                  
    
    call input_routine          ; input l1
    mov l1, dx
    call input_routine          ; input l2
    mov l2, dx
    
    mov cx, 0                   ; counter set to 0
    loop_1:
        cmp cx, l1              ; if cx == 0:
        jns end_loop_one        ; break 
        
        call input_routine      ; input
        lea bx, arr1            ; bx = addr of arr#1
        ; store in  arr#1
        shl cx, 1               ; cx *= 2
        add bx, cx              ; bx += cx
        shr cx, 1               ; cx //= 2
        mov DS:[bx], dx         
        inc cx                  ; cx ++
        jmp loop_1              ; continue loop
        
   end_loop_one:    
   
    mov cx, 0                   ; counter set to 0
    loop_2:
        cmp cx, l2              ; if cx == 0:
        jns end_loop_two        ; break
        
        call input_routine      ; input
        lea bx, arr2            ; addr of arr#2
        shl cx,1                ; cx *= 2
        add bx, cx              ; bx += cx
        shr cx,1                ; cx /=2
        mov DS:[bx], dx         ; store in  [bx]
        inc cx                  ; cx++
        jmp loop_2              ; continue loop
        
   end_loop_two:
      
      
     ; multiplication           
    loop_out:    
        mov bx, i              ; bx = i
        cmp l2, bx             ; if l2 - bx  == 0
        jz  end_loop_out       ; goto end_loop_out
                     
        lea bx, arr2           ; bx = addr of arr2
        shl i,1                ; i *= 2
        add bx, i              ; bx += i
        shr i,1                ; i /= 2
        mov cx, DS:[bx]        ; cx = [bx]
        loop_in:      
              mov bx, j        ; bx = j
              cmp l1, bx       ; if l1 - bx  == 0
              jz end_loop_in   ; goto end_loop_in
              
              lea bx, arr1     ; bx = addr of arr1
              shl j,1          ; j *= 2
              add bx, j        ; bx += j
              shr j,1          ; j /= 2
              mov dx, DS:[bx]  ; dx = [bx]
              
              mov ax, cx       ; ax = cx
              mul dx           ; dx = ax*dx
              
              lea bx, arr_coef ; bx = addr of arr_coef
              shl i,1          ; i *= 2  , j *= 2
              shl j,1
              add bx,i         ; bx += j + i
              add bx,j
              shr i, 1         ; i /= 2, j /= 2
              shr j, 1
             
              add DS:[bx], ax  ; [bx] = ax
              
              add j, 1         ; j += 1
              jmp loop_in      ; continue inner loop
        end_loop_in:         
         mov j, 0              ; j = 0
         add i, 1              ; i += 1
         jmp loop_out          ; continue outer loop
    end_loop_out:     
    
    
    
    mov cx, 0                  ; cx = l1 + l2
    add cx, l1
    add cx, l2 
    
    mov sum, cx                ; sum = (cx - 1)* 2
    sub sum,1
    shl sum,1
    
    mov cx, 0                  ; cx = 0
          
          
    loop_3:  
       cmp cx, sum             ; if cx == sum
       jz end_func_cc          ; end of func
             
       lea bx, arr_coef        ; bx = addr of arr_coef
       add bx, cx              ; bx += cx
       mov ax, DS:[bx]         ; ax = [bx]
       
       push cx                 ; store cx in the stack
       call print              ; print ax
       
       mov dl, 10              ; print new line
       mov ah, 2
       int 21h  
       
       pop cx                  ; load cx from stack
       add cx, 2               ; cx += 2
       jmp loop_3              ; continue loop
        
                     
                     
    end_func_cc:
ret
coef_calc ENDP
print PROC   ; print value in ax
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

                      
