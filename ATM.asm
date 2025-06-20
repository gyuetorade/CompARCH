include 'emu8086.inc'
JMP START

DATA SEGMENT 
    TOTAL        DW 16               ; 16 users: 0 to 15 decimal

    IDS          DW 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

    DATA1        DB '******WELCOME*******',0
    DATA2        DB 0DH,0AH,'ENTER YOUR ID (0-15): ',0
    DATA3        DB 0DH,0AH,'ENTER YOUR PASSWORD: ',0 
    DATA4        DB 0DH,0AH,'DENIED 0',0  
    DATA5        DB 0DH,0AH,'ALLOWED 1',0 
    DATA6        DB '******WELCOME BACK*******',0
    DATA7        DB 0DH,0AH,'Account is locked temporarily',0

    MENU          DB 0DH,0AH,'1.Deposit',0DH,0AH,'2.Withdraw',0DH,0AH,'3.Check Balance',0DH,0AH,'4.Exit',0
    ENTER_CHOICE  DB 0DH,0AH,'Enter your choice: ',0
    ENTER_AMOUNT  DB 0DH,0AH,'Enter amount: ',0
    INSUFFICIENT  DB 0DH,0AH,'Insufficient balance!',0
    THANK_YOU     DB 0DH,0AH,'Thank you for using ATM!',0
    SUCCESS_DEP   DB 0DH,0AH,'Deposit successful!',0
    SUCCESS_WD    DB 0DH,0AH,'Withdrawal successful!',0
    BALANCE_MSG   DB 0DH,0AH,'Account Balance: ',0

    IDINPUT      DW ?
    PASSINPUT    DW ?
    ATTEMPTS     DB ?

    BALANCE      DW 100      ; Initial balance 100 units
DATA ENDS

CODE SEGMENT

START:
    MOV AX, DATA
    MOV DS, AX  

    DEFINE_SCAN_NUM           
    DEFINE_PRINT_STRING 
    DEFINE_PRINT_NUM
    DEFINE_PRINT_NUM_UNS 

AGAIN:
    LEA SI, DATA1
    CALL PRINT_STRING
    LEA SI, DATA2
    CALL PRINT_STRING

    CALL SCAN_NUM
    MOV IDINPUT, CX
    MOV AX, CX
    MOV CX, 0
    MOV SI, -1

L1: 
    INC CX
    CMP CX, TOTAL
    JE ERROR
    INC SI
    MOV DX, SI
    CMP IDS[SI*2], AX
    JE PASS_CHECK
    JMP L1

;-------------------------
; PASSWORD CHECK: password = user ID
;-------------------------
PASS_CHECK:
    MOV ATTEMPTS, 3
PASS_LOOP:
    LEA SI, DATA3
    CALL PRINT_STRING        
    CALL SCAN_NUM
    MOV PASSINPUT, CX

    ; Check if password == IDINPUT
    MOV AX, IDINPUT
    CMP CX, AX
    JE DONE

    ; Wrong password
    DEC ATTEMPTS
    CMP ATTEMPTS, 0
    JE LOCKED
    JMP PASS_LOOP

;-------------------------
; LOCKOUT DISPLAY
;-------------------------
LOCKED:
    LEA SI, DATA7
    CALL PRINT_STRING
    PRINT 0AH            ; New line
    PRINT 0DH            ; Carriage return
    PRINT 0AH            ; Extra new line for better spacing
    PRINT 0DH            ; Extra carriage return          
    JMP AGAIN

;-------------------------
; IF WRONG ID
;-------------------------
ERROR:
    LEA SI, DATA4
    CALL PRINT_STRING 
    PRINT 0AH      
    PRINT 0DH
    JMP AGAIN 

;-------------------------
; IF SUCCESS - show allowed and go to menu
;-------------------------
DONE:
    LEA SI, DATA5
    CALL PRINT_STRING
    PRINT 0AH      
    PRINT 0DH 
    LEA SI, DATA6
    CALL PRINT_STRING 
    JMP MENU_LOOP

;-------------------------
; MENU LOOP
;-------------------------
MENU_LOOP:
    LEA SI, MENU
    CALL PRINT_STRING

    LEA SI, ENTER_CHOICE
    CALL PRINT_STRING

    CALL SCAN_NUM
    MOV AX, CX           ; choice in AX

    CMP AX, 1
    JE DEPOSIT
    CMP AX, 2
    JE WITHDRAW
    CMP AX, 3
    JE CHECK_BALANCE
    CMP AX, 4
    JE EXIT_ATM

    ; Invalid choice, show menu again
    JMP MENU_LOOP

;-------------------------
; Deposit procedure
;-------------------------
DEPOSIT:
    LEA SI, ENTER_AMOUNT
    CALL PRINT_STRING
    CALL SCAN_NUM
    MOV BX, CX          ; amount to deposit

    MOV AX, BALANCE
    ADD AX, BX
    MOV BALANCE, AX

    LEA SI, SUCCESS_DEP
    CALL PRINT_STRING
    JMP MENU_LOOP

;-------------------------
; Withdraw procedure
;-------------------------
WITHDRAW:
    LEA SI, ENTER_AMOUNT
    CALL PRINT_STRING
    CALL SCAN_NUM
    MOV BX, CX          ; amount to withdraw

    MOV AX, BALANCE
    CMP AX, BX
    JB INSUFF_FUNDS     ; jump if balance < amount

    SUB AX, BX
    MOV BALANCE, AX

    LEA SI, SUCCESS_WD
    CALL PRINT_STRING
    JMP MENU_LOOP

INSUFF_FUNDS:
    LEA SI, INSUFFICIENT
    CALL PRINT_STRING
    JMP MENU_LOOP

;-------------------------
; Check balance procedure
;-------------------------
CHECK_BALANCE:
    LEA SI, BALANCE_MSG   ; Print "Account Balance: "
    CALL PRINT_STRING
    MOV AX, BALANCE
    CALL PRINT_NUM_UNS    ; Print the balance amount
    PRINT 0AH            ; New line
    PRINT 0DH            ; Carriage return
    JMP MENU_LOOP

;-------------------------
; Exit ATM
;-------------------------
EXIT_ATM:
    LEA SI, THANK_YOU
    CALL PRINT_STRING
    PRINT 0AH            ; New line
    PRINT 0DH            ; Carriage return
    PRINT 0AH            ; Extra new line for better spacing
    PRINT 0DH            ; Extra carriage return
    JMP AGAIN           ; restart login

CODE ENDS

END START
