#include <stdint.h>
#include "tm4c1294ncpdt.h"

void PortE_Init(void){
  SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R4;                 // Port E clock
  while((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R4) == 0) {}
  GPIO_PORTE_DIR_R |= 0x0F;                                // PE3-0 outputs
  GPIO_PORTE_DEN_R |= 0x0F;                                // digital enable
  GPIO_PORTE_DATA_R |= 0x0F;                               // idle = all high
}

void PortM_Init(void){
  SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R11;                // Port M clock
  while((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R11) == 0) {}
  GPIO_PORTM_DIR_R &= ~0x0F;                               // PM3-0 inputs
  GPIO_PORTM_DEN_R |= 0x0F;
  GPIO_PORTM_PUR_R |= 0x0F;                               // pull-ups
}

static inline void small_delay(void){
  // tiny settle time after changing rows
  for(volatile int i=0;i<100;i++){}
}

// Returns 8-bit code: [PM3..PM0][PE3..PE0]
// If no key pressed, returns 0xFF (PM=1111, PE=1111)
uint8_t Keypad_ScanCode(void){
  static const uint8_t row_drive[4] = {
    0x0E,  // PE0 low (1110)
    0x0D,  // PE1 low (1101)
    0x0B,  // PE2 low (1011)
    0x07   // PE3 low (0111)
  };

  for(int r=0; r<4; r++){
    GPIO_PORTE_DATA_R = row_drive[r];
    small_delay();

    uint8_t cols = GPIO_PORTM_DATA_R & 0x0F;   // PM3..0
    if(cols != 0x0F){                          // something pulled low
      uint8_t rows = GPIO_PORTE_DATA_R & 0x0F; // PE3..0 current pattern
      return (cols << 4) | rows;               // PM nibble then PE nibble
    }
  }

  return 0xFF; // no press detected
}

volatile uint8_t watch8bit;

int main(void){
  PortE_Init();
  PortM_Init();

  while(1){
    uint8_t code = Keypad_ScanCode();
    if(code != 0xFF){
      watch8bit = code;       

      while((GPIO_PORTM_DATA_R & 0x0F) != 0x0F){}
    }
  }
}
