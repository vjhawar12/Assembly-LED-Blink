// Uses Port E4 to control external LED brightning/dimming sequence

#include <stdint.h>
#include "tm4c1294ncpdt.h"
#include "PLL.h"
#include "SysTick.h"

#define PERIOD_TICKS 1200000 
// 120 M / 1200000 = 100 Hz

#define RED 0x01
#define BLUE 0x02
#define GREEN 0x04
#define NONE 0x0

#define STEP 52


void PortE_Init(void){

	SYSCTL_RCGCGPIO_R |= 0b00010000;								// 1. activate clock for port E
	while ((SYSCTL_PRGPIO_R & 0b00010000) == 0) {}	//		wait for clock/port to be ready
	GPIO_PORTE_DIR_R |= 0x07;												// 2) make PE[0-2] output   
	GPIO_PORTE_AMSEL_R &= ~0x07;     								// disable analog functionality on PE[0-2]	
	GPIO_PORTE_DEN_R |= 0x07;											// 4) enable digital I/O on PE[0-2]   
	GPIO_PORTE_AFSEL_R &= ~0x07;
    //==============================================================================	
	
	return;
}


// give inputs as fraction of 255
void RGB_LED(int r, int g, int b) {
    r = r * 255 / 100;
    g = g * 255 / 100;
    b = b * 255 / 100; 
    for (int i = 0; i < 256; i++) {
        uint32_t pins = 0;
        // need to convert r, g, b into some fraction of 256
        if (i < r) {
            pins |= RED;
        }
        if (i < g) {
            pins |= GREEN;
        }
        if (i < b) {
            pins |= BLUE; 
        } 

        GPIO_PORTE_DATA_R = (GPIO_PORTE_DATA_R &= ~0x07) | pins;							
        SysTick_Wait(PERIOD_TICKS / 256);
    } 
}


int main(void){	 
	PLL_Init();																			
	SysTick_Init();																	
	PortE_Init();				

	
	while (1) {
        RGB_LED(128, 77, 26); // 50% red, 30% green, 20% blue
	}
	
}
