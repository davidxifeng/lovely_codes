; Jul 27

        org 7c00h ; start addr
        mov ax, cs
        mov ds, ax
        mov es, ax
        call DisplayStr
        jmp $

DisplayStr:
        mov ax, Message
        mov bp, ax
        mov cx, msg_len
        mov ax, 1301h ;
        mov bx, 000ch ; bh = 00 red on black, bl = 0c highlight
        mov dl, 0
        int 10h
        ret

Message:
        db "hello OS world!", 13, 10
        db "this is a second line", 13, 10
        db "bochs is really a great software and very easy to use", 13, 10
msg_len equ $ - Message
times 510 - ($ - $$) db 0
        dw 0xaa55

; vim: tabstop=8 softtabstop=8 shiftwidth=8
