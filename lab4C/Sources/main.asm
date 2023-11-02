;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 
           ;************************************************************
;* Timer Alams *
;************************************************************
;definitions
OneSec          EQU   23 ; 1 second delay (at 23Hz)
TwoSec          EQU   46 ; 2 second delay (at 23Hz)
LCD_DAT       EQU   PORTB ; LCD data port, bits - PB7,...,PB0
LCD_CNTR   EQU    PTJ ; LCD control port, bits - PJ7(E),PJ6(RS)
LCD_E            EQU    $80 ; LCD E-signal pin
LCD_RS         EQU    $40 ; LCD RS-signal pin

;variable/data section
            ORG $3850 ; Where our TOF counter register lives
TOF_COUNTER RMB 1 ; The timer, incremented at 23Hz
AT_DEMO     RMB 1 ; The alarm time for this demo

;code section
            ORG $4000 ; Where the code starts
Entry:
_Startup:
            LDS #$4000 ; initialize the stack pointer
            JSR initLCD ; initialize the LCD
            JSR clrLCD ; clear LCD & home cursor
            JSR ENABLE_TOF ; Jump to TOF initialization
            CLI ; Enable global interrupt        
            
            
            LDAA #$41 ;play A (for 1 sec)
            JSR putcLCD ; --"--
            
            
            LDAA TOF_COUNTER ; Initialize the alarm time
            ADDA #OneSec ; by adding on the 1 sec delay
            STAA AT_DEMO ; and save it in the alarm
            
CHK_DELAY_1 LDAA TOF_COUNTER ; If the current time
            CMPA AT_DEMO ; equals the alarm time
            BEQ A1 ; then display B
            BRA CHK_DELAY_1 ; and check the alarm again
            
A1          JSR clrLCD ; clear LCD & home cursor
               LDAA #'B';Display B (for 2 sec)
              JSR putcLCD ; --"--
              LDAA AT_DEMO ; Initialize the alarm time
              ADDA #TwoSec ; by adding on the 2 sec delay
              STAA AT_DEMO ; and save it in the alarm
            
CHK_DELAY_2 LDAA TOF_COUNTER ; If the current time
            CMPA AT_DEMO ; equals the alarm time
            BEQ A2 ; then display C
            BRA CHK_DELAY_2 ; and check the alarm again
            
A2          JSR clrLCD ; clear LCD & home cursor
            LDAA #'C'; Display C (forever)
            JSR putcLCD ; --"--
            SWI
;subroutine section
;*******************************************************************
;* Initialization of the LCD: 4-bit data width, 2-line display, *
;* turn on display, cursor and blinking off. Shift cursor right. *
;*******************************************************************
;FROM LAB 2
initLCD   BSET  DDRB,%11111111   ;Configure pins PB7-PB0 as output for port B
          BSET  DDRJ,%11000000          ;Configure pins 6 (Contol Byte of LCD- RS) and 7(Connected to enable output on the keypad and Enable on LCD - E) as ouputs of port J
          LDY   #2000                                    ;Load register Y with decimal 2000  - delay by 0.1sec
          JSR   del_50us                               ;jump to delay 50us subroutine
          LDAA  #$28                                      ;Load accumulatore a with a hex value of 28    , set 4-bit daya, 2-line display
          JSR   cmd2LCD                              ;jump to cmd2LCD subroutine
          LDAA  #$0C                                      ;  Display will be on, cursor off, blinking off
          JSR   cmd2LCD                              ; jump to cmd2LCD subroutine
          LDAA  #$06                                       ;Entry Mode set, movve cursor right after entering a character
          JSR   cmd2LCD                               ; jump to cmd2LCD subroutine
          RTS                                                      ;return from subroutine

;FROM LAB 2
clrLCD    LDAA  #$01        ;Clear display and return to home position
          JSR   cmd2LCD          ; jump to cmd2LCD subroutine
          LDY   #40                         ;Load register Y with decimal 40
          JSR   del_50us             ;jump to delay 50us subroutine
          RTS                                   ;return from subroutine
          
;FROM LAB 2
del_50us: PSHX             ;Stack point will subtract by 2 and high bits of X will go on top and low bits of X will go on bottom to safe info about X 
eloop:    LDX   #30           ;Loads decimal 30 to register X
iloop:    PSHA                    ;Wasting TIME
          PULA
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP
          NOP                     ;21 NOP
          PSHA
          PULA
          NOP
          NOP
          DBNE  X,iloop          ;decrement X and branch to iloop if answer if not equal to zero
          DBNE  Y,eloop          ;decrement Y and branch to eloop if answer if not equal to zero
          PULX                            ;Pull the first two bytes from stack and store then into X again and adds SP by 2
          RTS   
          
;FROM LAB 2
;Sends command from accumulator A to the LCD

cmd2LCD:  BCLR  LCD_CNTR,LCD_RS           ;Clear actual pin 7 in Port E -->0
          JSR   dataMov                                                  ;Jump to subroutine dataMov
          RTS                                                                     ;return from subroutine
          
;FROM LAB2       
;Outputs a Null terminated string to by register x

putsLCD   LDAA  1,X+                           ;Load   acc A with X and then add 1 to X
          BEQ   donePS                              ;Branch if equal to zero
          JSR   putcLCD                              ;jump to subroutine putcLCD to display the character
          BRA   putsLCD                              ;Load will load the next letter
donePS    RTS                                          ;return from subroutine


;FROM LAB 2
;Outputs the character in accumulator A to Lcd

putcLCD   BSET  LCD_CNTR,LCD_RS        ;Set the RS - > Control Byte     
          JSR   dataMov                                           ;jump subroute datamov to display character
          RTS


;FROM LAB 2
dataMov   BSET  LCD_CNTR,LCD_E                 ;Set actual pin 4 to a 1 in Port E  (E-SIGNAL is high)
          STAA  LCD_DAT                                            ;Send high bits of  acc A to port S (Data Bye of LCD)
          BCLR  LCD_CNTR,LCD_E                         ;Clear port E's pin 4 ->0
          
          LSLA                                                                   ;Sfift A by four to the left
          LSLA
          LSLA
          LSLA
          
          BSET  LCD_CNTR,LCD_E                       ;set the E-signal to a 1   (ready to read)
          STAA  LCD_DAT                                          ;Sending the lower 4 bits of Acc A to Data byte
          BCLR  LCD_CNTR,LCD_E                        ;Clear E-signal             (done reading)
                                                                                     
          LDY   #1                                                          ;Load decimal 1 register Y
          JSR   del_50us                                              ;Jump to delay 5us subrouine
          RTS      
            
;************************************************************
ENABLE_TOF  LDAA #%10000000
                            STAA TSCR1 ; Enable TCNT
                            STAA TFLG2 ; Clear TOF
                            LDAA #%10000100 ; Enable TOI and select prescale factor equal to 16
                            STAA TSCR2
                            RTS

;************************************************************
TOF_ISR     INC TOF_COUNTER
                      LDAA #%10000000; Clear
                      STAA TFLG2 ; TOF
                      RTI
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
            
            ORG   $FFDE
            DC.W  TOF_ISR   ;Place that address of the TOF interrupt routine in the interrupt vector 
