SEC EQU 40H; 秒
MIN EQU 41H; 分
LEDM2 EQU 30H; 显示分十位
LEDM1 EQU 31H; 显示分个位
LEDS2 EQU 32H; 显示秒十位
LEDS1 EQU 33H; 显示秒个位
TCOUNT EQU 34H; 用于记录20个中断周期，标志1s

ORG 0000H
LJMP START
ORG 001BH
LJMP INT_1

ORG 0100H
;*************************************
;           主程序开始
;*************************************
START:
    MOV SP, #50H; 设定堆栈地址
    MOV TCOUNT, #0
    MOV SEC, #0
    MOV MIN, #0
    MOV TMOD, #10H
    MOV TH1, #3CH
    MOV TL1, #0B0H
    ; t = (2^16-定时初值)*机器周期
    ; 这里: 定时初值 = 3CB0H;  中断周期 = 0.05s
    ; 1s 需要经历约 20 个中断周期
    SETB EA; 允许中断
    SETB ET1; 允许定时器1中断
    SETB TR1; 定时器1启动

MAIN:
    ; 秒，低位
    MOV A, SEC
    ANL A, #00001111B; 取低四位
    MOV LEDS1, A
    ; 秒，高位
    MOV A, SEC
    ANL A, #11110000B; 高四位
    SWAP A; 把高四位转化为低四位用于显示
    MOV LEDS2, A
    ; 分，高位
    MOV A, MIN; 存储分
    ANL A, #11110000B
    SWAP A
    MOV LEDM2, A; 存储分钟的显示
    ; 分，低位
    MOV A, MIN;
    ANL A, #00001111B
    MOV LEDM1, A
    LCALL DISPLAY; 调用显示
LJMP MAIN
;***************************************
;              示数子程序
;***************************************
DISPLAY:
    MOV A, LEDM2;
    ANL A, #00001111B; 取后4位
    MOV DPTR, #MAPNUM; 读取表格头指针
    MOVC A, @A+DPTR; 经典的数组索引方法
    MOV DPTR, #7FF3H;
    MOVX @DPTR, A

    MOV A, LEDM1
    ANL A, #00001111B; 取后四位
    MOV DPTR, #MAPNUM
    MOVC A, @A+DPTR
    MOV DPTR, #7FF2H
    ANL A, #01111111B;
    MOVX @DPTR, A

    MOV A, LEDS2
    ANL A, #0FH
    MOV DPTR, #MAPNUM
    MOVC A, @A+DPTR
    MOV DPTR, #7EF1H
    MOVX @DPTR, A

    MOV A, LEDS1
    ANL A, #0FH
    MOV DPTR, #MAPNUM
    MOVC A, @A+DPTR
    MOV DPTR, #7FF0H
    MOVX @DPTR, A
    RET
;***************************************
;          中断INT_1子程序开始
;***************************************
INT_1:
    ; 一次中断的时间是50ms
    ; 判断是否达到1s
    PUSH PSW; 程序状态字
    PUSH ACC; 累加器
    JNB P1.0, WAIT_FOR_RESUME;
TIME_RESET:
    MOV TH1, #3CH; d
    MOV TL1, #0B0H; d
    INC TCOUNT
    MOV A, TCOUNT
    CJNE A, #14H, INT_1_RET; 计数器==20次 ? 继续 : 结束中断
    MOV TCOUNT, #00H; 满足条件, 计数器清零

    ; 读入秒数，+1
    MOV A, SEC
    ADD A, #1
    DA A; 将A从16进制数转化为8421码
    MOV SEC, A;把8421码存储到SEC单元

    ; 若满足进位条件，则读入分钟+1
    CJNE A, #60H, INT_1_RET; 与立即数60H比较
    MOV SEC, #00H; 清零60S
    MOV A, MIN
    ADD A, #01H; 分进位
    DA A; 转化为8421
    MOV MIN, A

    CJNE A, #60H, INT_1_RET; 是否满一小时
    MOV MIN, #00H; 分清零
    MOV SEC, #00H; 秒清零
    LJMP INT_1_RET

WAIT_FOR_RESUME:
    LCALL DELAY
    JNB P1.2, REST
    JB P1.1, WAIT_FOR_RESUME
    LJMP TIME_RESET; 回到时间常数重置，继续完成中断
; 触发清零
REST:
    MOV SEC, #0
    MOV MIN, #0
    MOV LEDM1, #0
    MOV LEDM2, #0
    MOV LEDS1, #0
    MOV LEDS2, #0
    LCALL DISPLAY
    LJMP WAIT_FOR_RESUME; 返回循环等待继续按钮按下
; 中断结束
INT_1_RET:
    POP ACC
    POP PSW
    RETI

;*************************************************
;           延时子程序；10ms，T=1E-6 s
;*************************************************
DELAY:
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
    DB 0C0H, 0F9H, 0A4H, 0B0H
    DB 99H,  92H,  82H,  0F8H
    DB 80H,  090H, 88H,  83H
    DB 0C6H, 0A1H, 86H,  8EH
