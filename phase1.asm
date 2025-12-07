org 0x100
start:
   mov ax, 0x0013
    int 0x10
    call clear_screen
    call draw_borders
    call draw_letter_r_left
    call draw_letter_i_right
    call draw_road
    call draw_cars
    xor ax, ax
    int 0x16
    mov ax, 0x0003
    int 0x10
    mov ax, 0x4C00
    int 0x21
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
    jge .done
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
    jl .next_row
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
    jge .check_window_d
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
    jl .next_row_d
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