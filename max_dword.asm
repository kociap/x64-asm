section .data

array:
    dd 0x1
    dd 0x2
    dd 0x3
    dd 0x4
    dd 0x22
    dd 0xA
    dd 0x11
    dd 0xF5
    dd 0x2
    dd 0x10
    dd 0x0

format_str:
    db '%d', 0xA, 0

section .text

extern printf
global main

; Address of the array of dwords to scan in rax
; Size of the array in rbx
; Returns the max value in rax
; Modifies rax, rcx and r8
max_dword:
    mov edx, dword [rax]
    mov r8, 1
    .max_loop:
        cmp r8, rbx
        jge .loop_end

        mov ecx, dword [rax + 4 * r8]
        cmp ecx, edx
        cmova edx, ecx

        add r8, 1
        jmp .max_loop

    .loop_end:
    movsxd rax, edx
    ret

main:
    push rbp
    mov rbp, rsp

    mov rax, array
    mov rbx, 11
    call max_dword

    mov rdi, format_str
    mov rsi, rax
    xor rax, rax
    call printf
    
    mov rsp, rbp
    pop rbp
    mov rax, 0
    ret
