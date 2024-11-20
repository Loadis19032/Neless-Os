%macro create_file 2
    pusha

    add byte [FILES], %1
    add byte [FILES], 0x0a
    add byte [FILES], 0x0d
    add byte [FILES], 0x0a
    add byte [FILES], 0x0d

    popa
%endmacro


%macro write_file 3
    push cx
    push ax

    mov ah, 0x03
    mov al, 1
    mov ch, %1
    mov cl, 0x01
    mov dh, 0x00  
    mov dl, 0x80   
    mov bx, %2
    int 0x13  

    add byte [FILES], %3
    add byte [FILES], 0x0a
    add byte [FILES], 0x0d
    add byte [FILES], 0x0a
    add byte [FILES], 0x0d

    pop cx
    pop ax
%endmacro

%macro read_file 3
    push cx
    push ax

    mov ah, 0x02
    mov al, 1
    mov ch, %1
    mov cl, 0x01
    mov dh, 0x00
    mov dl, 0x80
    mov bx, %2
    int 0x13

    add byte [FILES], %3
    add byte [FILES], 0x0a
    add byte [FILES], 0x0d
    add byte [FILES], 0x0a
    add byte [FILES], 0x0d

    pop cx
    pop ax
%endmacro


FILES db 0x0a, 0x0d