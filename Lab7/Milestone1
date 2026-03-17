
#include <stdint.h>
#include "tm4c1294ncpdt.h"
#include "PLL.h"
#include "SysTick.h"

// -------------------------------------------------------
// Port N Init — PN0 = LED D2, PN1 = LED D1
// -------------------------------------------------------
void PortN_Init(void) {
    SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R12;
    while ((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R12) == 0) {};
    GPIO_PORTN_DIR_R   |=  0x03;
    GPIO_PORTN_AFSEL_R &= ~0x03;
    GPIO_PORTN_DEN_R   |=  0x03;
    GPIO_PORTN_AMSEL_R &= ~0x03;
    GPIO_PORTN_DATA_R   =  0x00;
}

// -------------------------------------------------------
// Port M Init — PM0 = scope output pin
// Change 0x01 to another bit mask if TA picks a different pin
// -------------------------------------------------------
void PortM_Init(void) {
    SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R11;
    while ((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R11) == 0) {};
    GPIO_PORTM_DIR_R   |=  0x01;
    GPIO_PORTM_AFSEL_R &= ~0x01;
    GPIO_PORTM_DEN_R   |=  0x01;
    GPIO_PORTM_AMSEL_R &= ~0x01;
    GPIO_PORTM_DATA_R   =  0x00;
}

void EnableInt(void)  { __asm("    cpsie   i\n"); }
void DisableInt(void) { __asm("    cpsid   i\n"); }
void WaitForInt(void) { __asm("    wfi\n");        }

void Timer0A_Interrupt_Init(void) {
    // Step 1: Enable clock to Timer0 module
    SYSCTL_RCGCTIMER_R |= SYSCTL_RCGCTIMER_R0;

    while((SYSCTL_RCGCTIMER_R &SYSCTL_RCGCTIMER_R0) ==0){};
    

    // Step 3: Disable Timer0A before configuring
    TIMER0_CTL_R &= ~TIMER_CTL_TAEN;

    // Step 4: Configure for 32-bit periodic mode
    TIMER0_CFG_R  =  0x00000000;           // 32-bit mode
    TIMER0_TAMR_R =  TIMER_TAMR_TAMR_PERIOD; // periodic mode

    // Step 5: Load PERIOD — 1s at 120MHz
    TIMER0_TAILR_R = 120000000 - 1;

    // Step 6: Load PRESCALE — none needed (PRESCALE = 0)
    TIMER0_TAPR_R = 0;

    // Step 7: Clear time-out flag
    TIMER0_ICR_R = TIMER_ICR_TATOCINT;

    // Step 8: Arm interrupt — enable time-out interrupt
    TIMER0_IMR_R |= TIMER_IMR_TATOIM;

    // Step 9: Set priority to 2
    // TIMER0A is IRQ 19, lives in NVIC_PRI4_R bits 31:29
    NVIC_PRI4_R = (NVIC_PRI4_R & 0x00FFFFFF) | 0x40000000;

    // Step 10: Enable interrupt — IRQ 19 is bit 19 of NVIC_EN0_R
    NVIC_EN0_R |= (1 << 19);

    // Step 11: Start timer
    TIMER0_CTL_R |= TIMER_CTL_TAEN;

    EnableInt();   // Enable global interrupts
}

// -------------------------------------------------------
// TIMER0A ISR — fires every 1s
// Name must match startup_msp432e401y_uvision.s exactly
// -------------------------------------------------------
void TIMER0A_IRQHandler(void) {
    // Acknowledge interrupt first (Step 7 equivalent at runtime)
    TIMER0_ICR_R = TIMER_ICR_TATOCINT;

    // Assert HIGH — start of 250ms pulse
    GPIO_PORTN_DATA_R |=  0x01;    // LED D2 ON
    GPIO_PORTM_DATA_R |=  0x01;    // PM0 HIGH (scope probe)

    SysTick_Wait10ms(25);      

    // Assert LOW — pulse ends, stays LOW for remaining 750ms
    GPIO_PORTN_DATA_R &= ~0x01;    // LED D2 OFF
    GPIO_PORTM_DATA_R &= ~0x01;    // PM0 LOW
}

// -------------------------------------------------------
// Main
// -------------------------------------------------------
int main(void) {
    PLL_Init();
    SysTick_Init();
    PortN_Init();
    PortM_Init();
    Timer0A_Interrupt_Init();

    while (1) {
        WaitForInt();
    }
}
