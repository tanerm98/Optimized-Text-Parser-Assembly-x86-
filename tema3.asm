section .bss
    w:     resb    1
    r:     resb    114753536  ;the string to be read
    t:     resd    1          ;argv

section .data
    u dd      0   ;search start position
    v dd      -19 ;search end position

section .text
global _start

;Function which converts a string to a number
;@dword[t] = the address of the string
;Returns in eax the resulting number.
a:
    dec ecx
    add dword[t], 4
    mov ebx, dword[t]
    mov ebx, [ebx]
    xor eax, eax
b:
    movzx edx, byte[ebx]
    sub edx, 0x00
    je c
    imul eax, 10
    sub edx, '0'
    add eax, edx
    inc ebx
    jmp b
c:
    ret    
    
_start:
    xor edi, edi
    mov ecx, [esp]  ;argc
    mov dword[t], esp ;argv
    add dword[t], 4
    dec ecx
    jnz d
     
    push 3
    pop eax
    xor ebx, ebx
    push r
    pop ecx
    push 32
    pop edx
    int 0x80
    push 4
    pop eax
    inc ebx
    int 0x80
    jmp q

d:  ;checks the parameters given in command line
    add dword[t], 4
    mov ebx, dword[t]
    mov ebx, [ebx]

    cmp byte[ebx+1], 'i'    ;input file name
    jne s
    dec ecx
    add dword[t], 4
    mov edi, dword[t]
    mov edi, [edi]
    jmp g
s:
    cmp byte[ebx+1], 's'    ;start position
    jne e
    call a
    mov dword[u], eax
    jmp g
e:    
    cmp byte[ebx+1], 'e'    ;end position
    jne f
    call a
    mov dword[v], eax
    jmp g
f:    
    dec ecx                 ;searched substring
    add dword[t], 4
    mov esi, dword[t]
    mov esi, [esi]  
g:
    dec ecx
    jnz d
    
    sub edi, 0      ;checks if to read from stdin or file
    jnz h
    
    push 3      ;reads from stdin
    pop eax
    xor ebx, ebx
    push r
    pop ecx
    push 0x6D70000
    pop edx
    int 0x80
    
    jmp j
    
h:
    push 5      ;opens file
    pop eax
    push edi
    pop ebx
    xor ecx, ecx
    xor edx, edx
    int 0x80

    push eax    ;reads from file
    pop ebx
    push 3
    pop eax
    push r
    pop ecx
    push 0x6D70000
    pop edx
    int 0x80
    
j:           ;the string has been read
    mov ebx, eax   
    
    mov eax, dword[v] ;sets the ending position
    
    cmp eax, -19    ;the default value for no ending
    je k
    
    mov edi, eax
    add edi, ecx
    mov al, 10
    
    mov edx, ecx
    std
    repne scasb
    cld
    mov ecx, edx
    inc edi
    
    mov dl, byte[esi] 
    mov byte[edi + 1], dl
    mov byte[edi + 2], 9
    
    add ecx, dword[u] ;sets the begginng position
    jmp l
    
k:
    mov dl, byte[esi]
    mov byte[ecx + ebx], 10
    mov byte[ecx + ebx + 1], dl  ;value for end of text
    mov byte[ecx + ebx + 2], 9
    
    add ecx, dword[u] ;sets the begginng position
l:
    inc esi
    mov edi, ecx
    mov byte[edi - 1], 10
    mov al, byte[esi - 1]

m:
    repne scasb
    cmp byte[edi], 9
    je q
    
    mov edx, esi         ;edi, ecx -> string,     esi, edx -> substring

    dec edi
    dec edx
n:
    inc edi
    inc edx
    
    mov bl, byte[edx]
    
    cmp bl, byte[edi]
    je n
    
    cmp bl, 0
    je o
    
    inc edi
    jmp m

o:
    dec edi
    mov al, 10
    
    mov edx, edi
    std
    repne scasb
    cld
    add edi, 2
    mov ecx, edi
    
    
    mov edi, edx
    mov edx, ecx
    repne scasb
    mov ecx, edx

    jmp p
    
p:
    mov edx, edi
    sub edx, ecx    ;calculates the number of bytes to write
                    ;starting from edi (start of line)
    push 4
    pop eax
    push 1
    pop ebx
    int 0x80
    
    mov al, byte[esi - 1]
    jmp m
    
q:
    pop ebp
    push 1
    pop eax
    xor ebx, ebx
    int 0x80