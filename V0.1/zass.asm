BITS 64
section .bss
    zin resb 4096
    zode resb 4096
    zdata resb 4096
    ende resq 256
    numvar resq 256
    varnme resq 512
    elf resb 176
    texout resb 256

section .data
    ;elf
    elfc:
        ;[0 - 15] e_ident
        db 0x7F, 'E', 'L', 'F', 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
        ;[16-63] resto do cabeçalho elf
        dw 2, 62
        dd 1
        dq 0x4000B0
        dq 64
        dq 0
        dd 0
        dw 64, 56, 2, 0, 0, 0
        ;[64 - 119] cabeçalho do programa
        dd 1, 5
        dq 0, 0x400000, 0x400000
        dq 0 ;zerado para ser alterado posteriormente
        dq 0 ;zerado para ser alterado posteriormente
        dq 0x1000
        ;dados
        dd 1, 6
        dq 0
        dq 0x600000, 0x600000
        dq 0
        dq 0
        dq 0x1000
    ;no inferno
    ;causar destruição
    ;o exterminio é a solução
    ;ouça o solo da guitarra
    ;que causa devastação
    ;sua princesa mimada
    ;os demonios são uma praga
    ;não serão mais ameaça
    ;se preparem para o dia
    ;em que todos vão morrer
    ;pecadores com a vida fodida
    ;quero que vá se foder
    ;sou a pica primordial
    ;igual a mim não tem igual
    ;não, sou Adão
    ql db 0x0A
    sunome db "Código: "
    tsize EQU $ - sunome
    opcr db 0xB8, 0xBB, 0xB9, 0xBA, 0xBF, 0xBE
    lrg db 'A', 'B', 'C', 'D', 'P', 'E'
    ;Low Letter List
    lls db 'A', 'B', 'C', 'D', 'P', 'E'
    secsz EQU $ - lrg
    arq db "arqv", 0
    sec_info db "info", 0
    id_info dw 1
    sec_every db "every", 0
    id_every dw 2
    tbl_end db 0
    tbl_secs dq sec_info, sec_every, 0
    tbl_ids dw 1, 2
    sec_id db 2
    kk dq 0x600000

section .text
    global _start
reg_edr:
    push rax
    push rbx
    push rcx
    mov rcx, [numvar]

    mov rax, 0x600000
    add rax, r14

    shl rcx, 3

    mov [ende+rcx], rax

    mov rcx, [numvar]
    inc rcx
    mov [numvar], rcx

    pop rcx
    pop rbx
    pop rax
    ret
spaceKill:
    cmp byte [rdi+rcx], " "
    je .space
    jmp .end
    .space:
        inc rcx
        cmp byte [rdi+rcx], " "
        je .space
    .end:
        ret
criarELF:
    xor rcx, rcx
    .ctrlct:
        cmp rcx, 176
        jae .adjust
        mov al, [elfc+rcx]
        mov [elf+rcx], al
        inc rcx
        jmp .ctrlct
        .adjust:
            syscall
            mov rax, r11
            add rax, 176

            mov [elf+96], rax
            mov [elf+104], rax
            ;seg 2 dados
            mov qword [elf+128], 0x1000

            mov qword [elf+136], 0x600000
            mov qword [elf+144], 0x600000

            mov rax, r14
            mov [elf+152], rax
            mov [elf+160], rax

    ret
pref:
    cmp r13, 1
    jne .end
    mov byte[zode+r10], 0x48
    inc r10
    inc r11
    .end:
        ret
regs:
    mov r12, -1
    xor r13, r13
    cmp byte [rdi+rcx], 'Z' ;64 e 32 bits Z -> Zanon
    je .zreg
    jmp .end
    .zreg:
        inc rcx
        cmp byte[rdi+rcx], 'H' ;64 bits R -> high
        je .high
        cmp byte[rdi+rcx], 'L' ;32 bits L -> Low
        je .low
        jmp .end
        .low:
            ;limpa pra evitar prefixos
            xor r13, r13
            ;passa a letra pro al de comparação
            inc rcx
            mov al, [rdi+rcx]
            xor r12, r12
            .compl:
                ;compara se já leu tudo
                cmp r12, secsz
                jae .errol
                ;compara a letra com a lista de letras
                cmp al, [lls+r12]
                je .encl
                inc r12
                jmp .compl
                .errol:
                    mov r12, -1
                    jmp .end
                .encl:
                    inc rcx
                    jmp .end
        .high:
            ;indica 64 bits
            mov r13, 1
            ;bota a letra no al para comparar
            inc rcx
            mov al, [rdi+rcx]
            xor r12, r12
            .comph:
                ;compara se já leu tudo
                cmp r12, secsz
                jae .erroh
                ;compara a letra com a lista de letras
                cmp al, [lrg+r12]
                je .ench
                inc r12
                jmp .comph
                .erroh:
                    mov r12, -1
                    jmp .end
                .ench:
                    inc rcx
                    jmp .end
    .end:
        ret
tpnd:
    xor rax, rax
    .Loop:
        movzx r8d, byte [rdi+rcx]
        cmp r8b, '0'
        jb .end
        cmp r8b, '9'
        ja .end

        sub r8b, '0'

        lea rax, [rax + rax*4]
        shl rax, 1

        or al, r8b
        inc rcx
        jmp .Loop
    .end:
        ret
tpnh:
    xor rax, rax
    ;saudades do int a cin<<a
    .loopas:
        movzx r8d, byte [rdi+rcx]

        ;vê se é decimal
        cmp r8b, '0'
        jb .fim
        cmp r8b, '9'
        jbe .decim

        ;compara se o valor está maiusculo
        cmp r8b, 'A'
        jb .fim
        ;encerra se for menor que 'A' na ASCII
        cmp r8b, 'F'
        jbe .hexmasc

        ;compara se está minusculo
        cmp r8b, 'a'
        jb .fim
        ;termina se for menor que 'a'
        cmp r8b, 'f'
        ja .fim
        ;cria uma faixa entre a e f
        .hexmin:
            sub r8b, 'a' - 10
            jmp .acum
        .hexmasc:
            sub r8b, 'A' - 10
            jmp .acum
        .decim:
            sub r8b, '0'
        .acum:
            shl rax, 4
            or al, r8b
            inc rcx
            jmp .loopas
        .fim:
            ret
valueAtrb:
    .read:
        ;ignora o espaço
        inc rcx
        .jmpsp:
            cmp byte [rdi+rcx], ' '
            jne .cnt
            inc rcx
            jmp .jmpsp
        .cnt:
        ;verifica se já está em hexadecimal
        cmp byte [rdi+rcx], '0'
        je .hexc
        jmp .deci
        .hexc:
            cmp byte [rdi+rcx+1], 'x'
            je .vhex
            cmp byte [rdi+rcx+1], 'X'
            je .vhex
            jmp .deci
            .vhex:
                inc rcx
                inc rcx
                call tpnh
                jmp .whex
            .deci:
                call tpnd
                jmp .whex
            .whex:
                cmp r13, 0
                je .v32
                cmp r13, 1
                je .v64
                jmp .end
            .v64:
                mov r9d, 8
                .loov:
                    cmp r9d, 0
                    jle .end
                    mov dl, al
                    mov [zode+r10], dl
                    inc r10
                    inc r11

                    shr rax, 8
                    dec r9d
                    jmp .loov
                jmp .end
            .v32:
                mov r9d, 4
                .loov32:
                    cmp r9d, 0
                    jle .end
                    mov dl, al
                    mov [zode+r10], dl
                    inc r10
                    inc r11

                    shr rax, 8
                    dec r9d
                    jmp .loov32
                jmp .end
            .end:
                ret
write:
    cmp byte [sec_id], 1
    je .infow
    cmp byte [sec_id], 2
    je .everyw
    jmp .end
    .end:
        ret
    .infow:
        call reg_edr
        mov [zdata+r14], al
        inc r14
        jmp .end
    .everyw:
        mov [zode+r10], al
        inc r10
        inc r11
        jmp .end

lista:
    xor r9b, r9b
    .looping:
        cmp rcx, r15
        jae .end
        cmp byte [rdi+rcx], '.'
        je .cmpsec
        cmp byte [sec_id], 2
        je .scev
        cmp byte [sec_id], 1
        je .scin
        inc rcx
        jmp .looping
        .scin:
            cmp byte [rdi+rcx], 'D'
            je .cmpd
            inc rcx
            jmp .looping

        .scev:
            cmp byte [rdi+rcx], ','
            je .vle
            
            cmp byte [rdi+rcx], 'G'
            je .cmpg
            cmp byte [rdi+rcx], 'R'
            je .cmpr
            inc rcx
            jmp .looping
        
        .cmpsec:
            inc rcx
            xor r8, r8
            .init:
                mov rbx, [tbl_secs+r8*8] 
                cmp rbx, 0
                je .unfound
                xor rdx, rdx
                .cmp_bytes:
                    mov al, [rbx+rdx]
                    lea r9, [rdx+rcx]
                    mov r9b, [r9+rdi]
                    cmp al, 0
                    je .endin

                    cmp al, r9b
                    jne .nxt
                    inc rdx
                    jmp .cmp_bytes
                    .endin:
                        cmp r9b, ' '
                        je .suc
                        cmp r9b, 0x0A
                        je .suc
                        cmp r9b, 0
                        je .suc
                        jmp .nxt
                        .suc:
                            mov ax, word [tbl_ids + r8*2]
                            mov word [sec_id], ax
                            add rcx, rdx
                            jmp .looping
                    .nxt:
                        inc r8
                        jmp .init
                .unfound:
                    mov ax, -1
                    jmp .looping
        .mtm:
            cmp byte [rdi+rcx], 'a'
            jb .avcn
            cmp byte [rdi+rcx], 'z'
            jbe .conv
            jmp .avcn
            .conv:
                mov al, byte [rdi+rcx]
                sub al, 0x20
                mov [rdi+rcx], al
            .avcn:
                inc rcx
                jmp .looping
        .cmpd:
            inc rcx
            cmp byte [rdi+rcx], 'B'
            je .cmpdb
            jmp .looping
            .cmpdb:
                inc rcx
                call spaceKill
                inc rcx
                .strg:
                    mov al, [rdi+rcx]

                    cmp al, '"'
                    je .ter
                    cmp al, 0x0A
                    je .ter
                    cmp al, 0
                    je .ter

                    mov [zdata + r14], al
                    inc r14
                    inc rcx
                    jmp .strg

                    .ter:
                        inc rcx
                        jmp .looping
        .vle:
            call valueAtrb
            jmp .looping
        .cmpg:
            inc rcx
            cmp byte [rdi+rcx], 'O'
            je .cmpgo
            jmp .looping
            .cmpgo:
                inc rcx
                cmp byte [rdi+rcx], ' '
                je .go
                cmp byte [rdi+rcx], 0x0A
                je .go
                jmp .looping
                .go:
                    inc rcx
                    call regs
                    cmp r12, -1
                    je .danaochefia
                    mov al, [opcr+r12]
                    call pref
                    call write
                    jmp .looping
                    .danaochefia:
                        jmp .looping
        .cmpr:
            inc rcx
            cmp byte [rdi+rcx], 'U'
            je .cmpru
            .cmpru:
                inc rcx
                cmp byte [rdi+rcx], 'N'
                je .cmprun
                .cmprun:
                    inc rcx
                    cmp byte [rdi+rcx], 'S'
                    je .cmpruns
                    .cmpruns:
                        inc rcx
                        cmp byte [rdi+rcx], 'Y'
                        je .cmprunsy
                        .cmprunsy:
                            inc rcx
                            cmp byte [rdi+rcx], 'S'
                            je .cmprunsys
                            .cmprunsys:
                                mov al, 0x0F
                                call write
                                mov al, 0x05
                                call write
                                inc rcx
                                jmp .looping
            jmp .looping
        .end:
            ret

_start:
    cmp qword [rsp], 2
    jae .chc
    mov rbx, arq
    jmp .cnt
    .chc:
        mov rbx, [rsp+16]
    .cnt:
    
    push rbx
    ;input
    mov rax, 0
    mov rdi, 0
    mov rsi, zin
    mov rdx, 4096
    syscall

    ;salvando o tanto de bytes lidos
    mov r15, rax

    ;aqui começa a leitura
    xor rcx, rcx ;limpar rcx
    xor r10, r10 ;limpar r10
    xor r11, r11 ;limpar r11
    mov rdi, zin ;coloca o zin no rdi para ter o que ler
    call lista ;começa a leitura

    pop rdi
    ;abre o arquivo
    mov rax, 2
    mov rsi, 577
    mov rdx, 0o755
    syscall

    ;salvando o caminho
    mov r8, rax

    ;printando o cabeçalho
    call criarELF
    mov rax, 1
    mov rdi, r8
    mov rsi, elf
    mov rdx, 176
    syscall

    ;printando o código por escrito
    mov rax, 1
    mov rdi, r8
    mov rsi, zode
    mov rdx, r11
    syscall

    ;Organizando os dados
    mov rax, 8
    mov rdi, r8
    mov rsi, 0x1000
    mov rdx, 0
    syscall

    ;dados
    mov rax, 1
    mov rdi, r8
    mov rsi, zdata
    mov rdx, r14
    syscall

    ;fecha arquivo
    mov rax, 3
    mov rdi, r8
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
    ; depois dessa, vou agradecer