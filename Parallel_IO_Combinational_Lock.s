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
PM3_MASK					  EQU	  0x08
LOCK_CODE					  EQU     0x07

; 	change to pressed 0x00 and released 0x08 if active lo
	
PRESSED						  EQU	  0x08 
RELEASED					  EQU	  0x00

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

Start
        BL 	PortM_Init
		BL 	PortN_Init
		LDR R3, =DELAY_CONST
		LDR R1, =0
		B Delay
		
		
WaitForButtonRelease
		LDR R4, =GPIO_PORTM_DATA_R
		LDR R5, [R4]
		AND R5, R5, PM3_MASK
		CMP R5, RELEASED
		BEQ CheckButtonPress
		BNE WaitForButtonRelease
		
Delay
		ADD R1, R1, #1	
		CMP R1, R3
		BEQ WaitForButtonRelease
		BNE Delay
		

CheckButtonPress
		LDR R2, =GPIO_PORTM_DATA_R
		LDR R0, [R2]
		AND R0, R0, PM3_MASK
		CMP R0, PRESSED
		BEQ EnterCode
		BNE CheckButtonPress
		
		
EnterCode
		LDR R1, =GPIO_PORTM_DATA_R
		LDR R0, [R1]
		AND R0, R0, #0x07
		CMP R0, #LOCK_CODE
		BEQ Success
		B Fail
		
		
Success
		LDR R2, =GPIO_PORTN_DATA_R
		LDR R3, [R2]
		ORR R3, R3, #0x01
		AND R3, R3, #0xFD
		STR R3, [R2]
		LDR R1, =0
		LDR R3, =DELAY_CONST
		B Delay
		
		
Fail
		LDR R2, =GPIO_PORTN_DATA_R
		LDR R3, [R2]
		ORR R3, R3, #0x02
		AND R3, R3, #0xFE
		STR R3, [R2]
		LDR R1, =0
		LDR R3, =DELAY_CONST
		B Delay
		
		
