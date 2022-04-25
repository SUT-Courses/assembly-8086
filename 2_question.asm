; Program description

StSeg   Segment STACK 'STACK'
     DB 100H DUP (?)

StSeg   ENDS

DtSeg   Segment
    data   dw -130
    ; place data here
DtSeg   ENDS

CDSeg   Segment
    ASSUME  CS: CDSeg, DS: DtSeg, SS: StSeg

Start:
    MOV AX, DtSeg
    MOV DS, AX
    ; my code starts here

   	mov ax,data ; ax = [data]
    call print  ; call print routine

	; my code ends here
    MOV AH, 4CH
    MOV AL, 0
    INT 21H

print PROC
    add ax,0 ; sign bit = 1 iff ax is neg      
    jz is_zero  ; ax == 0 then jump
    
    
    js is_neg ; if is neg make it pos and print '-'
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
     is_neg:
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

CDSeg ENDS
END Start
