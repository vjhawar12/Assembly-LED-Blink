// COMPENG 2DX3
// This program illustrates the interfacing of the Stepper Motor with the microcontroller

//  Written by Ama Simons
//  January 18, 2020
// 	Last Update by Dr. Shahrukh Athar on February 2, 2025

#include <stdint.h>
#include "tm4c1294ncpdt.h"
#include "PLL.h"
#include "SysTick.h"


void PortL_Init(void){
	//Use PortM pins (PM0-PM3) for output
	SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R10;		// activate clock for PORT L
	while((SYSCTL_PRGPIO_R&SYSCTL_PRGPIO_R10) == 0){};	// allow time for clock to stabilize
	GPIO_PORTL_DIR_R |= 0x0F;        			// configure PORT L pins (PL0-PL3) as output
	GPIO_PORTL_AFSEL_R &= ~0x0F;     				// disable alt funct on PORT L pins (PL0-PL3)
	GPIO_PORTL_DEN_R |= 0x0F;        				// enable digital I/O on PORT L pins (PL0-PL3)
													// configure PORT L as GPIO
	GPIO_PORTL_AMSEL_R &= ~0x0F;     				// disable analog functionality on PORT L pins (PL0-PL3)
	return;
}


void spin_forward_full_step(uint32_t delay, uint32_t steps){							// Complete function spin to implement the Full-step Stepping Method
	for(int i=0; i< steps; i++){				// What should the upper-bound of i be for one complete rotation of the motor shaft?
		GPIO_PORTL_DATA_R = 0b00000011;
		SysTick_Wait10ms(delay);			// What if we want to reduce the delay between steps to be less than 10 ms?
		GPIO_PORTL_DATA_R = 0b00000110;			// Complete the missing code.
		SysTick_Wait10ms(delay);
		GPIO_PORTL_DATA_R = 0b00001100;			// Complete the missing code.
		SysTick_Wait10ms(delay);
		GPIO_PORTL_DATA_R = 0b00001001;			// Complete the missing code.
		SysTick_Wait10ms(delay);
	}
}

void spin_reverse_full_step(uint32_t delay, uint32_t steps) {
	for(int i=0; i< steps; i++){				// What should the upper-bound of i be for one complete rotation of the motor shaft?
		GPIO_PORTL_DATA_R = 0b00001001;			// Complete the missing code.
		SysTick_Wait10ms(delay);
		GPIO_PORTL_DATA_R = 0b00001100;			// Complete the missing code.
		SysTick_Wait10ms(delay);
		GPIO_PORTL_DATA_R = 0b00000110;			// Complete the missing code.
		SysTick_Wait10ms(delay);
		GPIO_PORTL_DATA_R = 0b00000011;
		SysTick_Wait10ms(delay);			// What if we want to reduce the delay between steps to be less than 10 ms?
	}
}


void spin_forward_wave_drive(uint32_t delay, uint32_t steps){							// Complete function spin to implement the Full-step Stepping Method
	for(int i=0; i< steps; i++){				// What should the upper-bound of i be for one complete rotation of the motor shaft?
		GPIO_PORTL_DATA_R = 0b00000001;
		SysTick_Wait10ms(delay);			// What if we want to reduce the delay between steps to be less than 10 ms?
		GPIO_PORTL_DATA_R = 0b00000010;			// Complete the missing code.
		SysTick_Wait10ms(delay);
		GPIO_PORTL_DATA_R = 0b00000100;			// Complete the missing code.
		SysTick_Wait10ms(delay);
		GPIO_PORTL_DATA_R = 0b00001000;			// Complete the missing code.
		SysTick_Wait10ms(delay);
	}
}

void spin_reverse_wave_drive(uint32_t delay, uint32_t steps) {
	for(int i=0; i< steps; i++){				// What should the upper-bound of i be for one complete rotation of the motor shaft?
		GPIO_PORTL_DATA_R = 0b00001000;			// Complete the missing code.
		SysTick_Wait10ms(delay);
		GPIO_PORTL_DATA_R = 0b00000100;			// Complete the missing code.
		SysTick_Wait10ms(delay);
		GPIO_PORTL_DATA_R = 0b00000010;			// Complete the missing code.
		SysTick_Wait10ms(delay);
		GPIO_PORTL_DATA_R = 0b00000001;
		SysTick_Wait10ms(delay);			// What if we want to reduce the delay between steps to be less than 10 ms?
	}
}


int main(void){
	PLL_Init();						// Default Set System Clock to 120MHz
	SysTick_Init();					// Initialize SysTick configuration
	PortL_Init();					// Initialize PORT L
	spin_forward_full_step(1, 512);							
	SysTick_Wait10ms(100); // wait 2000 ms
	spin_forward_full_step(1, 512);							
	SysTick_Wait10ms(100); // wait 2000 ms
	spin_reverse_full_step(1, 512);	
	SysTick_Wait10ms(100); // wait 2000 ms
	
	return 0;
}
