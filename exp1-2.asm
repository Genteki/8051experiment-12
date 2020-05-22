ORG 0000H
LJMP INIT

ORG 0100H
INIT:
    NUM EQU 40H
    N1 EQU 41H
    N2 EQU 42H
    N3 EQU 43H
    N4 EQU 44H
    NI EQU 45H
    NADD EQU 46H


    MOV N1, #1
    MOV N2, #2
    MOV N3, #3
    MOV N4, #4
    MOV NI, #0
    MOV NADD, #41H

    LJMP MAIN


MAIN:
    LCALL DISPLAY
    LCALL ADDALL
    LCALL DELAY500
    LJMP MAIN

DISPLAY:
; ADDRESS_LIST: 7FF8H,7FF9H,7FFAH,7FFBH

    MOV A, N1
    ANL A, #00001111B; 取后四位
    MOV DPTR, #MAPNUM
    MOVC A, @A+DPTR
    MOV DPTR, #7FF8H
    ANL A, #01111111B;
    MOVX @DPTR, A

    MOV A, N2
    ANL A, #00001111B; 取后四位
    MOV DPTR, #MAPNUM
    MOVC A, @A+DPTR
    MOV DPTR, #7FF9H
    ANL A, #01111111B;
    MOVX @DPTR, A

    MOV A, N3
    ANL A, #00001111B; 取后四位
    MOV DPTR, #MAPNUM
    MOVC A, @A+DPTR
    MOV DPTR, #7FFAH
    ANL A, #01111111B;
    MOVX @DPTR, A

    MOV A, N4
    ANL A, #00001111B; 取后四位
    MOV DPTR, #MAPNUM
    MOVC A, @A+DPTR
    MOV DPTR, #7FFBH
    ANL A, #01111111B;
    MOVX @DPTR, A

    RET

ADDALL:
    MOV R0, NADD
    MOV A, @R0
    INC A                           ; 若a=0FH, inc a会自动回到00h
    MOV @R0, A

    CJNE A, #0FH, ADDALL_END        ; 如果这个数未到达#0fh，子程序结束

    INC NADD                        ; 地址加一，下次从下一个数字开始增加
    MOV A, NADD
    CJNE A, #45H, ADDALL_END     ; 如果未达到#4，子程序结束
    MOV NADD, #41H                  ; 回到41H，下次从第一个数开始增加
ADDALL_END:
    RET


DELAY500:
; T = (2XYZ+3YZ+3Z+3)T = 500.4 ms
    DEL4:   MOV R4, #100
    DEL3:   MOV R5, #120
    DEL2:   MOV R6, #207
    DEL1:   DJNZ R6, DEL1
            DJNZ R5, DEL2
            DJNZ R4, DEL3
    RET

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
