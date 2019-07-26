proc Random.Initialize
     mov        ah, $2C
     int        21h
     mov        [Random.wPrevValue], dx
     ret
endp

proc Random.Get\
     wMin, wMax

     mov        ax, [Random.wPrevValue]
     rol        ax, 7
     add        ax, 23
     mov        [Random.wPrevValue], ax

     xor        dx, dx
     mov        cx, [wMax]
     sub        cx, [wMin]
     inc        cx
     div        cx
     add        dx, [wMin]
     mov        ax, dx
     ret
endp