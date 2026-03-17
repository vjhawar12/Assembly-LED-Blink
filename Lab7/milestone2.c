#include <stdint.h>
#include "tm4c1294ncpdt.h"
#include "PLL.h"
#include "SysTick.h"

// ---------------- I2C bit definitions ----------------
#define I2C_MCS_ACK      0x00000008
#define I2C_MCS_STOP     0x00000004
#define I2C_MCS_START    0x00000002
#define I2C_MCS_ERROR    0x00000002
#define I2C_MCS_RUN      0x00000001
#define I2C_MCS_BUSY     0x00000001
#define I2C_MCR_MFE      0x00000010

// ---------------- globals ----------------
volatile uint8_t g_sendByte = 0x5C;   // TA can ask you to change this
volatile uint8_t g_buttonEvent = 0;   // debug flag if needed

// -------------------------------------------------------
// basic interrupt helpers
// -------------------------------------------------------
void EnableInt(void)  { __asm("    cpsie   i\n"); }
void DisableInt(void) { __asm("    cpsid   i\n"); }
void WaitForInt(void) { __asm("    wfi\n");        }

// -------------------------------------------------------
// Port N Init — use LED for debug/visual confirmation
// PN0 = D2, PN1 = D1
// -------------------------------------------------------
void PortN_Init(void) {
    SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R12;
    while ((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R12) == 0) {}

    GPIO_PORTN_DIR_R   |=  0x03;
    GPIO_PORTN_AFSEL_R &= ~0x03;
    GPIO_PORTN_DEN_R   |=  0x03;
    GPIO_PORTN_AMSEL_R &= ~0x03;
    GPIO_PORTN_DATA_R  &= ~0x03;
}

// -------------------------------------------------------
// Port J Init + interrupt setup for USR SW1 on PJ0
// Button on LaunchPad is active low, so use falling edge
// -------------------------------------------------------
void PortJ_Interrupt_Init(void) {
    SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R8;
    while ((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R8) == 0) {}

    // PJ0 input
    GPIO_PORTJ_DIR_R   &= ~0x01;
    GPIO_PORTJ_AFSEL_R &= ~0x01;
    GPIO_PORTJ_DEN_R   |=  0x01;
    GPIO_PORTJ_AMSEL_R &= ~0x01;

    // If pull-up is needed, enable it
    GPIO_PORTJ_PUR_R   |=  0x01;

    // Interrupt config: edge-sensitive, single edge, falling edge
    GPIO_PORTJ_IS_R   &= ~0x01;   // edge sensitive
    GPIO_PORTJ_IBE_R  &= ~0x01;   // not both edges
    GPIO_PORTJ_IEV_R  &= ~0x01;   // falling edge

    GPIO_PORTJ_ICR_R   =  0x01;   // clear any prior flag
    GPIO_PORTJ_IM_R   |=  0x01;   // arm interrupt

    // Port J interrupt number is 51 -> EN1 bit 19
    NVIC_PRI12_R = (NVIC_PRI12_R & 0xFF00FFFF) | 0x00400000; // priority 2
    NVIC_EN1_R   = (1 << (51 - 32)); // bit 19
}

// -------------------------------------------------------
// I2C0 init on PB2/PB3
// PB2 = I2C0SCL, PB3 = I2C0SDA
// -------------------------------------------------------
void I2C_Init(void) {
    SYSCTL_RCGCI2C_R  |= SYSCTL_RCGCI2C_R0;
    SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R1;

    while ((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R1) == 0) {}

    // PB2, PB3 alt function
    GPIO_PORTB_AFSEL_R |= 0x0C;

    // SDA open drain on PB3
    GPIO_PORTB_ODR_R   |= 0x08;

    // Digital enable
    GPIO_PORTB_DEN_R   |= 0x0C;
    GPIO_PORTB_AMSEL_R &= ~0x0C;

    // PCTL for I2C on PB2/PB3
    GPIO_PORTB_PCTL_R = (GPIO_PORTB_PCTL_R & 0xFFFF00FF) | 0x00002200;

    // Master mode enable
    I2C0_MCR_R = I2C_MCR_MFE;

    // 100 kbps
    // This is the same style you were already using
    I2C0_MTPR_R = 0x3B;
}

// -------------------------------------------------------
// wait until I2C master is not busy
// -------------------------------------------------------
void I2C0_WaitIdle(void) {
    while (I2C0_MCS_R & I2C_MCS_BUSY) {}
}

// -------------------------------------------------------
// send one byte to a 7-bit slave address
// This is exactly what milestone 2 needs:
// address 0x29 + one data byte 0x5C
// -------------------------------------------------------
int I2C0_SendByte(uint8_t slaveAddr, uint8_t data) {
    I2C0_WaitIdle();

    I2C0_MSA_R = (slaveAddr << 1) & 0xFE;   // write mode
    I2C0_MDR_R = data;

    // single-byte burst: START + RUN + STOP
    I2C0_MCS_R = I2C_MCS_START | I2C_MCS_RUN | I2C_MCS_STOP;

    I2C0_WaitIdle();

    if (I2C0_MCS_R & I2C_MCS_ERROR) {
        return 1;   // error happened
    }
    return 0;       // success
}

// -------------------------------------------------------
// GPIO Port J ISR
// Must match startup file vector name
// On many TM4C/MSP432E setups this is GPIOJ_IRQHandler
// -------------------------------------------------------
void GPIOJ_IRQHandler(void) {
    // acknowledge PJ0 interrupt first
    GPIO_PORTJ_ICR_R = 0x01;

    g_buttonEvent = 1;

    // quick visual cue
    GPIO_PORTN_DATA_R |= 0x02;   // D1 ON

    // simple debounce
    SysTick_Wait10ms(2);

    // if still pressed, send the byte
    if ((GPIO_PORTJ_DATA_R & 0x01) == 0) {
        I2C0_SendByte(0x29, g_sendByte);
    }

    // wait for release to reduce repeated triggers
    while ((GPIO_PORTJ_DATA_R & 0x01) == 0) {}

    SysTick_Wait10ms(2);         // debounce on release

    GPIO_PORTN_DATA_R &= ~0x02;  // D1 OFF
}

// -------------------------------------------------------
// main
// -------------------------------------------------------
int main(void) {
    PLL_Init();
    SysTick_Init();
    PortN_Init();
    I2C_Init();
    PortJ_Interrupt_Init();

    EnableInt();

    while (1) {
        WaitForInt();
    }
}
