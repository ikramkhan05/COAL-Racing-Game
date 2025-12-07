org 0x100
start:
    mov ax, cs
    mov ss, ax
    mov sp, 0xFFFE
    mov ax, 0x0013
    int 0x10
    call show_start_screen
    cmp byte [quit_flag], 1
    je near exit_program
    call input_screen
    cmp byte [quit_flag], 1
    je near exit_program
    call instruction_screen
    cmp byte [quit_flag], 1
    je near exit_program
    call clear_screen
    call draw_borders
    call draw_road
    call draw_letter_r_left
    call draw_letter_i_right
    call draw_lives
    call draw_fuel_bar
    call draw_coins_display
    call copy_buffer_to_screen
    xor ax, ax
    mov es, ax
    mov ax, [es:9*4]
    mov [oldisr], ax
    mov ax, [es:9*4+2]
    mov [oldisr+2], ax
    cli
    mov word [es:9*4], kbisr
    mov [es:9*4+2], cs
    sti
    call init_animation
anim_loop:
    cmp byte [paused], 1
    je .paused_state
    call draw_road
    call handle_player_input
    call animate_frame
    call copy_buffer_to_screen
    jmp .check_input
.paused_state:
    call draw_pause_message
    call copy_buffer_to_screen
.check_input:
    cmp byte [flag], 2
    je near game_over_screen
    call delay_tick
    jmp anim_loop
kbisr:
    push ax
    push es
    push ds
    push cs
    pop ds
    in al, 0x60
    cmp byte [cs:flag], 0
    jne .check_esc
    mov byte [cs:flag], 1
    jmp .end_isr
.check_esc:
    cmp al, 0x01
    jne .check_left
    cmp byte [cs:paused], 1
    je .unpause
    mov byte [cs:paused], 1
    jmp .end_isr
.unpause:
    mov byte [cs:paused], 0
    jmp .end_isr
.check_left:
    cmp al, 0x4B
    jne .check_right
    cmp byte [cs:paused], 0
    jne .end_isr
    mov byte [cs:left_pressed], 1
    jmp .end_isr
.check_right:
    cmp al, 0x4D
    jne .check_up
    cmp byte [cs:paused], 0
    jne .end_isr
    mov byte [cs:right_pressed], 1
    jmp .end_isr
.check_up:
    cmp al, 0x48
    jne .check_down
    cmp byte [cs:paused], 0
    jne .end_isr
    mov byte [cs:up_pressed], 1
    jmp .end_isr
.check_down:
    cmp al, 0x50
    jne .check_y
    cmp byte [cs:paused], 0
    jne .end_isr
    mov byte [cs:down_pressed], 1
    jmp .end_isr
.check_y:
    cmp byte [cs:paused], 1
    jne .check_n
    cmp al, 0x15
    jne .check_n
    mov byte [cs:flag], 2
    jmp .end_isr
.check_n:
    cmp byte [cs:paused], 1
    jne .end_isr
    cmp al, 0x31
    jne .end_isr
    mov byte [cs:paused], 0
.end_isr:
    mov al, 0x20
    out 0x20, al
    pop ds
    pop es
    pop ax
    iret
exit_program:
    cmp word [oldisr], 0
    je .skip_unhook
    cli
    xor ax, ax
    mov es, ax
    mov ax, [oldisr]
    mov [es:9*4], ax
    mov ax, [oldisr+2]
    mov [es:9*4+2], ax
    sti
.skip_unhook:
    mov ax, 0x0003
    int 0x10
    mov ax, 0x4C00
    int 0x21
show_start_screen:
    call clear_screen
    call copy_buffer_to_screen
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 5
    mov dl, 10
    int 0x10
    mov si, game_title
    call print_string_yellow
    mov ah, 0x02
    mov dh, 8
    mov dl, 2
    int 0x10
    mov si, dev_names
    call print_string_white
    mov ah, 0x02
    mov dh, 10
    mov dl, 2
    int 0x10
    mov si, roll_nos
    call print_string_white
    mov ah, 0x02
    mov dh, 18
    mov dl, 8
    int 0x10
    mov si, press_start
    call print_string_white
.wait_key:
    mov ah, 0x00
    int 0x16
    cmp al, 27
    je .confirm_exit
    ret
.confirm_exit:
    call confirm_screen
    cmp byte [quit_flag], 1
    je .ret
    jmp show_start_screen
.ret:
    ret

input_screen:
   call clear_screen
    call copy_buffer_to_screen
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 8
    mov dl, 5
    int 0x10
    mov si, input_prompt_name
    call print_string_white
    mov di, player_name_buf
    call get_input_string
    cmp byte [quit_flag], 1
    je .ret
    mov ah, 0x02
    mov dh, 10
    mov dl, 5
    int 0x10
    mov si, input_prompt_roll
    call print_string_white
    mov di, player_roll_buf
    call get_input_string
.ret:
    ret

instruction_screen:
    call clear_screen
    call copy_buffer_to_screen
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 4
    mov dl, 10
    int 0x10
    mov si, instr_title
    call print_string_yellow
    mov ah, 0x02
    mov dh, 8
    mov dl, 5
    int 0x10
    mov si, instr_1
    call print_string_white
    mov ah, 0x02
    mov dh, 10
    mov dl, 5
    int 0x10
    mov si, instr_2
    call print_string_white
    mov ah, 0x02
    mov dh, 12
    mov dl, 5
    int 0x10
    mov si, instr_3
    call print_string_white
    mov ah, 0x02
    mov dh, 14
    mov dl, 5
    int 0x10
    mov si, instr_4
    call print_string_white
    mov ah, 0x02
    mov dh, 20
    mov dl, 8
    int 0x10
    mov si, instr_press
    call print_string_white
.wait_key:
    mov ah, 0x00
    int 0x16
    cmp al, 27
    je .confirm_exit
    ret
.confirm_exit:
    call confirm_screen
    cmp byte [quit_flag], 1
    je .ret
    jmp instruction_screen
.ret:
    ret
game_over_screen:
    cli
    xor ax, ax
    mov es, ax
    mov ax, [oldisr]
    mov [es:9*4], ax
    mov ax, [oldisr+2]
    mov [es:9*4+2], ax
    sti
    mov word [oldisr], 0
    mov ax, 0x0003
    int 0x10
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 6
    mov dl, 35
    int 0x10
    mov si, game_over_msg
    call print_string_red
    mov ah, 0x02
    mov dh, 9
    mov dl, 30
    int 0x10
    mov si, player_label
    call print_string_white
    mov ah, 0x02
    mov dh, 9
    mov dl, 38
    int 0x10
    mov si, player_name_buf
    call print_string_yellow
    mov ah, 0x02
    mov dh, 11
    mov dl, 30
    int 0x10
    mov si, roll_label
    call print_string_white
    mov ah, 0x02
    mov dh, 11
    mov dl, 39
    int 0x10
    mov si, player_roll_buf
    call print_string_yellow
    mov ah, 0x02
    mov dh, 15
    mov dl, 22
    int 0x10
    mov si, play_again_msg
    call print_string_white
.wait_choice:
    mov ah, 0x00
    int 0x16
    cmp al, 13
    je start
    cmp al, 27
    je exit_program
    jmp .wait_choice
confirm_screen:
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 12
    mov dl, 14
    int 0x10
    mov si, confirm_msg
    call print_string_red
.wait_yn:
    mov ah, 0x00
    int 0x16
    cmp al, 'y'
    je .yes
    cmp al, 'Y'
    je .yes
    cmp al, 'n'
    je .no
    cmp al, 'N'
    je .no
    jmp .wait_yn
.yes:
    mov byte [quit_flag], 1
    ret
.no:
    mov byte [quit_flag], 0
    ret
print_string_white:
    mov bl, 0x0F
    jmp print_string_common
print_string_yellow:
    mov bl, 0x0E
    jmp print_string_common
print_string_red:
    mov bl, 0x0C
    jmp print_string_common
print_string_common:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret
get_input_string:
    xor cx, cx
.input_loop:
    mov ah, 0x00
    int 0x16
    cmp al, 27
    je .handle_esc
    cmp al, 13
    je .done_input
    cmp al, 8
    je .handle_backspace
    cmp cx, 19
    jge .input_loop
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .input_loop
.handle_backspace:
    cmp cx, 0
    je .input_loop
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .input_loop
.handle_esc:
    call confirm_screen
    cmp byte [quit_flag], 1
    je .esc_quit
    jmp .input_loop
.esc_quit:
    ret
.done_input:
    mov byte [di], 0
    ret
init_animation:
    mov word [player_x], 160
    mov word [player_y], 175
    mov byte [obstacle_active], 0
    mov byte [obstacle_counter], 0
    mov byte [left_pressed], 0
    mov byte [right_pressed], 0
    mov byte [up_pressed], 0
    mov byte [down_pressed], 0
    mov byte [current_lane], 1
    mov word [road_scroll], 0
    mov byte [paused], 0
    mov byte [coin1_active], 0
    mov byte [coin2_active], 0
    mov byte [coin3_active], 0
    mov byte [coin_counter], 35
    mov byte [fuel1_active], 0
    mov byte [fuel2_active], 0
    mov byte [fuel_counter], 55
    ret
handle_player_input:
    cmp byte [paused], 1
    je near .skip_input
    push ax
    push bx
    cmp byte [left_pressed], 1
    jne .check_right_input
    cmp byte [current_lane], 0
    je .skip_left
    dec byte [current_lane]
    mov byte [left_pressed], 0
    jmp .update_x_pos
.check_right_input:
    cmp byte [right_pressed], 1
    jne .check_up
    cmp byte [current_lane], 2
    je .skip_right
    inc byte [current_lane]
    mov byte [right_pressed], 0
    jmp .update_x_pos
.check_up:
    cmp byte [up_pressed], 1
    jne .check_down
    cmp word [player_y], 15
    jle .skip_up
    sub word [player_y], 4
    mov byte [up_pressed], 0
    jmp .done_input
.check_down:
    cmp byte [down_pressed], 1
    jne .done_input
    cmp word [player_y], 175
    jge .skip_down
    add word [player_y], 4
    mov byte [down_pressed], 0
    jmp .done_input
.update_x_pos:
    movzx ax, byte [current_lane]
    mov bx, 40
    mul bx
    add ax, 120
    mov [player_x], ax
.skip_left:
.skip_up:
.skip_down:
.skip_right:
.done_input:
    pop bx
    pop ax
.skip_input:
    ret
delay_tick:
    push ax
    push cx
    push dx
    mov ah, 0
    int 0x1A
    mov cx, dx
.wait_next:
    mov ah, 0
    int 0x1A
    cmp dx, cx
    je .wait_next
    pop dx
    pop cx
    pop ax
    ret
animate_frame:
    push ax
    push bx
    push cx
    push dx
    ; Coin spawning
    inc byte [coin_counter]
    mov al, [COIN_INTERVAL]
    cmp [coin_counter], al
    jb .skip_coin_spawn
    cmp byte [coin1_active], 0
    jne .try_coin2
    call choose_lane_x
    mov [coin1_x], ax
    mov word [coin1_y], 0
    mov byte [coin1_active], 1
    mov byte [coin_counter], 0
    jmp .skip_coin_spawn
.try_coin2:
    cmp byte [coin2_active], 0
    jne .try_coin3
    call choose_lane_x
    mov [coin2_x], ax
    mov word [coin2_y], 0
    mov byte [coin2_active], 1
    mov byte [coin_counter], 0
    jmp .skip_coin_spawn
.try_coin3:
    cmp byte [coin3_active], 0
    jne .skip_coin_spawn
    call choose_lane_x
    mov [coin3_x], ax
    mov word [coin3_y], 0
    mov byte [coin3_active], 1
    mov byte [coin_counter], 0
.skip_coin_spawn:
    cmp byte [coin1_active], 0
    je .skip_coin1_move
    add word [coin1_y], 2
    cmp word [coin1_y], 190
    jle .skip_coin1_move
    mov byte [coin1_active], 0
.skip_coin1_move:
    cmp byte [coin2_active], 0
    je .skip_coin2_move
    add word [coin2_y], 2
    cmp word [coin2_y], 190
    jle .skip_coin2_move
    mov byte [coin2_active], 0
.skip_coin2_move:
    cmp byte [coin3_active], 0
    je .skip_coin3_move
    add word [coin3_y], 2
    cmp word [coin3_y], 190
    jle .skip_coin3_move
    mov byte [coin3_active], 0
.skip_coin3_move:
    ; Fuel spawning
    inc byte [fuel_counter]
    mov al, [FUEL_INTERVAL]
    cmp [fuel_counter], al
    jb .skip_fuel_spawn
    cmp byte [fuel1_active], 0
    jne .try_fuel2
    call choose_lane_x
    mov [fuel1_x], ax
    mov word [fuel1_y], 0
    mov byte [fuel1_active], 1
    mov byte [fuel_counter], 0
    jmp .skip_fuel_spawn
.try_fuel2:
    cmp byte [fuel2_active], 0
    jne .skip_fuel_spawn
    call choose_lane_x
    mov [fuel2_x], ax
    mov word [fuel2_y], 0
    mov byte [fuel2_active], 1
    mov byte [fuel_counter], 0
.skip_fuel_spawn:
    cmp byte [fuel1_active], 0
    je .skip_fuel1_move
    add word [fuel1_y], 2
    cmp word [fuel1_y], 190
    jle .skip_fuel1_move
    mov byte [fuel1_active], 0
.skip_fuel1_move:
    cmp byte [fuel2_active], 0
    je .skip_fuel2_move
    add word [fuel2_y], 2
    cmp word [fuel2_y], 190
    jle .skip_fuel2_move
    mov byte [fuel2_active], 0
.skip_fuel2_move:
    ; Obstacle spawning
    inc byte [obstacle_counter]
    cmp byte [obstacle_active], 0
    jne .move_obs
    mov al, [OBSTACLE_INTERVAL]
    cmp [obstacle_counter], al
    jb .draw_all
    call choose_lane_x
    mov [obstacle_x], ax
    mov word [obstacle_y], 0
    mov byte [obstacle_active], 1
    mov byte [obstacle_counter], 0
    jmp .draw_all
.move_obs:
    add word [obstacle_y], 2
    cmp word [obstacle_y], 190
    jle .draw_all
    mov byte [obstacle_active], 0
.draw_all:
    mov ax, [player_x]
    mov bx, [player_y]
    mov cl, 0x0C
    call draw_player_car
    cmp byte [obstacle_active], 0
    je .skip_obstacle
    mov ax, [obstacle_x]
    mov bx, [obstacle_y]
    mov cl, 0x01
    call draw_opponent_car
.skip_obstacle:
    cmp byte [coin1_active], 0
    je .skip_draw_coin1
    mov ax, [coin1_x]
    mov bx, [coin1_y]
    call draw_road_coin
.skip_draw_coin1:
    cmp byte [coin2_active], 0
    je .skip_draw_coin2
    mov ax, [coin2_x]
    mov bx, [coin2_y]
    call draw_road_coin
.skip_draw_coin2:
    cmp byte [coin3_active], 0
    je .skip_draw_coin3
    mov ax, [coin3_x]
    mov bx, [coin3_y]
    call draw_road_coin
.skip_draw_coin3:
    cmp byte [fuel1_active], 0
    je .skip_draw_fuel1
    mov ax, [fuel1_x]
    mov bx, [fuel1_y]
    call draw_road_fuel
.skip_draw_fuel1:
    cmp byte [fuel2_active], 0
    je .skip_draw_fuel2
    mov ax, [fuel2_x]
    mov bx, [fuel2_y]
    call draw_road_fuel
.skip_draw_fuel2:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
choose_lane_x:
    push dx
    push bx
    mov ah, 0x00
    int 0x1A
    mov ax, dx
    xor dx, dx
    mov bx, 3
    div bx
    mov ax, 120
    cmp dx, 0
    je .lane_ready
    mov ax, 160
    cmp dx, 1
    je .lane_ready
    mov ax, 200
.lane_ready:
    pop bx
    pop dx
    ret
copy_buffer_to_screen:
    push ax
    push cx
    push ds
    push es
    push si
    push di
    mov ax, [buffer_segment]
    mov ds, ax
    xor si, si
    mov ax, 0xA000
    mov es, ax
    xor di, di
    mov cx, 32000
    rep movsw
    pop di
    pop si
    pop es
    pop ds
    pop cx
    pop ax
    ret
clear_screen:
    push ax
    push cx
    push es
    push di
    mov ax, [buffer_segment]
    mov es, ax
    xor di, di
    mov cx, 64000
    xor al, al
    rep stosb
    pop di
    pop es
    pop cx
    pop ax
    ret
draw_borders:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    mov ax, [buffer_segment]
    mov es, ax
    mov dx, 0
.border_loop:
    cmp dx, 200
    jge near .done
    push dx
    mov ax, dx
    mov bx, 320
    mul bx
    mov di, ax
    pop dx
    mov cx, 100
    mov al, 0x06
    rep stosb
    push dx
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, 220
    mov di, ax
    pop dx
    mov cx, 100
    mov al, 0x06
    rep stosb
    inc dx
    jmp .border_loop
.done:
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_road:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    mov ax, [buffer_segment]
    mov es, ax
    inc word [road_scroll]
    and word [road_scroll], 0x0F
    mov dx, 0
.road_loop:
    cmp dx, 200
    jge near .done
    push dx
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, 100
    mov di, ax
    pop dx
    mov cx, 120
    mov al, 0x08
    rep stosb
    push dx
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, 100
    mov di, ax
    pop dx
    mov byte [es:di], 0x0F
    mov byte [es:di+1], 0x0F
    push dx
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, 218
    mov di, ax
    pop dx
    mov byte [es:di], 0x0F
    mov byte [es:di+1], 0x0F
    mov ax, dx
    add ax, [road_scroll]
    test ax, 0x08
    jnz .no_left_line
    push dx
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, 140
    mov di, ax
    pop dx
    mov byte [es:di], 0x0E
    mov byte [es:di+1], 0x0E
.no_left_line:
    mov ax, dx
    add ax, [road_scroll]
    test ax, 0x08
    jnz .no_right_line
    push dx
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, 180
    mov di, ax
    pop dx
    mov byte [es:di], 0x0E
    mov byte [es:di+1], 0x0E
.no_right_line:
    push dx
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, 96
    mov di, ax
    pop dx
    mov al, 0x0C
    mov cx, 3
    rep stosb
    push dx
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, 221
    mov di, ax
    pop dx
    mov al, 0x0C
    mov cx, 3
    rep stosb
    inc dx
    jmp .road_loop
.done:
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_player_car:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    push si
    mov si, bx
    mov bx, ax
    mov ax, si
    mov dx, 320
    mul dx
    add ax, bx
    sub ax, 5
    mov di, ax
    mov ax, [buffer_segment]
    mov es, ax
    mov si, 0
.draw_loop:
    cmp si, 14
    jge near .done
    push di
    cmp si, 2
    jge .check_window
    add di, 2
    mov al, cl
    push cx
    mov cx, 6
    rep stosb
    pop cx
    mov byte [es:di-6], 0x0F
    mov byte [es:di-1], 0x0F
    mov byte [es:di-4], 0x0F
    mov byte [es:di-3], 0x0F
    jmp .next_row
.check_window:
    cmp si, 5
    jge .check_body
    mov al, 0x07
    push cx
    mov cx, 10
    rep stosb
    pop cx
    jmp .next_row
.check_body:
    mov al, cl
    push cx
    mov cx, 10
    rep stosb
    pop cx
    mov byte [es:di-10], 0x00
    mov byte [es:di-1], 0x00
    cmp si, 6
    je .add_wheels
    cmp si, 11
    je .add_wheels
    cmp si, 12
    jl .next_row
    mov byte [es:di-9], 0x0C
    mov byte [es:di-2], 0x0C
    jmp .next_row
.add_wheels:
    mov byte [es:di-10], 0x00
    mov byte [es:di-9], 0x00
    mov byte [es:di-2], 0x00
    mov byte [es:di-1], 0x00
.next_row:
    pop di
    add di, 320
    inc si
    jmp .draw_loop
.done:
    pop si
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_opponent_car:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    push si
    mov si, bx
    mov bx, ax
    mov ax, si
    mov dx, 320
    mul dx
    add ax, bx
    sub ax, 5
    mov di, ax
    mov ax, [buffer_segment]
    mov es, ax
    mov si, 0
.down_loop:
    cmp si, 14
    jge near .down_done
    push di
    mov dx, 13
    sub dx, si
    cmp dx, 2
    jge .check_window_d
    add di, 2
    mov al, cl
    push cx
    mov cx, 6
    rep stosb
    pop cx
    mov byte [es:di-6], 0x0F
    mov byte [es:di-1], 0x0F
    mov byte [es:di-4], 0x0C
    mov byte [es:di-3], 0x0C
    jmp .next_row_d
.check_window_d:
    cmp dx, 5
    jge .check_body_d
    mov al, 0x0B
    push cx
    mov cx, 10
    rep stosb
    pop cx
    jmp .next_row_d
.check_body_d:
    mov al, cl
    push cx
    mov cx, 10
    rep stosb
    pop cx
    mov byte [es:di-10], 0x00
    mov byte [es:di-1], 0x00
    cmp dx, 6
    je .add_wheels_d
    cmp dx, 11
    je .add_wheels_d
    jmp .next_row_d
.add_wheels_d:
    mov byte [es:di-10], 0x00
    mov byte [es:di-9], 0x00
    mov byte [es:di-2], 0x00
    mov byte [es:di-1], 0x00
.next_row_d:
    pop di
    add di, 320
    inc si
    jmp .down_loop
.down_done:
    pop si
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_road_coin:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    mov cx, ax
    mov ax, bx
    mov bx, 320
    mul bx
    add ax, cx
    sub ax, 6
    mov di, ax
    mov ax, [buffer_segment]
    mov es, ax
    mov byte [es:di+4], 0x0E
    mov byte [es:di+5], 0x0E
    mov byte [es:di+6], 0x0E
    mov byte [es:di+7], 0x0E
    add di, 320
    mov byte [es:di+2], 0x0E
    mov byte [es:di+3], 0x0E
    mov byte [es:di+4], 0x0E
    mov byte [es:di+5], 0x0E
    mov byte [es:di+6], 0x0E
    mov byte [es:di+7], 0x0E
    mov byte [es:di+8], 0x0E
    mov byte [es:di+9], 0x0E
    add di, 320
    mov byte [es:di+1], 0x0E
    mov byte [es:di+2], 0x0E
    mov byte [es:di+3], 0x0E
    mov byte [es:di+4], 0x0E
    mov byte [es:di+5], 0x0E
    mov byte [es:di+6], 0x0E
    mov byte [es:di+7], 0x0E
    mov byte [es:di+8], 0x0E
    mov byte [es:di+9], 0x0E
    mov byte [es:di+10], 0x0E
    add di, 320
    mov byte [es:di], 0x0E
    mov byte [es:di+1], 0x0E
    mov byte [es:di+2], 0x0E
    mov byte [es:di+3], 0x06
    mov byte [es:di+4], 0x06
    mov byte [es:di+5], 0x06
    mov byte [es:di+6], 0x06
    mov byte [es:di+7], 0x06
    mov byte [es:di+8], 0x06
    mov byte [es:di+9], 0x0E
    mov byte [es:di+10], 0x0E
    mov byte [es:di+11], 0x0E
    add di, 320
    mov cx, 4
.coin_mid:
    mov byte [es:di], 0x0E
    mov byte [es:di+1], 0x0E
    mov byte [es:di+2], 0x06
    mov byte [es:di+3], 0x06
    mov byte [es:di+4], 0x0E
    mov byte [es:di+5], 0x0E
    mov byte [es:di+6], 0x0E
    mov byte [es:di+7], 0x0E
    mov byte [es:di+8], 0x06
    mov byte [es:di+9], 0x06
    mov byte [es:di+10], 0x0E
    mov byte [es:di+11], 0x0E
    add di, 320
    loop .coin_mid
    mov byte [es:di], 0x0E
    mov byte [es:di+1], 0x0E
    mov byte [es:di+2], 0x0E
    mov byte [es:di+3], 0x06
    mov byte [es:di+4], 0x06
    mov byte [es:di+5], 0x06
    mov byte [es:di+6], 0x06
    mov byte [es:di+7], 0x06
    mov byte [es:di+8], 0x06
    mov byte [es:di+9], 0x0E
    mov byte [es:di+10], 0x0E
    mov byte [es:di+11], 0x0E
    add di, 320
    mov byte [es:di+1], 0x0E
    mov byte [es:di+2], 0x0E
    mov byte [es:di+3], 0x0E
    mov byte [es:di+4], 0x0E
    mov byte [es:di+5], 0x0E
    mov byte [es:di+6], 0x0E
    mov byte [es:di+7], 0x0E
    mov byte [es:di+8], 0x0E
    mov byte [es:di+9], 0x0E
    mov byte [es:di+10], 0x0E
    add di, 320
    mov byte [es:di+2], 0x0E
    mov byte [es:di+3], 0x0E
    mov byte [es:di+4], 0x0E
    mov byte [es:di+5], 0x0E
    mov byte [es:di+6], 0x0E
    mov byte [es:di+7], 0x0E
    mov byte [es:di+8], 0x0E
    mov byte [es:di+9], 0x0E
    add di, 320
    mov byte [es:di+4], 0x0E
    mov byte [es:di+5], 0x0E
    mov byte [es:di+6], 0x0E
    mov byte [es:di+7], 0x0E
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_road_fuel:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    mov cx, ax
    mov ax, bx
    mov bx, 320
    mul bx
    add ax, cx
    sub ax, 5
    mov di, ax
    mov ax, [buffer_segment]
    mov es, ax
    mov byte [es:di+2], 0x04
    mov byte [es:di+3], 0x04
    mov byte [es:di+4], 0x04
    mov byte [es:di+5], 0x04
    mov byte [es:di+6], 0x04
    mov byte [es:di+7], 0x04
    add di, 320
    mov byte [es:di+1], 0x04
    mov byte [es:di+2], 0x04
    mov byte [es:di+3], 0x04
    mov byte [es:di+4], 0x04
    mov byte [es:di+5], 0x04
    mov byte [es:di+6], 0x04
    mov byte [es:di+7], 0x04
    mov byte [es:di+8], 0x04
    add di, 320
    mov byte [es:di], 0x04
    mov byte [es:di+1], 0x04
    mov byte [es:di+2], 0x04
    mov byte [es:di+3], 0x04
    mov byte [es:di+4], 0x04
    mov byte [es:di+5], 0x04
    mov byte [es:di+6], 0x04
    mov byte [es:di+7], 0x04
    mov byte [es:di+8], 0x04
    mov byte [es:di+9], 0x04
    add di, 320
    mov cx, 2
.fuel_upper:
    mov byte [es:di], 0x04
    mov byte [es:di+1], 0x0C
    mov byte [es:di+2], 0x0C
    mov byte [es:di+3], 0x0C
    mov byte [es:di+4], 0x0C
    mov byte [es:di+5], 0x0C
    mov byte [es:di+6], 0x0C
    mov byte [es:di+7], 0x0C
    mov byte [es:di+8], 0x0C
    mov byte [es:di+9], 0x04
    add di, 320
    loop .fuel_upper
    mov cx, 4
.fuel_mid:
    mov byte [es:di], 0x04
    mov byte [es:di+1], 0x0C
    mov byte [es:di+2], 0x0F
    mov byte [es:di+3], 0x0F
    mov byte [es:di+4], 0x0F
    mov byte [es:di+5], 0x0F
    mov byte [es:di+6], 0x0F
    mov byte [es:di+7], 0x0F
    mov byte [es:di+8], 0x0C
    mov byte [es:di+9], 0x04
    add di, 320
    loop .fuel_mid
    mov cx, 2
.fuel_lower:
    mov byte [es:di], 0x04
    mov byte [es:di+1], 0x0C
    mov byte [es:di+2], 0x0C
    mov byte [es:di+3], 0x0C
    mov byte [es:di+4], 0x0C
    mov byte [es:di+5], 0x0C
    mov byte [es:di+6], 0x0C
    mov byte [es:di+7], 0x0C
    mov byte [es:di+8], 0x0C
    mov byte [es:di+9], 0x04
    add di, 320
    loop .fuel_lower
    mov byte [es:di], 0x04
    mov byte [es:di+1], 0x04
    mov byte [es:di+2], 0x04
    mov byte [es:di+3], 0x04
    mov byte [es:di+4], 0x04
    mov byte [es:di+5], 0x04
    mov byte [es:di+6], 0x04
    mov byte [es:di+7], 0x04
    mov byte [es:di+8], 0x04
    mov byte [es:di+9], 0x04
    add di, 320
    mov byte [es:di+3], 0x04
    mov byte [es:di+4], 0x04
    mov byte [es:di+5], 0x04
    mov byte [es:di+6], 0x04
    add di, 320
    mov byte [es:di+3], 0x04
    mov byte [es:di+4], 0x04
    mov byte [es:di+5], 0x04
    mov byte [es:di+6], 0x04
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_letter_r_left:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    mov ax, [buffer_segment]
    mov es, ax
    mov dx, 80
    mov bx, 40
.r_loop:
    cmp dx, 120
    jge near .r_done
    push dx
    mov ax, dx
    push bx
    mov bx, 320
    mul bx
    pop bx
    add ax, bx
    mov di, ax
    pop dx
    mov ax, dx
    sub ax, 80
    mov byte [es:di], 0x0F
    mov byte [es:di+1], 0x0F
    mov byte [es:di+2], 0x0F
    cmp ax, 4
    jge .check_mid
    mov byte [es:di+3], 0x0F
    mov byte [es:di+4], 0x0F
    mov byte [es:di+5], 0x0F
    mov byte [es:di+6], 0x0F
    mov byte [es:di+7], 0x0F
    mov byte [es:di+8], 0x0F
    mov byte [es:di+9], 0x0F
    mov byte [es:di+10], 0x0F
    jmp .next_r
.check_mid:
    cmp ax, 19
    jge .check_bar
    mov byte [es:di+10], 0x0F
    mov byte [es:di+11], 0x0F
    mov byte [es:di+12], 0x0F
    jmp .next_r
.check_bar:
    cmp ax, 23
    jge .check_diag
    mov byte [es:di+3], 0x0F
    mov byte [es:di+4], 0x0F
    mov byte [es:di+5], 0x0F
    mov byte [es:di+6], 0x0F
    mov byte [es:di+7], 0x0F
    mov byte [es:di+8], 0x0F
    mov byte [es:di+9], 0x0F
    jmp .next_r
.check_diag:
    sub ax, 23
    mov cx, ax
    shr cx, 1
    add cx, 6
    add di, cx
    mov byte [es:di], 0x0F
    mov byte [es:di+1], 0x0F
    mov byte [es:di+2], 0x0F
.next_r:
    inc dx
    jmp .r_loop
.r_done:
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_letter_i_right:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    mov ax, [buffer_segment]
    mov es, ax
    mov dx, 80
    mov bx, 260
.i_loop:
    cmp dx, 120
    jge near .i_done
    push dx
    mov ax, dx
    push bx
    mov bx, 320
    mul bx
    pop bx
    add ax, bx
    mov di, ax
    pop dx
    mov ax, dx
    sub ax, 80
    cmp ax, 4
    jge .check_mid_i
    mov byte [es:di], 0x0F
    mov byte [es:di+1], 0x0F
    mov byte [es:di+2], 0x0F
    mov byte [es:di+3], 0x0F
    mov byte [es:di+4], 0x0F
    mov byte [es:di+5], 0x0F
    mov byte [es:di+6], 0x0F
    mov byte [es:di+7], 0x0F
    mov byte [es:di+8], 0x0F
    mov byte [es:di+9], 0x0F
    mov byte [es:di+10], 0x0F
    mov byte [es:di+11], 0x0F
    mov byte [es:di+12], 0x0F
    jmp .next_i
.check_mid_i:
    cmp ax, 36
    jge .check_bot_i
    mov byte [es:di+5], 0x0F
    mov byte [es:di+6], 0x0F
    mov byte [es:di+7], 0x0F
    jmp .next_i
.check_bot_i:
    mov byte [es:di], 0x0F
    mov byte [es:di+1], 0x0F
    mov byte [es:di+2], 0x0F
    mov byte [es:di+3], 0x0F
    mov byte [es:di+4], 0x0F
    mov byte [es:di+5], 0x0F
    mov byte [es:di+6], 0x0F
    mov byte [es:di+7], 0x0F
    mov byte [es:di+8], 0x0F
    mov byte [es:di+9], 0x0F
    mov byte [es:di+10], 0x0F
    mov byte [es:di+11], 0x0F
    mov byte [es:di+12], 0x0F
.next_i:
    inc dx
    jmp .i_loop
.i_done:
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_lives:
    push ax
    push bx
    push dx
    mov bx, 260
    mov dx, 8
    call draw_single_life
    mov bx, 275
    call draw_single_life
    mov bx, 290
    call draw_single_life
    pop dx
    pop bx
    pop ax
    ret
draw_single_life:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    mov ax, [buffer_segment]
    mov es, ax
    mov ax, dx
    push bx
    mov bx, 320
    mul bx
    pop bx
    add ax, bx
    mov di, ax
    add di, 3
    mov al, 0x0C
    mov cx, 4
    rep stosb
    add di, 320 - 7
    mov cx, 8
    rep stosb
    add di, 320 - 8 - 1
    mov cx, 6
.life_mid:
    push cx
    mov cx, 10
    rep stosb
    add di, 320 - 10
    pop cx
    loop .life_mid
    add di, 1
    mov cx, 8
    rep stosb
    add di, 320 - 8 - 1 + 3
    mov cx, 4
    rep stosb
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_fuel_bar:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    mov ax, [buffer_segment]
    mov es, ax
    mov ax, 187
    mov bx, 320
    mul bx
    add ax, 265
    mov di, ax
    mov al, 0x02
    add di, 2
    mov cx, 34
    rep stosb
    sub di, 34
    add di, 320
    mov dx, 6
.fuel_loop:
    mov cx, 38
    rep stosb
    add di, 320 - 38
    dec dx
    jnz .fuel_loop
    add di, 2
    mov cx, 34
    rep stosb
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_coins_display:
  push ax
    push bx
    push cx
    push dx
    push es
    push di
    push si
    mov ax, [buffer_segment]
    mov es, ax   
    mov bx, 10
    mov dx, 185
    call draw_ui_coin
    mov bx, 22
    mov dx, 185
    call draw_ui_coin
    mov bx, 34
    mov dx, 185
    call draw_ui_coin
    pop si
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_ui_coin:
    push ax
    push bx
    push cx
    push dx
    push di
    mov ax, dx
    push bx
    mov bx, 320
    mul bx
    pop bx
    add ax, bx
    mov di, ax
    add di, 3
    mov al, 0x0E    
    mov cx, 4
    rep stosb
    add di, 320 - 4 - 3
    add di, 1
    mov al, 0x0E
    mov cx, 8
    rep stosb
    add di, 320 - 8 - 1
    mov si, 0
.coin_middle:
    cmp si, 6
    jge .coin_bottom
    mov al, 0x0E
    mov cx, 10
    rep stosb
    mov byte [es:di-6], 0x06  
    mov byte [es:di-5], 0x06
    add di, 320 - 10
    inc si
    jmp .coin_middle
.coin_bottom:
    add di, 1
    mov al, 0x0E
    mov cx, 8
    rep stosb
    add di, 320 - 8 - 1
    add di, 3
    mov al, 0x0E
    mov cx, 4
    rep stosb
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_pause_message:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    mov ax, [buffer_segment]
    mov es, ax
    mov dx, 85
.box_loop:
    cmp dx, 115
    jge .box_done
    push dx
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, 110
    mov di, ax
    pop dx
    mov cx, 100
    mov al, 0x00
    rep stosb
    inc dx
    jmp .box_loop
.box_done:
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 12
    mov dl, 15
    int 0x10
    mov si, pause_msg
    call print_string_white
    ret
quit_flag        db 0
player_x         dw 160
player_y         dw 175
oldisr           dd 0
obstacle_x       dw 0
obstacle_y       dw 0
obstacle_active  db 0
obstacle_counter db 0
coin1_x          dw 0
coin1_y          dw 0
coin1_active     db 0
coin2_x          dw 0
coin2_y          dw 0
coin2_active     db 0
coin3_x          dw 0
coin3_y          dw 0
coin3_active     db 0
coin_counter     db 0
fuel1_x          dw 0
fuel1_y          dw 0
fuel1_active     db 0
fuel2_x          dw 0
fuel2_y          dw 0
fuel2_active     db 0
fuel_counter     db 0
flag             db 0
left_pressed     db 0
right_pressed    db 0
down_pressed     db 0
up_pressed       db 0
current_lane     db 1
road_scroll      dw 0
paused           db 0
OBSTACLE_INTERVAL db 30
COIN_INTERVAL     db 45
FUEL_INTERVAL     db 80
game_title       db '=== HIGHWAY RACER ===', 0
dev_names        db 'Devs: Ikram Ul Haq & Rohaan Ahmed', 0
roll_nos         db 'Rolls: 24L-0767 & 24L-0548', 0
press_start      db 'Press ANY Key to Start', 0
input_prompt_name db 'Enter Name: ', 0
input_prompt_roll db 'Enter Roll: ', 0
instr_title      db '--- INSTRUCTIONS ---', 0
instr_1          db 'Left/Right: Change Lanes', 0
instr_2          db 'Up/Down: Move Car', 0
instr_3          db 'Collect Coins & Fuel', 0
instr_4          db 'ESC: Pause/Quit', 0
instr_press      db 'Press ANY Key to Play', 0
game_over_msg    db '=== GAME OVER ===', 0
player_label     db 'Player: ', 0
roll_label       db 'Roll No: ', 0
play_again_msg   db 'Enter: Restart | ESC: Exit', 0
confirm_msg      db 'Quit Game? (Y/N)', 0
pause_msg        db 'PAUSED - Quit? (Y/N)', 0
player_name_buf  times 20 db 0
player_roll_buf  times 20 db 0