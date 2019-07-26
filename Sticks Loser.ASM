STICKS_MIN      = 15
STICKS_MAX      = 30

ROW_STICKS      = 11
ROW_HINT        = 13

FALSE           = 0
TRUE            = 1

        org 100h
        include 'macro\proc16.inc'

        include 'Units\Random.h'
        include 'Units\Screen.h'
        include 'Units\Keyboard.h'

PLAYER_COMPUTER = 0
PLAYER_USER     = 1

struc String Params&
{
  local ..EndOfString
  . db ..EndOfString - . - 1
    db Params
  ..EndOfString:
}

EntryPoint:
        stdcall Random.Initialize
        stdcall Screen.SetMode, $13

        stdcall Controller.StartGame
.GameLoop:
        stdcall Keyboard.ReadKey
        stdcall Controller.ProcessInput, ax
        test    ax, ax
        jnz     .GameLoop

        stdcall Screen.RestoreMode
        ret

        include 'Units\Random.c'
        include 'Units\Screen.c'
        include 'Units\Keyboard.c'

Controller.StartGame = Model.StartGame

proc Controller.ProcessInput\
     keyCode

     xor        ax, ax
     cmp        [keyCode], KEY_ESCAPE
     je         .EndProc

     stdcall    Model.GetNextPlayer
     cmp        ax, PLAYER_USER
     je         .User
.Computer:
     stdcall    Model.GetNextComputerMove
     stdcall    Model.MakeMove, ax
     jmp        .Done
.User:
     mov        ax, [keyCode]
     cmp        ax, '1'
     jb         .EndProc
     cmp        ax, '3'
     ja         .EndProc
     sub        ax, '0'
     stdcall    Model.MakeMove, ax
.Done:
     stdcall    Model.GetStickCount
.EndProc:
     ret
endp

proc View.DrawDesk uses es bx

STICK_WIDTH     = 2
GAP_WIDTH       = 5

     stdcall    Screen.Clear

     stdcall    Model.GetInitialCount
     imul       ax, (STICK_WIDTH + GAP_WIDTH)
     sub        ax, GAP_WIDTH
     mov        bx, ax

     stdcall    Model.GetStickCount
     mov        cx, ax
.DrawLoop:
     push       cx
     stdcall    Screen.Rectangle, bx, 50, STICK_WIDTH, 50, $60
     pop        cx
     add        bx, STICK_WIDTH + GAP_WIDTH
     loop       .DrawLoop

;     stdcall    Model.GetNextPlayer
;     cmp        ax, PLAYER_USER
;     je         .User
;.Computer:
;     stdcall    Model.GetNextComputerMove
;     add        al, '0'
;     mov        [chStickCount], al
;     stdcall    Screen.WriteString, strHintComputerMove, ROW_HINT, ALIGN_CENTER
;     jmp        .EndProc
;.User:
;     stdcall    Screen.WriteString, strHintUserMove, ROW_HINT, ALIGN_CENTER
.EndProc:
     ret
endp

proc Model.StartGame
     stdcall    Random.Get, STICKS_MIN, STICKS_MAX
     mov        [Model.wSticksInitial], ax
     mov        [Model.wSticksLeft], ax
     mov        [Model.plNext], PLAYER_USER

     stdcall    View.DrawDesk
     ret
endp

proc Model.MakeMove\
     nSticks

     mov        ax, [nSticks]
     cmp        [Model.wSticksLeft], ax
     jb         .EndProc
     sub        [Model.wSticksLeft], ax
     xor        [Model.plNext], 1
     jne        @F

     ; <AI>
     mov        ax, [Model.wSticksLeft]
     dec        ax
     and        ax, 00000011b
     jnz        .Done
     ; </AI>

     mov        ax, [Model.wSticksLeft]
     sub        ax, 3
     cwd
     and        ax, dx
     add        ax, 3
     stdcall    Random.Get, 1, ax
.Done:
     mov        [Model.wNextComputerMove], ax

@@:
     stdcall    View.DrawDesk
.EndProc:
     ret
endp

proc Model.IsGameOver
     xor        ax, ax
     cmp        [Model.wSticksLeft], ax
     sete       al
     ret
endp

proc Model.GetStickCount
     mov        ax, [Model.wSticksLeft]
     ret
endp

proc Model.GetInitialCount
     mov        ax, [Model.wSticksInitial]
     ret
endp

proc Model.GetNextPlayer
     mov        ax, [Model.plNext]
     ret
endp

proc Model.GetNextComputerMove
     mov        ax, [Model.wNextComputerMove]
     ret
endp

        include 'Units\Random.di'
        include 'Units\Screen.di'
        include 'Units\Keyboard.di'

strHintUserMove         String  'Press (1), (2) or (3), or (Esc) to quit'
strHintComputerMove     db      strHintComputerMove.End - strHintComputerMove - 1
                        db      'I take '
chStickCount            db      ' '
                        db      ' sticks. Press any key...'
strHintComputerMove.End:

        include 'Units\Random.du'
        include 'Units\Screen.du'
        include 'Units\Keyboard.du'

Model.wSticksInitial    dw      ?
Model.wSticksLeft       dw      ?
Model.wNextComputerMove dw      ?
Model.plNext            dw      ?