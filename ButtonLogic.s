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
GPIO_PORTF_DIR_R              EQU     0x4005D400         ;Step 3: GPIO Port F DIR Register Address
GPIO_PORTF_DEN_R              EQU     0x4005D51C         ;Step 4: GPIO Port F DEN Register Address
GPIO_PORTF_DATA_R             EQU     0x4005D3FC         ;Step 5: GPIO Port F DATA Register Address

GPIO_PORTL_DIR_R              EQU     0x40062400         ;Step 3: GPIO Port L DIR Register Address
GPIO_PORTL_DEN_R              EQU     0x4006251C         ;Step 4: GPIO Port L DEN Register Address
GPIO_PORTL_DATA_R             EQU     0x400623FC         ;Step 5: GPIO Port L DATA Register Address
	
GPIO_PORTN_DIR_R              EQU     0x40064400         ;Step 3: GPIO Port L DIR Register Address
GPIO_PORTN_DEN_R              EQU     0x4006451C         ;Step 4: GPIO Port L DEN Register Address
GPIO_PORTN_DATA_R             EQU     0x400643FC         ;Step 5: GPIO Port L DATA Register Address
                              



        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT Start

PortF_Init 
		;STEP 1 Activate clock
		;This means, set bit 5 in RCGCGPIO without changing any other bits
		;In C pseudcode: SYSCTL_RCGCGPIO_R |= #0x20
		LDR R1, =SYSCTL_RCGCGPIO_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		ORR R0,R0, #0x20				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
		
		;STEP 2: Wait for Peripheral Ready
		NOP
		NOP
		 
		
		;STEP 3: Make PF4 an output pin
		;This means set bit 4 in PortF Direction Register
		;In C pseudocode: GPIO_PORTF_DIR_R |= #0x10
		LDR R1, =GPIO_PORTF_DIR_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		ORR R0,R0, #0x10				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
		 
		;STEP 4: Enable PF4 for digital I/O
		;This means set bit 4 in PortF Digital Enable Register
		;In C pseudocode: GPIO_PORTF_DEN_R |= #0x10
		LDR R1, =GPIO_PORTF_DEN_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		ORR R0,R0, #0x10				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
 

        BX LR               ; return from function 


;Function PortL_Init
;Enable PortL and set bit PL0 for digital input
PortL_Init 
		;STEP 1 Activate clock
		;This means, set bit A in RCGCGPIO without changing any other bits
		;In C pseudcode: SYSCTL_RCGCGPIO_R |= #0x400
		LDR R1, =SYSCTL_RCGCGPIO_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		ORR R0,R0, #0x400				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
		
		;STEP 2: Wait for Peripheral Ready
		NOP
		NOP
		 
		
		;STEP 3: Make PL0 an input pin
		;This means clear bit 0 in PortL Direction Register
		;In C pseudocode: GPIO_PORTL_DIR_R &= !(#0x10)
		LDR R1, =GPIO_PORTL_DIR_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		AND R0,R0, #0xFE				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
		 
		;STEP 4: Enable PL0 for digital I/O
		;This means set bit 0 in PortL Digital Enable Register
		;In C pseudocode: GPIO_PORTL_DEN_R |= #0x1
		LDR R1, =GPIO_PORTL_DEN_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		ORR R0,R0, #0x1					;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
 

        BX LR               ; return from function 


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
		ORR R0,R0, #0x02				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
		 
		;STEP 4: Enable PL0 for digital I/O
		;This means set bit 0 in PortL Digital Enable Register
		;In C pseudocode: GPIO_PORTL_DEN_R |= #0x1
		LDR R1, =GPIO_PORTN_DEN_R		;Stores the address of the target register in R1
		LDR R0, [R1]					;Dereferences R1 to put the contents of the target register in R0
		ORR R0,R0, #0x02				;Modifies the contents of R0 as needed
		STR R0, [R1]					;Stores the new value back into the target register
 

        BX LR               ; return from function 


Start
        BL  PortF_Init
        BL  PortL_Init
        BL 	PortN_Init
		
		B keep_on
		
		
detect_off
		LDR R2, =GPIO_PORTL_DATA_R
		LDR R3, [R2]
		AND R3, R3, #0x1
		CMP R3, 0
		BX LR
		

keep_on 
		LDR R1, =GPIO_PORTN_DATA_R ;Stores the address of the target register in R1 
		LDR R0, [R1] ;Dereferences R1 to put the contents of the target register in R0 
		ORR R0,R0, #0x2 ;Modifies the contents of R0 as needed 
		STR R0, [R1] ;Stores the new value back into the target register 
		
		BL detect_off
		BEQ turn_off
		B keep_on

		

turn_off
		LDR R1, =GPIO_PORTN_DATA_R ;Stores the address of the target register in R1 
		LDR R0, [R1] ;Dereferences R1 to put the contents of the target register in R0 
		AND R0,R0, #0xFD ;Modifies the contents of R0 as needed 
		STR R0, [R1] ;Stores the new value back into the target register
	
		BL detect_off
		BEQ turn_off
		B keep_on
	
		ALIGN
		END
