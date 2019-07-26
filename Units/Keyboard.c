proc Keyboard.ReadKey
     xor        dx, dx
     mov        ax, $0C08
     int        21h
     mov        dl, al
     test       al, al
     jnz        @F
     mov        ah, $08
     int        21h
     mov        dh, al
@@:
     mov        ax, dx
     ret
endp