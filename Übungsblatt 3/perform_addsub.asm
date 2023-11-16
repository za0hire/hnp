section .text

global _addsub

perform_addsub:
    push ebp
    mov ebp, esp 

    ; [ebp+8] -> a
    ; [ebp+12] -> b
    ; [ebp+16] -> operation
    ; [ebp+20] -> flags pointer

    mov eax, 0
    add ax, word [ebp+16] ;operant in ax laden für vergleich
    cmp ax, 45  ;wenn char minus
    je sub      ;dann nach sub springen

    mov eax, 0
    add ax, word [ebp+8] ;a in ax schieben
    add ax, word [ebp+12] ;b draufaddieren
    jmp ende

sub:
    mov eax, 0
    add ax, word [ebp+8] ;a in ax schieben
    sub ax, word [ebp+12] ;b draufaddieren

ende:
    pushfd
    pop ecx
    mov edx, word [ebp+20]
    mov adx, cx

    mov esp, ebp
    pop ebp

    ret

section.data