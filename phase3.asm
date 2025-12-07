org 0x100

start:
    mov ax, cs
    mov ss, ax
    mov sp, 0xFFFE
    mov ax, 0x0013
    int 0x10
    call clear_screen
    call draw_borders
    call draw_road
    call draw_letter_i_right
    call draw_letter_r_left
    call draw_lives
    call draw_fuel
    call draw_coins
    call copy_buffer_to_screen
    xor ax, ax
    mov es, ax
    mov ax, [es:9*4]
    mov [oldisr], ax
    mov ax, [es:9*4+2]
    mov [oldisr+2], ax
    cli
    mov word[es:9*4], kbisr
    mov [es:9*4+2], cs
    sti
L1:
    cmp byte[flag], 1
    jne L1
    call init_animation
    jmp anim_loop
kbisr:
    push ax
    push es
    push ds      
    push cs
    pop ds       
    in al, 0x60
    cmp byte[cs:flag], 0
    jne check_esc
    mov byte[cs:flag], 1
    jmp endkbisr
check_esc:
    cmp al, 0x01
    jne check_left
    cmp byte[cs:paused], 1
    je .unpause_game
    mov byte[cs:paused], 1
    jmp endkbisr
.unpause_game:
    mov byte[cs:paused], 0
    jmp endkbisr
check_left:
    cmp al, 0x4B
    jne check_right
    cmp byte[cs:paused], 0 
    jne endkbisr
    mov byte[cs:left_pressed], 1
    jmp endkbisr
check_right:
    cmp al, 0x4D
    jne check_upk
    cmp byte[cs:paused], 0 
    jne endkbisr
    mov byte[cs:right_pressed], 1
    jmp endkbisr
check_upk:
    cmp al, 0x48
    jne check_downk
    cmp byte[cs:paused], 0  
    jne endkbisr
    mov byte[cs:up_pressed], 1
    jmp endkbisr
check_downk:
    cmp al, 0x50
    jne check_y_key
    cmp byte[cs:paused], 0 
    jne endkbisr
    mov byte[cs:down_pressed], 1
    jmp endkbisr
check_y_key:
    cmp byte[cs:paused], 1 
    jne check_n_key
    cmp al, 0x15 
    jne check_n_key
    mov byte[cs:flag], 2
    jmp endkbisr
check_n_key:
    cmp byte[cs:paused], 1 
    jne endkbisr
    cmp al, 0x31           
    jne endkbisr
    mov byte[cs:paused], 0
endkbisr:
    mov al, 0x20
    out 0x20, al
    pop ds         
    pop es
    pop ax
    iret
anim_loop:
    cmp byte[paused], 1
    je .paused_state
    call draw_road         
    call handle_player_input
    call animate_frame     
    call copy_buffer_to_screen
    jmp .check_input
.paused_state:
    call draw_pause_message
    call copy_buffer_to_screen
    jmp .check_input
.check_input:
    cmp byte[flag], 2
    je .quit_game
    call delay_tick
    jmp anim_loop
.quit_game:
    cli   
    xor ax, ax
    mov es, ax
    mov ax, [oldisr] 
    mov [es:9*4], ax
    mov ax, [oldisr+2]
    mov [es:9*4+2], ax
    sti               
    mov ax, 0x0003
    int 0x10
    mov ax, 0x4C00
    int 0x21
draw_pause_message:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    push si
    mov ax, 0xA000
    mov es, ax
    mov dx, 90
.overlay_loop:
    cmp dx, 130
    jge .draw_text
    push dx
    mov ax, dx
    mov bx, 320
    mul bx
    add ax, 100
    mov di, ax
    pop dx
    mov cx, 120
    mov al, 0x07  
    rep stosb
    inc dx
    jmp .overlay_loop
.draw_text:
    mov bx, 100
    mov dx, 95
    call draw_quit_message
   
    pop si
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_quit_message:
    push ax
    push bx
    push cx
    push dx
    push es
    push bp
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 12          
    mov dl, 10          
    int 0x10
    mov ax, cs
    mov es, ax
    mov bp, quit_msg_1
    mov cx, 20          
    mov ax, 0x1301      
    mov bx, 0x000F      
    int 0x10
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 14          
    mov dl, 17          
    int 0x10
    mov bp, quit_msg_2
    mov cx, 5
    mov ax, 0x1301
    mov bx, 0x000F
    int 0x10
    pop bp
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
quit_msg_1 db 'Do you want to Quit?', 0
quit_msg_2 db '(Y/N)', 0

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
    mov byte [road_scroll], 0
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
    je near skip_input
    push ax
    push bx
    cmp byte [left_pressed], 1
    jne check_right_input
    cmp byte [current_lane], 0
    je skip_left
    dec byte [current_lane]
    mov byte [left_pressed], 0
    jmp update_x_pos
check_right_input:
    cmp byte [right_pressed], 1
    jne check_up
    cmp byte [current_lane], 2
    je skip_right
    inc byte [current_lane]
    mov byte [right_pressed], 0
    jmp update_x_pos
check_up:
    cmp byte [up_pressed], 1
    jne check_down
    cmp word [player_y], 15
    jle skip_up
    mov word [y_pos], -4
    mov byte [up_pressed], 0
    jmp update_y_pos
check_down:
    cmp byte [down_pressed], 1
    jne skip_movement
    cmp word [player_y], 175
    jge skip_down
    mov word [y_pos], 4
    mov byte [down_pressed], 0
    jmp update_y_pos
update_y_pos:
    mov ax, [y_pos]
    add [player_y], ax
update_x_pos:
    movzx ax, byte [current_lane]
    mov bx, 40
    mul bx
    add ax, 120
    mov [player_x], ax
skip_left:
skip_up:
skip_down:
skip_right:
skip_movement:
    pop bx
    pop ax
skip_input:
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
    inc word [coin1_y]
    cmp word [coin1_y], 190
    jle .skip_coin1_move
    mov byte [coin1_active], 0
.skip_coin1_move:
    cmp byte [coin2_active], 0
    je .skip_coin2_move
    inc word [coin2_y]
    cmp word [coin2_y], 190
    jle .skip_coin2_move
    mov byte [coin2_active], 0
.skip_coin2_move:
    cmp byte [coin3_active], 0
    je .skip_coin3_move
    inc word [coin3_y]
    cmp word [coin3_y], 190
    jle .skip_coin3_move
    mov byte [coin3_active], 0
.skip_coin3_move:
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
    inc word [fuel1_y]
    cmp word [fuel1_y], 190
    jle .skip_fuel1_move
    mov byte [fuel1_active], 0
.skip_fuel1_move:
    cmp byte [fuel2_active], 0
    je .skip_fuel2_move
    inc word [fuel2_y]
    cmp word [fuel2_y], 190
    jle .skip_fuel2_move
    mov byte [fuel2_active], 0
.skip_fuel2_move:
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
    inc word [obstacle_y]
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
    call draw_oponent_car
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
.done_anim:
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
    add ax, 40
    cmp dx, 1
    je .lane_ready
    add ax, 40
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
.r_left_loop:
    cmp dx, 120        
    jge near .r_left_done
   
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
    jge near .check_middle
    mov byte [es:di+3], 0x0F
    mov byte [es:di+4], 0x0F
    mov byte [es:di+5], 0x0F
    mov byte [es:di+6], 0x0F
    mov byte [es:di+7], 0x0F
    mov byte [es:di+8], 0x0F
    mov byte [es:di+9], 0x0F
    mov byte [es:di+10], 0x0F
    jmp near .next_left_row
   
.check_middle:
    cmp ax, 19
    jge near .check_middle_bar
    mov byte [es:di+10], 0x0F
    mov byte [es:di+11], 0x0F
    mov byte [es:di+12], 0x0F
    jmp near .next_left_row
   
.check_middle_bar:
    cmp ax, 23
    jge near .check_diagonal
    mov byte [es:di+3], 0x0F
    mov byte [es:di+4], 0x0F
    mov byte [es:di+5], 0x0F
    mov byte [es:di+6], 0x0F
    mov byte [es:di+7], 0x0F
    mov byte [es:di+8], 0x0F
    mov byte [es:di+9], 0x0F
    jmp near .next_left_row
   
.check_diagonal:
    sub ax, 23
    mov cx, ax
    shr cx, 1          
    add cx, 6
    add di, cx
    mov byte [es:di], 0x0F
    mov byte [es:di+1], 0x0F
    mov byte [es:di+2], 0x0F
   
.next_left_row:
    inc dx
    jmp near .r_left_loop
   
.r_left_done:
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
.i_right_loop:
    cmp dx, 120        
    jge near .i_right_done
   
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
    jge near .check_middle_i
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
    jmp near .next_i_row
   
.check_middle_i:
    cmp ax, 36
    jge near .check_bottom_i
    mov byte [es:di+5], 0x0F
    mov byte [es:di+6], 0x0F
    mov byte [es:di+7], 0x0F
    jmp near .next_i_row
   
.check_bottom_i:
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
   
.next_i_row:
    inc dx
    jmp near .i_right_loop
   
.i_right_done:
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
    push si
   
    mov ax, [buffer_segment]
    mov es, ax
    inc byte [road_scroll]
    and byte [road_scroll], 0x0F  
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
    mov byte [es:di], 0x0F     
    mov byte [es:di+1], 0x0F
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
    mov byte [es:di], 0x0F     
    mov byte [es:di+1], 0x0F
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
    pop si
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
    mov cx, 6
    rep stosb
    mov byte [es:di-6], 0x0F  
    mov byte [es:di-1], 0x0F  
    mov byte [es:di-4], 0x0F  
    mov byte [es:di-3], 0x0F
    jmp .next_row
.check_window:
    cmp si, 5
    jge .check_body
    mov al, 0x07
    mov cx, 10
    rep stosb
    jmp .next_row
.check_body:
    mov al, cl
    mov cx, 10
    rep stosb
    mov byte [es:di-10], 0x00  
    mov byte [es:di-1],  0x00
    cmp si, 6
    je .add_wheels
    cmp si, 11
    je .add_wheels
    cmp si, 12
    jl near .next_row
    mov byte [es:di-9],  0x0C  
    mov byte [es:di-2],  0x0C  
    jmp .next_row
.add_wheels:
    mov byte [es:di-10], 0x00
    mov byte [es:di-9],  0x00
    mov byte [es:di-2],  0x00
    mov byte [es:di-1],  0x00
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

draw_oponent_car:
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
    jge near .check_window_d
    add di, 2
    mov al, cl
    mov cx, 6
    rep stosb
    mov byte [es:di-6], 0x0F
    mov byte [es:di-1], 0x0F
    mov byte [es:di-4], 0x0F
    mov byte [es:di-3], 0x0F
    jmp .next_row_d
.check_window_d:
    cmp dx, 5
    jge .check_body_d
    mov al, 0x0B      
    mov cx, 10
    rep stosb
    jmp .next_row_d
.check_body_d:
    mov al, cl
    mov cx, 10
    rep stosb
    cmp dx, 10
    jne .no_roof_light_d
    mov byte [es:di-6], 0x0F
    mov byte [es:di-5], 0x0F
.no_roof_light_d:
    mov byte [es:di-10], 0x00
    mov byte [es:di-1],  0x00
    cmp dx, 6
    je .add_wheels_d
    cmp dx, 11
    je .add_wheels_d
    cmp dx, 12
    jl near .next_row_d
    mov byte [es:di-9],  0x0C
    mov byte [es:di-2],  0x0C
    jmp .next_row_d
.add_wheels_d:
    mov byte [es:di-10], 0x00
    mov byte [es:di-9],  0x00
    mov byte [es:di-2],  0x00
    mov byte [es:di-1],  0x00
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
    pop si
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
    push si
    
    mov si, bx
    mov bx, ax
    mov ax, si
    mov dx, 320
    mul dx
    add ax, bx
    sub ax, 4          
    mov di, ax
    mov ax, [buffer_segment]
    mov es, ax
    mov byte [es:di], 0x08  
    mov byte [es:di+1], 0x08
    mov byte [es:di+2], 0x08
    mov byte [es:di+3], 0x08
    mov byte [es:di+4], 0x08
    mov byte [es:di+5], 0x08
    mov byte [es:di+6], 0x08
    mov byte [es:di+7], 0x08
    add di, 320
    mov byte [es:di], 0x0F      
    mov byte [es:di+1], 0x04    
    mov byte [es:di+2], 0x04
    mov byte [es:di+3], 0x04
    mov byte [es:di+4], 0x04
    mov byte [es:di+5], 0x04
    mov byte [es:di+6], 0x04
    mov byte [es:di+7], 0x0F    
    add di, 320
    mov si, 0
.upper_body:
    cmp si, 2
    jge .middle_body
    mov byte [es:di], 0x04     
    mov byte [es:di+1], 0x0F    
    mov byte [es:di+2], 0x0F
    mov byte [es:di+3], 0x04   
    mov byte [es:di+4], 0x04
    mov byte [es:di+5], 0x04
    mov byte [es:di+6], 0x0C    
    mov byte [es:di+7], 0x04
    add di, 320
    inc si
    jmp .upper_body
.middle_body:
    mov si, 0
.mid_loop:
    cmp si, 2
    jge .lower_body
    
    mov byte [es:di], 0x04      
    mov byte [es:di+1], 0x04
    mov byte [es:di+2], 0x0F        
    mov byte [es:di+3], 0x0F
    mov byte [es:di+4], 0x04    
    mov byte [es:di+5], 0x04
    mov byte [es:di+6], 0x0C    
    mov byte [es:di+7], 0x04
    
    add di, 320
    inc si
    jmp .mid_loop
    
.lower_body:
    mov si, 0
.low_loop:
    cmp si, 3
    jge .bottom
    mov byte [es:di], 0x04      
    mov byte [es:di+1], 0x04
    mov byte [es:di+2], 0x04
    mov byte [es:di+3], 0x04
    mov byte [es:di+4], 0x04
    mov byte [es:di+5], 0x04
    mov byte [es:di+6], 0x0C    
    mov byte [es:di+7], 0x0F    
    add di, 320
    inc si
    jmp .low_loop
.bottom:
    mov byte [es:di], 0x0C      
    mov byte [es:di+1], 0x0C
    mov byte [es:di+2], 0x0C
    mov byte [es:di+3], 0x0C
    mov byte [es:di+4], 0x0C
    mov byte [es:di+5], 0x0C
    mov byte [es:di+6], 0x0C
    mov byte [es:di+7], 0x0C
    pop si
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
    push cx
    push dx
    push es
    push di
    push si
   
    mov ax, [buffer_segment]
    mov es, ax
   
    mov bx, 260
    mov dx, 8
    call draw_single_life
   
    mov bx, 275
    mov dx, 8
    call draw_single_life
   
    mov bx, 290
    mov dx, 8
    call draw_single_life
   
    pop si
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_single_life:
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
    mov al, 12
    mov cx, 4
    rep stosb
    add di, 320 - 4 - 3
   
    add di, 1
    mov al, 12
    mov cx, 8
    rep stosb
    add di, 320 - 8 - 1
   
    mov si, 0
.life_middle:
    cmp si, 6
    jge .life_bottom
   
    mov al, 12
    mov cx, 10
    rep stosb
   
    add di, 320 - 10
    inc si
    jmp .life_middle
   
.life_bottom:
    add di, 1
    mov al, 12
    mov cx, 8
    rep stosb
    add di, 320 - 8 - 1
   
    add di, 3
    mov al, 12
    mov cx, 4
    rep stosb
   
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_fuel:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    push si
   
    mov ax, [buffer_segment]
    mov es, ax
   
    mov ax, 187
    mov bx, 320
    mul bx
    add ax, 265    
    mov di, ax
    push di
   
    mov al, 0x02
    add di, 2
    mov cx, 34
    rep stosb
    pop di
   
    add di, 38
    add di, 320 - 38
   
    mov dx, 0          
    mov si, 6      

.draw1:
    mov cx, 38  
    rep stosb
   
    inc dx
    cmp dx, si
    je .done1
   
    add di, 320 - 38  
    jmp .draw1

.done1:
    add di, 320 - 38
    add di, 2
    mov cx, 34
    rep stosb
   
    pop si
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_coins:
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
    call draw_single_coin
   
    mov bx, 22
    mov dx, 185
    call draw_single_coin
   
    mov bx, 34
    mov dx, 185
    call draw_single_coin
   
    pop si
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_single_coin:
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
player_x         dw 160
player_y         dw 175
y_pos            dw 0

oldisr           dd 0
obstacle_x       dw 0
obstacle_y       dw 0
obstacle_active  db 0
obstacle_counter db 0
OBSTACLE_INTERVAL db 24     
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
COIN_INTERVAL    db 40      
fuel1_x          dw 0
fuel1_y          dw 0
fuel1_active     db 0
fuel2_x          dw 0
fuel2_y          dw 0
fuel2_active     db 0
fuel_counter     db 0
FUEL_INTERVAL    db 1092
flag             db 0
left_pressed     db 0
right_pressed    db 0
down_pressed     db 0
up_pressed       db 0
current_lane     db 1
road_scroll      db 0    
paused           db 0
buffer_x         dw 100
buffer_y         dw 80
buffer_segment   dw 0x7000 