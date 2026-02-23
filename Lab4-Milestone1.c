// Uses Port E4 to control external LED brightning/dimming sequence

#include <stdint.h>
#include "tm4c1294ncpdt.h"
#include "PLL.h"
#include "SysTick.h"

#define PERIOD_TICKS 1200000 
// 120 M / 1200000 = 100 Hz

#define STEP 26


void PortE_Init(void){

	SYSCTL_RCGCGPIO_R |= 0b00010000;								// 1. activate clock for port E
	while ((SYSCTL_PRGPIO_R & 0b00010000) == 0) {}	//		wait for clock/port to be ready
	GPIO_PORTE_DIR_R |= 0x10;												// 2) make PE4 output   
	GPIO_PORTE_AMSEL_R &= ~0x10;     								// disable analog functionality on PE4	
	GPIO_PORTE_DEN_R |= 0x10;											// 4) enable digital I/O on PE4   
	//==============================================================================	
	
	return;
}



void DutyCycle_Percent(int percentage) {
	SysTick_Wait((uint32_t)PERIOD_TICKS * percentage / 255u);
}

void flash(int duty255) {
		GPIO_PORTE_DATA_R |= 0x10;							// toggle LED for visualization of process
		DutyCycle_Percent((uint32_t)duty255);					
		GPIO_PORTE_DATA_R &= ~0x10;							// toggle LED for visualization of process
		DutyCycle_Percent((uint32_t) (255 - duty255)); 
}

void IntensitySteps() {
		int duty255 = 0; 
		int i = 0; 
		
		// On-ramp
		while(duty255 <= 255){					
			for (i = 0; i < 10; i++) {
				flash(duty255);
			}
			duty255 += STEP;
			if (duty255 > 255) {
				duty255 = 255;
				break;
			}
		}
		
		duty255 -= STEP;
		
		// Off-ramp
		while(duty255 >= 0){					
			for (i = 0; i < 10; i++) {
				flash(duty255);
			}
			duty255 -= STEP;
			if (duty255 < 0) {
				duty255 = 0;
				break;
			}
		}
		
		for (i = 0; i < 10; i++) {
			flash(0);
		}
}


int main(void){	 
	PLL_Init();																			
	SysTick_Init();																	
	PortE_Init();				

	
	while (1) {
		IntensitySteps();
	}
	
}
