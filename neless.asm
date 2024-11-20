org 0x7c00

jmp boot

boot:
    cli         
    xor ax, ax 
    mov ds, ax 
    mov es, ax 
    mov ss, ax 
    mov sp, 0x7c0

    mov ah, 0x02
    mov al, 10
    mov ch, 0x00   
    mov cl, 0x02 
    mov dh, 0x00  
    mov dl, 0x80   
    mov bx, 0x7e00 
    int 0x13       

    jc PANIC_BOOT 
    jmp 0x7e00    

times 510 - ($ - $$) db 0
dw 0xAA55


%include "drivers/fs.asm"


jmp kernel


kernel:
    call clear_screen

    create_file file_neless_ini, 0x10

    mov si, welcome_message
    call out_string 
    call new_line

    jmp terminal

terminal:
    mov si, buffer
    mov bx, 100
    call clear_buffer

    mov si, prompt
    call out_string

    mov si, buffer
    call in_string

    jmp logic

    jmp terminal


logic:
    ; NULL COMMAND
    mov si, null_symbol
    mov bx, buffer
    call comp
    cmp cx, 1
    je terminal

    ; HELP COMMAND
    mov si, command_help_text
    mov bx, buffer
    call comp
    cmp cx, 1
    je HELP_CALL

    ; CLEAR COMMAND
    mov si, command_clear_text
    mov bx, buffer
    call comp
    cmp cx, 1
    je clear_call

    ; REBOOT COMAND
    mov si, command_reboot_text
    mov bx, buffer
    call comp
    cmp cx, 1
    je reboot_computer

    ; SHUTDOWN COMMAND
    mov si, command_shutdown_text
    mov bx, buffer
    call comp
    cmp cx, 1
    je shutdown_computer

    ; DISKTOOL COMMAND
    mov si, command_disktool_text
    mov bx, buffer
    call comp
    cmp cx, 1
    je disktool_call

    ; PANIC COMMAND
    mov si, command_panic_text
    mov bx, buffer
    call comp
    cmp cx, 1
    je PANIC_UNKNOWN

    ; EDIT COMMAND
    mov si, command_edit_text
    mov bx, buffer
    call comp
    cmp cx, 1
    je EDIT_CALL

    ; LS COMMAND
    mov si, command_ls_text
    mov bx, buffer
    call comp
    cmp cx, 1
    je LS_CALL

    ; MF COMMAND
    mov si, command_mf_text
    mov bx, buffer
    call comp
    cmp cx, 1
    je MF_CALL

    ; RF COMMAND
    mov si, command_rf_text
    mov bx, buffer
    call comp
    cmp cx, 1
    je RF_CALL

    ; ECHO 
    mov si, comamnd_echo_text
    mov bx, buffer
    call comp
    cmp cx, 1
    je ECHO_CALL

    jne wrong_call

    jmp terminal


wrong_call:
    mov si, buffer
    call out_string

    mov si, command_wrong_text
    call out_string

    call new_line

    jmp terminal


RF_CALL:

    jmp terminal


ECHO_CALL:

    jmp terminal


MF_CALL:


    jmp terminal

LS_CALL:
    mov si, FILES
    call out_string

    jmp terminal


EDIT_CALL:
    mov si, edit_buffer
    mov bx, 2048
    call clear_buffer

EDIT_CALLS:
    call clear_screen

    mov si, edit_menu_text1
    call out_string

    call new_line

    mov si, edit_buffer
    call in_textarea

    cmp word [textarea_exit], 1
    je terminal


    ret




HELP_CALL:
    call clear_screen

    mov ch, COLOR_BLUE
    call set_screen_color

    mov si, nullsss
    call out_string
    
    mov si, exit_esc_text
    call out_string

    call new_line
    call new_line
    call new_line

    mov si, help_menu_text1
    call out_string
    call new_line
    mov si, help_menu_text2
    call out_string

    call new_line
    call new_line

    mov si, help_menu_text3
    call out_string

    call new_line
    call new_line

    mov si, help_menu_text4
    call out_string

    call new_line

    mov si, help_menu_text5
    call out_string

    call new_line
    call new_line

    mov si, help_menu_text6
    call out_string

    call new_line
    call new_line

    mov si, help_menu_text7
    call out_string

    call new_line
    call new_line

    mov si, help_menu_text8
    call out_string

    call new_line

    mov si, help_menu_text9
    call out_string

    call new_line

    mov si, help_menu_text10
    call out_string

    call new_line

    mov si, help_menu_text11
    call out_string

    call new_line

    mov ah, 0x00
    int 0x16

    cmp al, 'q'
    je EXIT_APP

   
    jmp HELP_CALL

    

EXIT_APP:
    call clear_screen
    jmp kernel

clear_call:
    call clear_screen
    jmp terminal


disktool_call:
    mov si, buffer
    mov bx, 100
    call clear_buffer

    mov si, disktool_prompt
    call out_string

    mov si, buffer
    call in_string

    jmp disktool_command

    jmp disktool_call

disktool_command:
    mov si, disktool_command_reset
    mov bx, buffer
    call comp
    cmp cx, 1
    je reset_disk

    mov si, disktool_command_exit
    mov bx, buffer
    call comp
    cmp cx, 1
    je terminal

    jmp disktool_call

reset_disk:
    mov ah, 0x00
    mov dl, 0x80
    int 0x13
    jc PANIC_DISK

    jc failed_disk_reset

    jmp success_disk_reset

success_disk_reset:
    mov si, disktool_command_reset_success
    call out_string

    call new_line

    jmp disktool_call

failed_disk_reset:
    mov si, disktool_command_reset_wrong
    call out_string

    call new_line

    jmp disktool_call


%include "drivers/io.asm"


boot_error_text db "BOOT ERROR", 0
panic_error_text db "PANIC", 0

welcome_message db "Neless os 0.10                                                  enter 'help'", 0
prompt db "# ", 0
disktool_prompt db "disktool# ", 0

null_symbol db "", 0

nullsss db "                            ", 0
exit_esc_text db "press 'q' to exit", 0

command_help_text db "help", 0
command_clear_text db "clear", 0
command_reboot_text db "reboot", 0
command_shutdown_text db "shutdown", 0
command_disktool_text db "disktool", 0
command_panic_text db "panic", 0
command_edit_text db "edit", 0
command_ls_text db "ls", 0
command_mf_text db "mf", 0
command_rf_text db "rf", 0
comamnd_echo_text db "echo", 0

disktool_command_reset db "reset", 0
disktool_command_reset_wrong db "failed to reset the disk", 0
disktool_command_reset_success db "success to reset the disk", 0
disktool_command_exit db "exit", 0

command_wrong_text db ": unknown command", 0


help_menu_text1 db  "        reboot          ->      'reboot computer'", 0
help_menu_text2 db  "        shutdown        ->      'shutdown computer'", 0
help_menu_text3 db  "        clear           ->      'clear screen'", 0
help_menu_text4 db  "        disktool        ->      'utility for working with a disk'", 0
help_menu_text5 db  "        reset           ->      'reset disk (disktool component)'", 0
help_menu_text6 db  "        panic           ->      'artificially cause a panic'", 0
help_menu_text7 db  "        edit            ->      'Neless text editor'", 0
help_menu_text8 db  "        ls              ->      'files list'", 0
help_menu_text9 db  "        mf              ->      'create file (max size 512 bytes)'", 0
help_menu_text10 db "        rf              ->      'clean file'", 0
help_menu_text11 db "        echo            ->      'read file (max size 512 bytes)'", 0

edit_menu_text1 db "Neless editor                       press 'q' to exit", 0


file_neless_ini db "neless.ini", 0


buffer times 100 db 0

edit_buffer times 2048 db 0
settings_buff times 512 db 0