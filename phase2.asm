org 0x100
start:
    ; Set video mode 13h (320x200, 256 colors)
    mov ax, 0x0013
    int 0x10
    
    ; Draw background (black screen)
    call clear_screen
    
    ; Draw green borders
    call draw_borders
    
    ; Draw the road
    call draw_road
    
    ; ... existing code ...
    ; Draw cars
    ; call draw_cars            ; (no longer needed, replaced by animation loop)
    ; ... existing code ...
    call draw_letter_i_right
    call draw_letter_r_left
    call draw_lives
    call draw_fuel
    call draw_coins
    ; --- Animation init and loop ---
    call init_animation

.anim_loop:
    ; Redraw the static road area to clear previous sprite frames
    call draw_road

    ; Update positions, spawn obstacle at intervals, draw sprites
    call animate_frame

    ; Terminate loop on any key press
    mov ah, 0x01
    int 0x16
    jz .keep_loop
    xor ax, ax
    int 0x16
    jmp .after_loop

.keep_loop:
    call delay_tick
    jmp .anim_loop

.after_loop:
    ; Return to text mode
    mov ax, 0x0003
    int 0x10
    
    ; Exit
    mov ax, 0x4C00
    int 0x21
; ... existing code ...

;===========================================
; Animation helpers and state
;===========================================
init_animation:
    mov word [player_x], 160
    mov word [player_y], 175
    mov byte [obstacle_active], 0
    mov byte [obstacle_counter], 0
    ret

delay_tick:
    push ax
    push cx
    push dx
    mov ah, 0
    int 0x1A          ; CX:DX = ticks since midnight
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

; Frame update: move player slightly upward, spawn/move obstacle, then draw both
animate_frame:
    push ax
    push bx
    push cx
    push dx
    ; Obstacle spawn/move
    inc byte [obstacle_counter]
    cmp byte [obstacle_active], 0
    jne .move_obs
    mov al, [OBSTACLE_INTERVAL]
    cmp [obstacle_counter], al
    jb .draw_all
    call choose_lane_x
    mov [obstacle_x], ax
    mov word [obstacle_y], 10
    mov byte [obstacle_active], 1
    mov byte [obstacle_counter], 0
    jmp .draw_all

.move_obs:
    inc word [obstacle_y]
    cmp word [obstacle_y], 190
    jle .draw_all
    mov byte [obstacle_active], 0

.draw_all:
    ; Draw player (UP)
    mov ax, [player_x]
    mov bx, [player_y]
    mov cl, 0x0C
    call draw_player_car

    ; Draw obstacle (DOWN), blue
    cmp byte [obstacle_active], 0
    je .done_anim
    mov ax, [obstacle_x]
    mov bx, [obstacle_y]
    mov cl, 0x01
    call draw_oponent_car

.done_anim:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Lane chooser (X center = 120 / 160 / 200)
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

; ... existing code ...
;===========================================
; Clear screen to black
;===========================================
clear_screen:
    push ax
    push cx
    push es
    push di
    mov ax, 0xA000
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
    mov ax, 0xA000
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
    mov ax, 0xA000
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
    mov ax, 0xA000
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
    mov ax, 0xA000
    mov es, ax
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
    test dx, 0x04
    jz .draw_gray
    mov al, 0x08
.draw_gray:
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
    test dx, 0x08
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
    test dx, 0x08
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
    test dx, 0x10
    jz .left_barr
    mov al, 0x0F        
.left_barr:
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
    test dx, 0x10
    jz .right_barr
    mov al, 0x0F
.right_barr:
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
draw_cars:
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
    mov bx, 40
    mov cl, 0x0E
    call draw_oponent_car
    mov ax, 160
    mov bx, 165
    mov cl, 0x0C            
    call draw_player_car
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
    mov ax, 0xA000
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
    mov ax, 0xA000
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
draw_lives:
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    push si
    
    mov ax, 0xA000
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
    
    mov ax, 0xA000
    mov es, ax
    
    
    mov ax, 187
    mov bx, 320
    mul bx
    add ax, 265     
    mov di, ax
    push di
    
    
    
    mov al, 0x02 
    add di,2
    mov cx,34
    rep stosb
    pop di
    
    add di,38
    add di,320-38
    
    
      
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
    add di,320-38
    add di,2
    mov cx,34
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
    
    mov ax, 0xA000
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
    ; Row 8: 8 pixels
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
player_y          dw 175

obstacle_x        dw 0
obstacle_y        dw 0
obstacle_active   db 0
obstacle_counter  db 0
OBSTACLE_INTERVAL db 24