; Program description

StSeg   Segment STACK 'STACK' 
     DB 100H DUP (?) 
      
StSeg   ENDS

DtSeg   Segment 
merged   DW 100 DUP(?)  
arr1     DW -1, 2, 3, 10
arr2     DW  1, 4, 11
addr1    DW ?                ; address of array #1
addr2    DW ?                ; address of array #2
 
len1 DW 4    ; len of array #1 = 4
len2 DW 3    ; len of array #1 = 3

addr    DW ? ; tmp address of final array
addr_return  DW ?  ; address of final array
    ; place data here   
DtSeg   ENDS             
    
CDSeg   Segment
    ASSUME  CS: CDSeg, DS: DtSeg, SS: StSeg
       
Start:
    MOV AX, DtSeg
    MOV DS, AX
    ; my code starts here  
    lea ax, arr1        ; ax = addr of arr1
	push ax             ; store ax in stack
	push len1           ; store len1 in stack
	
	lea ax, arr2        ; ax = addr of arr2
	push ax             ; store ax in stack
	push len2           ; store len2 in stack
	
	lea ax, merged      ; ax = addr of final array
	call merge          ; call function to merge two sorted arrays
	          
	mov bx, ax          ; store return address into bx
	mov ax, [bx]        ; ax = [return address]
	call print          ; print first element of the stored array
	; my code ends here
    MOV AH, 4CH
    MOV AL, 0
    INT 21H       
        
merge PROC ; input addr1, len1, addr2, len2    in the stack return address of the merged sorted array in ax
    mov BP, SP              ; BP = SP

    mov addr, ax            ; addr = ax (ax = final array addr)
    mov addr_return,  ax    ; addr_return = ax
     
    mov ax, SS:[BP+2]       ; ax = len
    mov len2, ax            ; len2 = ax
    
    mov ax, SS:[BP+4]       ; ax = address of arr2
    mov addr2, ax           ; addr2 = ax
 
    mov ax, SS:[BP+6]       ; ax = len
    mov len1, ax            ; len1 = ax
    
    mov ax, SS:[BP+8]       ; ax = address of arr1
    mov addr1, ax           ; addr1 = ax
     
    loop_m:  
        mov ax, len1        ; ax = len1
        mov bx, len2        ; bx = len2
        
        add ax, bx          ; if ax == bx == 0 then ax = 0
        jz end_merge        ; if ax == 0 goto end_merge
        
        mov ax, len1        ; ax = len1
        add ax, 0           ; if ax == 0 goto bx_m  
        jz bx_m
        
        add bx, 0           ; bx += 0
        jz  ax_m            ; if bx == 0 goto ax_m
        
                          
        mov bx, addr1           
        mov ax, DS:[bx]     ; ax = first element not visited of arr1
        
        mov bx, addr2
        mov bx, DS:[bx]     ; bx = first element not visited of arr2
        
        cmp ax, bx          ; if ax - bx < 0 then sign bit is 1
        
        jns bx_m            ; if not signed then goto bx_m
        ax_m: 
        
        push bx             ; store bx in stack
        mov bx, addr1       ; bx = addr1
        mov ax, DS:[bx]     ; ax = first element of array #1
        pop bx              ; retreive bx
             
        push bx             ; store bx in stack
        mov bx,addr         ; bx = addr
        mov DS:[bx], ax     ; [DS+bx] = ax
        pop bx              ; retreive bx
        
        add addr1, 2        ; addr1 += 2
        sub len1, 1         ; len1 --
        jmp cont_m          ; continue loop
        bx_m:    
        mov bx, addr2       ; bx = addr2
        mov bx, DS:[bx]     ; bx = [DS + bx]   ; first element of second array
        
        push bx             ; store in stack
        mov cx, bx          ; cx = bx
        mov bx,addr         ; bx = addr
        mov DS:[bx], cx     ; [DS + bx] = cx
        pop bx              ; retreive bx
        
        add addr2, 2        ; addr2 += 2
        sub len2, 1         ; len2 ++
        cont_m:             
        add addr, 2         ; addr += 2
        jmp loop_m          ; continue loop
        end_merge:
    mov ax, addr_return     ; ax = addr_return 
       
ret
merge ENDP  

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

                      
