; invert lower/upper in a string

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
    
    char_input:     ; loop to print string 
     mov AH, 07H    ; input char
     INT 21H    
     
     CMP al, 13     ; if it is enter then the loop should be ended
     jz end         ; zf == 0 => goto end
     
     push ax        ; ax saved
     sub al, 65     ; al -= 65
     mov bl, al     ; bl = al
     pop ax         ; ax loaded
     push ax        ; ax saved
     sub al, 90     ; al -= 90
     neg al         ; al *= -1
     mov bh, al     ; bh = al
     pop ax         ; ax is loaded
     or bl,bh       ; bl = bl or bh
     neg bl         ; bl *= -1
     js low         ; if signed then 64<al<91 so goto low
     
     push ax        ; ax saved
     sub al, 97     ; al -= 97
     mov bl, al     ; bl = al
     pop ax         ; ax loaded
     push ax        ; ax saved
     sub al, 122    ; al -= 122
     neg al         ; al *= -1
     mov bh, al     ; bh = al
     pop ax         ; ax loaded
     or bl,bh       ; bl = bl or bh
     neg bl         ; bl *= -1
     js up          ; if signed then 96<al<123 so goto up           
         
     mov ah, 02H    ; print if not alphabetic char
     mov dl, al  
     int 21H
  
     jmp char_input ; continue loop
     
up:
     call upper      ; make char upper case
     jmp char_input  ; continue loop
low:  
     call lower      ; make char lower case
     jmp char_input  ; continue loop
end:     
    ; end of code
    MOV AH, 4CH
    MOV AL, 0
    INT 21H            
     
 
upper proc
    sub al, 20h      ; al -= 32
    mov ah, 02H      ; print char
    mov dl, al
    int 21H    
ret        
upper endp        

lower proc
    add al, 20H      ; al += 32
    mov ah, 02H      ; print char
    mov dl, al
    int 21H    
ret        
lower endp    
 
CDSeg ENDS            
