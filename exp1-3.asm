ORG 0000H
LJMP INIT
ORG 0100H

INIT:
    N1 EQU 41H
    N2 EQU 42H
    N3 EQU 43H
    N4 EQU 44H
    TMP EQU 45H

    MOV N1, #0
    MOV N2, #0
    MOV N3, #0
    MOV N4, #0
    MOV TMP, #0

MAIN:
    LCALL READ
    LCALL DISPLAY
    LCALL DELAY10
    LJMP MAIN

; 读取示数
READ:
    ; 接受1，2信号
    CLR P1.7
    MOV DPTR, #0BFFFH
    MOVX A, @DPTR
    CPL A
    MOV TMP, A; 将bcd盘输入暂存
    ; 解码第一个输入
    ANL A, #00001111B
    MOV N1, A
    ; 解码第二个输入
    MOV A, TMP
    ANL A, #11110000B
    SWAP A
    MOV N2, A

    ; 接受3，4信号
    SETB P1.7
    MOV DPTR, #0BFFFH
    MOVX A, @DPTR
    CPL A
    MOV TMP, A; 将bcd盘输入暂存
    ; 解码第一个输入
    ANL A, #00001111B
    MOV N3, A
    ; 解码第二个输入
    MOV A, TMP
    ANL A, #11110000B
    SWAP A
    MOV N4, A

    RET

DISPLAY:
    ; ADDRESS_LIST: 7FF8H,7FF9H,7FFAH,7FFBH
    MOV A, N1
    ANL A, #00001111B
    MOV DPTR, #MAPNUM
    MOVC A, @A+DPTR
    MOV DPTR, #7FF8H
    ANL A, #01111111B;
    MOVX @DPTR, A

    MOV A, N2
    ANL A, #00001111B
    MOV DPTR, #MAPNUM
    MOVC A, @A+DPTR
    MOV DPTR, #7FF9H
    ANL A, #01111111B;
    MOVX @DPTR, A

    MOV A, N3
    ANL A, #00001111B
    MOV DPTR, #MAPNUM
    MOVC A, @A+DPTR
    MOV DPTR, #7FFAH
    ANL A, #01111111B;
    MOVX @DPTR, A

    MOV A, N4
    ANL A, #00001111B
    MOV DPTR, #MAPNUM
    MOVC A, @A+DPTR
    MOV DPTR, #7FFBH
    ANL A, #01111111B;
    MOVX @DPTR, A

    RET

DELAY10:
    NOP
    NOP; 2*T
    MOV R6, #5; 1*T
    DEL2:
    MOV R5, #98; 5*1*T
    DEL1:
    DJNZ R5, DEL1; 5*98*2*T
    DJNZ R6, DEL2; 5*2*T
    RET; 2*T
    ;共计1000T,恰好10ms

MAPNUM:
    DB 0C0H
    DB 0F9H
    DB 0A4H
    DB 0B0H
    DB 99H
    DB 92H
    DB 82H
    DB 0F8H
    DB 80H
    DB 090H
    DB 88H
    DB 83H
    DB 0C6H
    DB 0A1H
    DB 86H
    DB 8EH

END
