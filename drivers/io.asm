COLOR_BLACK equ 0x0
COLOR_BLUE equ 0x1
COLOR_GREEN equ 0x2
COLOR_CYAN equ 0x3
COLOR_RED equ 0x4
COLOR_MAGENTA equ 0x5
COLOR_BROWN equ 0x6
COLOR_LIGHT_GRAY equ 0x7
COLOR_DARK_GRAY equ 0x8
COLOR_LIGHT_BLUE equ 0x9
COLOR_LIGHT_GREEN equ 0x10
COLOR_LIGHT_CYAN equ 0x11
COLOR_LIGHT_RED equ 0x12
COLOR_LIGHT_MAGENTA equ 0x13
COLOR_YELLOW equ 0x14
COLOR_WHITE equ 0x15

COLOR_BLACK_TEXT db "0x0", 0
COLOR_BLUE_TEXT db "0x1", 0
COLOR_GREEN_TEXT db "0x2", 0
COLOR_CYAN_TEXT db "0x3", 0
COLOR_RED_TEXT db "0x4", 0
COLOR_MAGENTA_TEXT db "0x5", 0
COLOR_BROWN_TEXT db "0x6", 0
COLOR_LIGHT_GRAY_TEXT db "0x7", 0
COLOR_DARK_GRAY_TEXT db "0x8", 0
COLOR_LIGHT_BLUE_TEXT db "0x9", 0
COLOR_LIGHT_GREEN_TEXT db "0x10", 0
COLOR_LIGHT_CYAN_TEXT db "0x11", 0
COLOR_LIGHT_RED_TEXT db "0x12", 0
COLOR_LIGHT_MAGENTA_TEXT db "0x13", 0
COLOR_YELLOW_TEXT db "0x14", 0
COLOR_WHITE_TEXT db "0x15", 0

CODE_PANIC_SYSTOOL db "SYSTOOL ERROR", 0
CODE_PANIC_BOOT db "BOOT ERROR", 0
CODE_PANIC_DISK db "DISK ERROR", 0
CODE_PANIC_VIDEO db "VIDEO ERROR", 0
CODE_PANIC_DKEY db "DKEY ERROR", 0
CODE_PANIC_UNKNOWN db "UNKNOWN ERROR", 0

clear_screen:
    pusha

    mov ah, 0x00
    mov al, 0x03
    int 0x10

    popa
    ret  


set_screen_color:
    pusha

    mov ah, 0xB
    mov bh, 0x00
    mov bl, ch
    int 0x10

    popa
    ret


new_line:
    push ax
    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10
    pop ax
    ret


scrool_down:
    mov ah, 0x07
    mov al, 1
    mov bh, 0x00
    int 0x10
    ret


comp:
    push bx
    push si
    push ax

    mov cx, 1

compare:
    mov ah, [bx]
    cmp [si], ah
    jne not_equal
    cmp ah, 0
    je equal
    
    inc si
    inc bx

    jmp compare

not_equal:
    mov cx, 0

equal:
    pop ax
    pop si
    pop bx
    ret


out_char:        ; Вывод символа на экран
    push ax
    mov ah, 0x0e
    mov al, bl   ; В регистр bl мы заранее положили символ на вывод
    int 0x10
    pop ax
    ret


out_string:      
    push ax
    mov ah, 0x0e
    call __out_string_next_char
    pop ax
    ret

__out_string_next_char:
    mov al, [si]  
    cmp al, 0         
    jz __out_string_if_zero
    int 0x10
    inc si             
    jmp __out_string_next_char 

__out_string_if_zero:
    ret                  

in_char:     
    push bx
    mov ah, 0
    int 0x16    ; Символ сохранён в регистр al
    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x07
    int 0x10    ; Вывод введённого символа на экран
    pop bx
    ret


clear_buffer:
    ; si - Адрес буфера
    ; bx - Количество байт на очистку
    push cx
    mov cx, 0

__clear_buffer_loop:
    cmp cx, bx
    je __clear_buffer_end_loop
    mov byte [si], 0
    inc si
    inc cx
    jmp __clear_buffer_loop

__clear_buffer_end_loop:
    pop cx
    ret


in_textarea:
    push ax
    push cx
    xor cx, cx

__input_string_loops:
    mov ah, 0
    int 0x16
    cmp al, 0x0d            ; Если пользователь нажал Enter, то обрабатываем это событие
    je __input_string_enters
    cmp al, 0x08            ; Если пользователь нажал Backspace, то обрабатываем это событие
    je __input_string_backspaces

    cmp ah, 0x01
    je exit_textarea

    mov [si], al
    inc si
    inc cx

    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x07
    int 0x10
    cmp cx, 2048              ; Если Пользователь ввёл 255 символов
    je __input_string_enters   ; То прыгаем в событие нажатия на Enter
    jmp __input_string_loops

exit_textarea:
    call clear_screen

    mov word [textarea_exit], 1

    ret

__input_string_enters:
    mov ah, 0x0e ; Номер функции int 0x10 - вывод символа
    mov al, 0x0d ; Перевод каретки на новую строку
    mov bh, 0
    mov bl, 0x07 ; Цвет выводимого символа 0 - чёрный фон 7 - белый символ
    int 0x10
    mov al, 0xa  ; Перевод каретки в начало строки
    int 0x10

    mov byte [si], 0 ; Помещаем в конец строки 0
    
    jmp __input_string_loops

__input_string_backspaces:
    cmp cx, 0
    je __input_string_loops ; Если это 0 символ, то возвращаемся в цикл ввода
    mov ah, 0x0e            ; Иначе, эмулируем нажатия на Backspace, Пробел, Backspace
    mov al, 0x08            ; Backspace
    int 0x10
    mov al, 0x20            ; Пробел
    int 0x10
    mov al, 0x08            ; Backspace
    int 0x10

    mov byte [si], 0
    dec si                 ; Уменьшаем si на 1. si - адрес cx - номер введённого символа. Уменьшаем два этих регистра на один
    dec cx
    jmp __input_string_loops


in_string:             ; Пользовательский ввод строки. Адрес буфера хранится в si
    push ax
    push cx
    xor cx, cx

__input_string_loop:
    mov ah, 0
    int 0x16
    cmp al, 0x0d            ; Если пользователь нажал Enter, то обрабатываем это событие
    je __input_string_enter
    cmp al, 0x08            ; Если пользователь нажал Backspace, то обрабатываем это событие
    je __input_string_backspace

    mov [si], al
    inc si
    inc cx

    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x07
    int 0x10
    cmp cx, 255               ; Если Пользователь ввёл 255 символов
    je __input_string_enter   ; То прыгаем в событие нажатия на Enter
    jmp __input_string_loop

__input_string_enter:
    mov ah, 0x0e ; Номер функции int 0x10 - вывод символа 
    mov al, 0x0d ; Перевод каретки на новую строку
    mov bh, 0
    mov bl, 0x07 ; Цвет выводимого символа 0 - чёрный фон 7 - белый символ
    int 0x10
    mov al, 0xa  ; Перевод каретки в начало строки
    int 0x10

    mov byte [si], 0 ; Помещаем в конец строки 0
    pop cx
    pop ax
    ret

__input_string_backspace:
    cmp cx, 0
    je __input_string_loop ; Если это 0 символ, то возвращаемся в цикл ввода
    mov ah, 0x0e            ; Иначе, эмулируем нажатия на Backspace, Пробел, Backspace
    mov al, 0x08            ; Backspace
    int 0x10
    mov al, 0x20            ; Пробел
    int 0x10
    mov al, 0x08            ; Backspace
    int 0x10

    mov byte [si], 0
    dec si                 ; Уменьшаем si на 1. si - адрес cx - номер введённого символа. Уменьшаем два этих регистра на один
    dec cx
    jmp __input_string_loop 



reboot_computer:
    jmp 0xFFFF:0000h



shutdown_computer:
    mov ax, 0x1000
    mov ax, ss
    mov sp, 0xf000
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15

    jc PANIC_SYSTOOL
    ret



SET_BLACK_BG:
    mov ch, COLOR_BLACK
    call set_screen_color

SET_BLUE_BG:
    mov ch, COLOR_BLUE
    call set_screen_color

SET_GREEN_BG:
    mov ch, COLOR_GREEN
    call set_screen_color

SET_CYAN_BG:
    mov ch, COLOR_CYAN
    call set_screen_color

SET_RED_BG:
    mov ch, COLOR_RED
    call set_screen_color

SET_MAGENTA_BG:
    mov ch, COLOR_MAGENTA
    call set_screen_color

SET_BROWN_BG:
    mov ch, COLOR_BROWN
    call set_screen_color

SET_YELLOW_BG:
    mov ch, COLOR_YELLOW
    call set_screen_color


PANIC_SYSTOOL:
    mov bx, CODE_PANIC_SYSTOOL
    call PANIC_CALL
    ret

PANIC_DISK:
    mov bx, CODE_PANIC_DISK
    call PANIC_CALL
    ret

PANIC_BOOT:
    mov bx, CODE_PANIC_BOOT
    call PANIC_CALL
    ret

PANIC_VIDEO:
    mov bx, CODE_PANIC_VIDEO
    call PANIC_CALL
    ret

PANIC_DKEY:
    mov bx, CODE_PANIC_DKEY
    call PANIC_CALL
    ret

PANIC_UNKNOWN:
    mov bx, CODE_PANIC_UNKNOWN
    call PANIC_CALL
    ret


PANIC_CALL:
    pusha

    call clear_screen
    mov ch, COLOR_RED
    call set_screen_color

    call new_line
    call new_line
    call new_line

    mov si, PANIC_TEXT
    call out_string

    call new_line
    call new_line

    mov si, CENTER
    call out_string

    mov si, bx
    call out_string

    popa
    ret

PANIC_TEXT db "                                 NELESS PANIC", 0
CENTER db "                                 ", 0

textarea_exit dw 0