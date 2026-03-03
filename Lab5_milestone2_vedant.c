#include <stdint.h>
#include "tm4c1294ncpdt.h"

// --- GPIO init (cleaned) ---
void PortE_Init(void){
  SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R4;
  while((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R4) == 0) {}

  GPIO_PORTE_DIR_R |= 0x0F;     // PE3-PE0 outputs
  GPIO_PORTE_DEN_R |= 0x0F;     // digital enable
  GPIO_PORTE_DATA_R = 0x0F;     // idle rows high
}

void PortM_Init(void){
  SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R11;
  while((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R11) == 0) {}

  GPIO_PORTM_DIR_R &= ~0x0F;    // PM3-PM0 inputs
  GPIO_PORTM_DEN_R |= 0x0F;
  GPIO_PORTM_PUR_R |= 0x0F;    // pull-ups (so unpressed = 1)
}

static inline void settle_delay(void){
  for(volatile int i=0; i<80; i++) {}
}

// Returns scan code: [PM3..PM0][PE3..PE0]
// If nothing pressed: returns 0xFF
uint8_t Keypad_Get8bitCode(void){
  static const uint8_t row_patterns[4] = {
    0x0E, // 1110  (PE0 low)
    0x0D, // 1101  (PE1 low)
    0x0B, // 1011  (PE2 low)
    0x07  // 0111  (PE3 low)
  };

  for(int r=0; r<4; r++){
    GPIO_PORTE_DATA_R = row_patterns[r];
    settle_delay();

    uint8_t cols = GPIO_PORTM_DATA_R & 0x0F; // PM nibble
    if(cols != 0x0F){                        // any column went low => key pressed
      uint8_t rows = GPIO_PORTE_DATA_R & 0x0F;
      return (cols << 4) | rows;             // PM[3:0] PE[3:0]
    }
  }
  return 0xFF;
}
