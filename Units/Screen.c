proc Screen.SetMode uses bx,\
     bMode

     mov        ah, $0F
     int        10h
     mov        [Screen.bOldMode], al
     mov        [Screen.bOldPage], bh

     movzx      ax, byte [bMode]
     mov        [Screen.bCurrMode], al
     int        10h
     ret
endp

proc Screen.RestoreMode
     movzx      ax, [Screen.bOldMode]
     int        10h

     mov        ah, $05
     mov        al, [Screen.bOldPage]
     int        10h
     ret
endp

proc Screen.HideCursor uses bx
     mov        ah, $03
     xor        bh, bh
     int        10h
     mov        [Screen.wCursorSize], cx

     mov        ah, $01
     mov        cx, $2000
     int        10h
     ret
endp

proc Screen.ShowCursor
     mov        ah, $01
     mov        cx, [Screen.wCursorSize]
     int        10h
     ret
endp

nil = 0
Screen.ClearProcedures          dw      nil, nil, nil, Screen.Clear_Mode03,\
                                        nil, nil, nil, nil,\
                                        nil, nil, nil, nil,\
                                        nil, nil, nil, nil,\
                                        nil, nil, nil, Screen.Clear_Mode13
Screen.ClearProcedures.Count    = ($ - Screen.ClearProcedures) / 2

proc Screen.Clear uses bx
     movzx      bx, [Screen.bCurrMode]
     cmp        bx, Screen.ClearProcedures.Count
     jae        .EndProc

     shl        bx, 1
     mov        bx, [bx + Screen.ClearProcedures]
     test       bx, bx
     jz         .EndProc
     stdcall    bx
.EndProc:
     ret
endp

proc Screen.Clear_Mode03 uses es di
     push       $B800
     pop        es
     mov        ax, $0700 or ' '
     mov        cx, 80 * 25
     xor        di, di
     rep stosw
     ret
endp

proc Screen.Clear_Mode13 uses es di
     push       $A000
     pop        es
     xor        di, di
     mov        cx, 320 * 200
     xor        ax, ax
     rep stosb
     ret
endp

proc Screen.WriteString uses es si di,\
     pString, nLine, alType

     push       $B800
     pop        es
     imul       di, [nLine], 80 * 2
     mov        si, [pString]
     lodsb
     movzx      cx, al
     cmp        [alType], ALIGN_LEFT
     je         .StartOutput
     mov        dx, 80
     sub        dx, cx
     cmp        [alType], ALIGN_RIGHT
     je         .Right
.Center:
     shr        dx, 1
.Right:
     shl        dx, 1
     add        di, dx
.StartOutput:
     mov        ah, $07
.OutputLoop:
     lodsb
     stosw
     loop       .OutputLoop
     ret
endp

proc Screen.Rectangle uses es di,\
     X, Y, W, H, Color

     push       $A000
     pop        es
     imul       di, [Y], 320
     add        di, [X]
     mov        al, byte [Color]
     mov        cx, [H]
.RowLoop:
     push       cx
     mov        cx, [W]
     rep stosb
     pop        cx
     add        di, 320
     sub        di, [W]
     loop       .RowLoop
     ret
endp