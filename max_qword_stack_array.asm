section .data

scanf_format:
    db '%lld', 0

printf_format:
    db '%lld', 0xA, 0

section .text

extern printf
extern scanf
global main

; Address of the array of qwords to scan in rax
; Size of the array in rbx
; Returns the max value in rax
; Modifies rax, rcx, rdx and r8
max_qword:
    mov rdx, qword [rax]
    mov r8, 1
    .max_loop:
        cmp r8, rbx
        jge .loop_end

        mov rcx, qword [rax + 8 * r8]
        cmp rcx, rdx
        cmova rdx, rcx

        add r8, 1
        jmp .max_loop

    .loop_end:
    mov rax, rdx
    ret

main:
    push rbp
    mov rbp, rsp

    xor rax, rax
    push rax ; array size
    sub rsp, 8 ; align to 16 bytes
    mov rdi, scanf_format
    lea rsi, [rsp + 8]
    call scanf

    add rsp, 8 ; undo alignment
    pop r14
    
    ; ensure 16 byte alignment
    mov r12, r14
    test r12, 0x1
    jz .array_size_even
    add r12, 1
    .array_size_even:

    ; rsp - 8 * r12, r12 is the 16 byte aligned array size
    lea rax, [r12 * 8]
    sub rsp, rax ; alloc array_size qword elements
    mov r13, rsp ; array pointer
    xor r15, r15 ; loop counter

    push r12 ; save size of the stack array
    sub rsp, 8

    .scan_loop:
        cmp r15, r14
        jge .end_scan_loop

        mov rdi, scanf_format
        mov rsi, r13 
        lea rax, [8 * r15]
        add rsi, rax
        xor rax, rax
        call scanf

        add r15, 1
        jmp .scan_loop

    .end_scan_loop:

    mov rax, r13
    mov rbx, r14
    call max_qword

    add rsp, 8
    ; dealloc array
    pop r12
    shl r12, 3
    add rsp, r12

    mov rdi, printf_format
    mov rsi, rax
    xor rax, rax
    call printf
    
    mov rsp, rbp
    pop rbp
    mov rax, 0
    ret
