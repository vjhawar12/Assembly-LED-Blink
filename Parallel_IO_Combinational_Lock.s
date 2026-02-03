;Template - Defining an Assembly File 
;
; Original: Copyright 2014 by Jonathan W. Valvano, valvano@mail.utexas.edu
;
; Modified by: Yaser M. Haddara
; January 28, 2023
; Program for studio 2
; Initial template: implement a combinational lock using FSM
; Goal: implement a sequential lock using FSM
;
; McMaster University, Comp Eng 2DX3
; Further resources: Valvano textbook, Chs. 3 & 4
;

;ADDRESS SETUP
;Define your I/O Port Addresses Here

SYSCTL_RCGCGPIO_R       EQU		0x400FE608         ;Step 1: GPIO Run Mode Clock Gating Control Register Address

GPIO_PORTN_DIR_R		EQU 	0x40064400  ;GPIO Port N Direction Register address 
GPIO_PORTN_DEN_R        EQU 	0x4006451C  ;GPIO Port N Digital Enable Register address
GPIO_PORTN_DATA_R       EQU 	0x400643FC  ;GPIO Port N Data Register address
	
GPIO_PORTM_DIR_R        EQU		0x40063400  ;GPIO Port M Direction Register Address 
GPIO_PORTM_DEN_R        EQU		0x4006351C  ;GPIO Port M Direction Register Address 
GPIO_PORTM_DATA_R       EQU		0x400633FC  ;GPIO Port M Data Register Address      
GPIO_PORTM_PDR_R		EQU		0x40063514	;GPIO Port M Pull-Down Resistor Register Address
	
;Define constants

COMBINATION			EQU		2_111	; this is the sequential combination expected - does NOT include the clock
									; the sequential combination is read RIGHT-TO-LEFT (110 means 0 followed by 1 followed by 1)
COMBINATION_LENGTH	EQU		3		; number of digits in combination (decimal number)
CLOCK_BIT			EQU		2_1000	; clock is on PM2                            



        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT Start

;Function PortM_Init
;Enable Port M and set bits PM0-PM2 for digital input
PortM_Init 
		;STEP 1 Activate clock (Set bit 11 in RCGCGPIO; In C pseudcode: SYSCTL_RCGCGPIO_R |= #0x800)
		 LDR R1, =SYSCTL_RCGCGPIO_R		;Stores the address of the RCGCGPIO register in R1
		 LDR R0, [R1]					;Dereferences R1 to put the contents of the RCGCGPIO register in R0
		 ORR R0,R0, #0x800				;Modifies the contents of R0 to set bit 11 without changing other bits
		 STR R0, [R1]					;Stores the new value into the RCGCGPIO register
		
		;STEP 2: Wait for Peripheral Ready
		 NOP
		 NOP
		 	
		;STEP 3: Set Port Direction 
		LDR R1, =GPIO_PORTM_DIR_R		;Load the memory address of the GPIODIR Port M Register into R1 (pointer)
		LDR R0, [R1]					;Load the contents from the memory address of GPIODIR Port M Register into R0
		BIC R0, R0, #0x0F			;Modify the contents of R0 to clear bits 0 and 2 without changing other bits
		STR R0, [R1]					;Store what is in R0 into address pointed by R1 
		 
		;STEP 4: Enable Digital Functioning 
		LDR R1, =GPIO_PORTM_DEN_R		;Load the memory address of the GPIODEN Port M Register into R1 (pointer)
		LDR R0, [R1]					;Load the contents from the memory address of GPIODEN Port M Register into R0
		ORR R0, R0, #0x0F				;Modify the contents of R0 to set bits 0 and 2 without changing other bits
		STR R0, [R1]					;Store what is in R0 into address pointed by R1 

		
        BX LR               ; return from function 

;Function PortN_Init
;Enable PortN and set bits PN0 and PN1 for digital output
PortN_Init 
		;STEP 1 Activate clock (Set bit 12 in RCGCGPIO; In C pseudcode: SYSCTL_RCGCGPIO_R |= #0x1000)
		 LDR R1, =SYSCTL_RCGCGPIO_R		;Stores the address of the RCGCGPIO register in R1
		 LDR R0, [R1]					;Dereferences R1 to put the contents of the RCGCGPIO register in R0
		 ORR R0,R0, #0x1000				;Modifies the contents of R0 to set bit 12 without changing other bits
		 STR R0, [R1]					;Stores the new value into the RCGCGPIO register
		
		;STEP 2: Wait for Peripheral Ready
		 NOP
		 NOP
		 
		
		;STEP 3: Set Port Direction 
		LDR R1, =GPIO_PORTN_DIR_R		;Load the memory address of the GPIODIR Port N Register into R1 (pointer)
		LDR R0, [R1]					;Load the contents from the memory address of GPIODIR Port N Register into R0
		ORR R0, R0, #0x3				;Modify the contents of R0 to set bits 0 and 1 without changing other bits
		STR R0, [R1]					;Store what is in R0 into address pointed by R1 
		 
		;STEP 4: Enable Digital Functioning 
		LDR R1, =GPIO_PORTN_DEN_R		;Load the memory address of the GPIODEN Port N Register into R1 (pointer)
		LDR R0, [R1]					;Load the contents from the memory address of GPIODEN Port N Register into R0
		ORR R0, R0, #0x3				;Modify the contents of R0 to set bits 0 and 1 without changing other bits
		STR R0, [R1]					;Store what is in R0 into address pointed by R1 

        BX LR               ; return from function 
       

WaitForClockHigh 
		LDR R1, =GPIO_PORTM_DATA_R		;Load the memory address of the GPIODATA Port M Register into R1 (pointer)
		LDR R0, [R1]					;Load the contents from the memory address of GPIODATA Port M Register into R0
		AND R2, R0, #CLOCK_BIT			;Stores result in R2 to avoid changing R0. Result is 0 iff the clock bit is 0.
										;The 'S' modifier updates the flags. If result is 0, Z == 1 and condition EQ is true.
		BEQ WaitForClockHigh			;If it's 0, keep waiting

		LDR R7, =1200000
Debounce
		SUBS R7, R7, #1
		BNE Debounce
		
		BX LR

WaitForClockLow 
		LDR R1, =GPIO_PORTM_DATA_R		;Load the memory address of the GPIODATA Port M Register into R1 (pointer)
		LDR R0, [R1]					;Load the contents from the memory address of GPIODATA Port M Register into R0
		AND R2, R0, #CLOCK_BIT			;Stores result in R2 to avoid changing R0. Result is 0 iff the clock bit is 0.
										;The 'S' modifier updates the flags. If result is 0, Z == 1 and condition EQ is true.
		BNE WaitForClockLow				;If it's not 0, keep waiting
		BX LR


Start 
	    BL PortM_Init       ; call and execute PortF_Init
		BL PortN_Init		; call and execute PortL_Init

; Variables
; - R1 & R2 are used in the different functions so I avoid using them in the main program
; - R0 is also used in the function calls but it will always hold the latest data from PORT M
; - R4	the number of expected inputs to come
; - R5	the remaining portion of the combination to be entered
; - R6	temporary variable to compare with the most recently entered bit

Locked_State
		; Outputs
		LDR R1, =GPIO_PORTN_DATA_R		
		LDR R0, [R1]					
		ORR R0, R0, #0x01				;Set bit 0 - PN0 controls D2, ON for Locked
		BIC R0, R0, #0x02				;Clear bit 1 - PN1 controls D1, OFF for Locked
		STR R0, [R1]					

		; Input
		BL WaitForClockLow
		BL WaitForClockHigh				;when we return from this call, R0 bit 0 is the input
		
		; State transition
		LDR R4, =COMBINATION_LENGTH
		LDR R5, =COMBINATION
		AND R6, R5, #1					;only want to look at next bit
		AND R0, R0, #1					;only want to look at input
		CMP R0, R6
		BNE Locked_State
		
		LSR  R5, R5, #1      ; or LSRS if you want flags updated
		SUBS R4, R4, #1
		
		BEQ Unlocked_State
		
Intermediate_State								; We get here if (1) last input was correct; and (2) there are still inputs expected
		; Outputs
		LDR R1, =GPIO_PORTN_DATA_R		
		LDR R0, [R1]					
		ORR R0, R0, #0x01				;Set bit 0 - PN0 controls D2, ON for Locked
		BIC R0, R0, #0x02				;Clear bit 1 - PN1 controls D1, OFF for Locked
		STR R0, [R1]					

		; Input
		BL WaitForClockLow
		BL WaitForClockHigh				;when we return from this call, R0 bit 0 is the input
		
		; State transition
		AND R6, R5, #1					;only want to look at next bit
		AND R0, R0, #1					;only want to look at input
		CMP R0, R6
		BNE Locked_State
		
		LSR  R5, R5, #1      ; or LSRS if you want flags updated
		SUBS R4, R4, #1
		BNE Intermediate_State

Unlocked_State
		; Outputs
		LDR R1, =GPIO_PORTN_DATA_R		
		LDR R0, [R1]					
		BIC R0, R0, #0x01				;Clear bit 0 - PN0 controls D2, OFF for unLocked
		ORR R0, R0, #0x02				;Set bit 1 - PN1 controls D1, ON for unLocked
		STR R0, [R1]					
		
		; Input
		BL WaitForClockLow
		BL WaitForClockHigh				;when we return from this call, R0 bit 0 is the input
		
		; State transition
		B Locked_State
		
		ALIGN               ; directive for assembly			
        END                 ; End of function 
