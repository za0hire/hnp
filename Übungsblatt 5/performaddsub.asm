section .text

global performaddsub

performaddsub:
    push ebp
    mov ebp, esp 

    ; [ebp+8] -> a
    ; [ebp+12] -> b
    ; [ebp+16] -> operation
    ; [ebp+20] -> flags pointer

    mov eax, 0
    add ax, word [ebp+16] ;operant in ax laden für vergleich
    cmp ax, '-'  ;wenn char minus
    je subt      ;dann nach sub springen

    mov eax, 0
    add ax, word [ebp+8] ;a in ax schieben
    add ax, word [ebp+12] ;b draufaddieren
    jmp ende

subt:
    mov eax, 0
    add ax, word [ebp+8] ;a in ax schieben
    sub ax, word [ebp+12] ;b draufaddieren

ende:
    pushfd
    pop ecx
    mov edx, [ebp+20] ;flags in flags speicher für Zugriff in .c
    mov [edx], cx

    mov esp, ebp
    pop ebp

    ret

section .data
