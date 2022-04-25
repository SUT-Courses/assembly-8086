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
    
    mov [1500H],  DX             ; store in [1500hex]   1500H: DH, 1501H: DL        
     
    MOV AH, 4CH                  ; end of code interrupt
    MOV AL, 0                    ; zero return condition
    INT 21H                      ; the end
     
    negate_num:                  
    not DX                       ; 1's comp
    ADD DX, 01H                  ; 2's comp
    mov [1500H],  DX             ; store in [1500hex]   1500H: DL, 1501H: DH
    ; my code ends here
    
    MOV AH, 4CH
    MOV AL, 0
    INT 21H            
    
CDSeg ENDS
END Start

                      