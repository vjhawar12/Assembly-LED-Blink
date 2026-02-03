;Template - Defining an Assembly File 
;
; Original: Copyright 2014 by Jonathan W. Valvano, valvano@mail.utexas.edu
;
; Last modified by: Vedant Jhawar
; January 27, 2026
;
; Initial template for studio 1A and 1B
; This template has the structure for the basic steps required
; to configure and use PF4 for digital I/O
; 
; Studio 1A: objective is to switch on D3
; Students need to modify code for Steps 3, 4, and 5
;
; Studio 1B: objective is to use a pushbutton to control D3
; Students need to add code to configure Port L
; then add code to read Port L and control D3 
;
; McMaster University, Comp Eng 2DX3
; Further resources: Valvano textbook, Chs. 3 & 4

;ADDRESS SETUP
;Define your I/O Port Addresses Here

SYSCTL_RCGCGPIO_R             EQU     0x400FE608         ;Step 1: GPIO Run Mode Clock Gating Control Register Address
	
GPIO_PORTN_DIR_R              EQU     0x40064400         ;Step 3: GPIO Port L DIR Register Address
GPIO_PORTN_DEN_R              EQU     0x4006451C         ;Step 4: GPIO Port L DEN Register Address
GPIO_PORTN_DATA_R             EQU     0x400643FC         ;Step 5: GPIO Port L DATA Register Address
                              
GPIO_PORTM_DIR_R              EQU     0x40063400         ;Step 3: GPIO Port L DIR Register Address
GPIO_PORTM_DEN_R              EQU     0x4006351C         ;Step 4: GPIO Port L DEN Register Address
GPIO_PORTM_DATA_R             EQU     0x400633FC         ;Step 5: GPIO Port L DATA Register Address

DELAY_CONST					  EQU	  200
PM2_MASK					  EQU	  0x04
PM0_MASK					  EQU	  0x01
PN1_MASK					  EQU     0x02
PN0_MASK					  EQU     0x01
PN0_PN1_MASK				  EQU	  0x03
PF4_MASK					  EQU     0x10
PF0_MASK					  EQU     0x01
PF0_PF4_MASK				  EQU     0x11
LOCK_CODE			          EQU     0b1011
PRESSED_LEVEL				  EQU     PM2_MASK ; for active hi, swap to 0x00 for active lo
RELEASED_LEVEL				  EQU     0x00

; This assumes its active hi, swap PRESSED and RELEASED here if its active lo

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT Start


PortN_Init 
		;STEP 1 Activate clock
		;This means, set bit A in RCGCGPIO without changing any other bits
		;In C pseudcode: SYSCTL_RCGCGPIO_R |= #0x400
		LDR R1, =SYSCTL_RCGCGPIO_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		ORR R0,R0, #0x1000				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
		
		;STEP 2: Wait for Peripheral Ready
		NOP
		NOP
		 
		
		;STEP 3: Make PL0 an input pin
		;This means clear bit 0 in PortL Direction Register
		;In C pseudocode: GPIO_PORTL_DIR_R &= !(#0x10)
		LDR R1, =GPIO_PORTN_DIR_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		ORR R0,R0, #0x03				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
		 
		;STEP 4: Enable PL0 for digital I/O
		;This means set bit 0 in PortL Digital Enable Register
		;In C pseudocode: GPIO_PORTL_DEN_R |= #0x1
		LDR R1, =GPIO_PORTN_DEN_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		ORR R0,R0, #0x03				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
 

        BX LR               ; return from function 


PortM_Init 
		;STEP 1 Activate clock
		;This means, set bit A in RCGCGPIO without changing any other bits
		;In C pseudcode: SYSCTL_RCGCGPIO_R |= #0x400
		LDR R1, =SYSCTL_RCGCGPIO_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		ORR R0,R0, #0x800				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
		
		;STEP 2: Wait for Peripheral Ready
		NOP
		NOP
		 
		
		;STEP 3: Make PM[0-3] input pins
		;This means clear bits 0-3 in PortM Direction Register
		;In C pseudocode: GPIO_PORTL_DIR_R &= !(#0x10)
		LDR R1, =GPIO_PORTM_DIR_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		AND R0,R0, #0xF0				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
		 
		;STEP 4: Enable PL0 for digital I/O
		;This means set bit 0 in PortL Digital Enable Register
		;In C pseudocode: GPIO_PORTL_DEN_R |= #0x1
		LDR R1, =GPIO_PORTM_DEN_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		ORR R0,R0, #0x0F				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
 

        BX LR               ; return from function 

; Assuming active high button

Reset
		LDR R5, =0
		LDR R4, =0
		B WaitForReleased

Start
        BL 	PortM_Init
		BL 	PortN_Init
		LDR R6, =DELAY_CONST
		LDR R7, =LOCK_CODE
		B Reset

		
Delay
		ADD R5, #1
		CMP R5, R6
		BNE Delay
		LDR R5, =0
		BX LR

		
		


WaitForReleased
		LDR R0, =GPIO_PORTM_DATA_R
		LDR R1, [R0]
		AND R1, R1, #PM2_MASK
		CMP R1, #RELEASED_LEVEL ; checking if clock is on LO edge
		BEQ WaitForPressed ; if so check for HI
		BL Delay
		B WaitForReleased ; if not keep waiting

WaitForPressed
		LDR R0, =GPIO_PORTM_DATA_R
		LDR R1, [R0]
		AND R1, R1, #PM2_MASK
		CMP R1, #PRESSED_LEVEL ; checking if clock is on HI edge
		BEQ AcceptInput ; if so then we're in between LO and HI 
		BL Delay
		B WaitForPressed



GetValue
		RSBS R9, R4, #0x03 ; R9 = 3 - R4
		LSR R8, R7, R9 ; R9: 3 - R4 (index from increment), R7: lock code, R8: destination
		AND R8, R8, #0x01
		BX LR
		

AcceptInput
		LDR R2, =GPIO_PORTM_DATA_R
		LDR R3, [R2]
		AND R3, R3, #PM0_MASK ; change to EOR if active lo else keep AND
		BL GetValue
		CMP R3, R8 ; if equal then first digit entered is right
		BEQ Increment
		BNE Fail
		
Increment ; if increment reaches 4 then 4 correct digits were entered
		ADD R4, #1
		CMP R4, #4
		BEQ Win
		BNE WaitForReleased
		
Win ; light up D2 and turn off D1
		LDR R2, =GPIO_PORTN_DATA_R
		LDR R1, [R2]
		AND R1, R1, #0xFD ; turning off D1
		STR R1, [R2]
		ORR R1, R1, #0x02 ; turning on D2
		STR R1, [R2]
		B Win
		
Fail ; light up D1 and turn off D2
		LDR R2, =GPIO_PORTN_DATA_R
		LDR R1, [R2]
		AND R1, R1, #0xFE ; turning off D2
		STR R1, [R2]
		ORR R1, R1, #0x01 ; turning on D1
		STR R1, [R2]
		B Reset
