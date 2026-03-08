// COMPENG 2DX3 
// Lab 5 Milestone 1

#include <stdint.h>
#include "tm4c1294ncpdt.h"
#include "SysTick.h"
#include "PLL.h"

void PortE_Init(void){	
	SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R4;		              // Activate the clock for Port E
	while((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R4) == 0){};	      // Allow time for clock to stabilize
  
	GPIO_PORTE_DIR_R = 0b00001111;														// Enable PE0-PE3 as outputs  (1-4 on keyboard)
	GPIO_PORTE_DEN_R = 0b00001111;                        		// Enable PE0-PE3 as digital pins
	return;
	}

void PortM_Init(void){
	SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R11;                 // Activate the clock for Port M
	while((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R11) == 0){};      // Allow time for clock to stabilize
		
	GPIO_PORTM_DIR_R = 0b00000000;       								      // Enable PM0-PM3 as inputs   (5-8 on keyboard)
  GPIO_PORTM_DEN_R = 0b00001111;														// Enable PM0-PM3 as digital pins
	GPIO_PORTM_PUR_R = 0b00001111;														// Enable Internal Pull Up Resistors for PM0-PM3
	return;
}

int watch8bit[200];

int main(void){
	PortE_Init();
	PortM_Init();
	
	while(1){// Keep checking if a button is pressed 
		
		// Drive Low PE0 (Row 0) for scanning
		GPIO_PORTE_DATA_R =  0b11111110;
		
		// Check if Button #1-3 or A is pressed 
		
		// #1: Unique code is: 11101110 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000001)==0 && (GPIO_PORTE_DATA_R & 0b00000001)==0){
		watch8bit[0] = 0b11101110;
		}
		
		// #2: Unique code is: 11011110 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000010)==0 && (GPIO_PORTE_DATA_R & 0b00000001)==0){
		watch8bit[0] = 0b11011110;
		}
		
		// #3: Unique code is: 10111110 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000100)==0 && (GPIO_PORTE_DATA_R & 0b00000001)==0){
		watch8bit[0] = 0b10111110;
		}
		
		// A: Unique code is: 01111110 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00001000)==0 && (GPIO_PORTE_DATA_R & 0b00000001)==0){
		watch8bit[0] = 0b01111110;
		}
		
		// Drive Low PE1 (Row 1) for scanning
		GPIO_PORTE_DATA_R =  0b11111101;
		
		// Check if Button #4-6 or B is pressed 
		
		// #4: Unique code is: 11101101 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000001)==0 && (GPIO_PORTE_DATA_R & 0b00000010)==0){
		watch8bit[0] = 0b11101101;
		}
		
		// #5: Unique code is: 11011101 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000010)==0 && (GPIO_PORTE_DATA_R & 0b00000010)==0){
		watch8bit[0] = 0b11011101;
		}
		
		// #6: Unique code is: 10111101 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000100)==0 && (GPIO_PORTE_DATA_R & 0b00000010)==0){
		watch8bit[0] = 0b10111101;
		}
		
		// B: Unique code is: 01111101 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00001000)==0 && (GPIO_PORTE_DATA_R & 0b00000010)==0){
		watch8bit[0] = 0b01111101;
		}
		
		// Drive Low PE2 (Row 2) for scanning
		GPIO_PORTE_DATA_R =  0b11111011;
		
		// Check if Button #7-9 or C is pressed 
		
		// #7: Unique code is: 11101011 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000001)==0 && (GPIO_PORTE_DATA_R & 0b00000100)==0){
		watch8bit[0] = 0b11101011;
		}
		
		// #8: Unique code is: 11011011 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000010)==0 && (GPIO_PORTE_DATA_R & 0b00000100)==0){
		watch8bit[0] = 0b11011011;
		}
		
		// #9: Unique code is: 10111011 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000100)==0 && (GPIO_PORTE_DATA_R & 0b00000100)==0){
		watch8bit[0] = 0b10111011;
		}
		
		// C: Unique code is: 01111011 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00001000)==0 && (GPIO_PORTE_DATA_R & 0b00000100)==0){
		watch8bit[0] = 0b01111011;
		}
		
		// Drive Low PE3 (Row 3) for scanning
		GPIO_PORTE_DATA_R =  0b11110111;
		
		// Check if Button *, #0, #, or D is pressed 
		
		// *: Unique code is: 11100111 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000001)==0 && (GPIO_PORTE_DATA_R & 0b00001000)==0){
		watch8bit[0] = 0b11100111;
		}
		
		// #0: Unique code is: 11010111 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000010)==0 && (GPIO_PORTE_DATA_R & 0b00001000)==0){
		watch8bit[0] = 0b11010111;
		}
		
		// #: Unique code is: 10110111 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00000100)==0 && (GPIO_PORTE_DATA_R & 0b00001000)==0){
		watch8bit[0] = 0b10110111;
		}
		
		// D: Unique code is: 01110111 - In order of PM3 PM2 PM1 PM0 PE3 PE2 PE1 PE0
		while((GPIO_PORTM_DATA_R & 0b00001000)==0 && (GPIO_PORTE_DATA_R & 0b00001000)==0){
		watch8bit[0] = 0b01110111;
		}
		
	}
}
