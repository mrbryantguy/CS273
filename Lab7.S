  .equ ADCL, 0x0078
  .equ ADCH, 0x0079
  .equ ADCSRA, 0x007A
  .equ ADCSRB, 0x007B
  .equ ADMUX, 0x007C
  .equ DDIR0, 0x007E
  .equ ADSC, 6 // bit 6 on the ADCSRA     
  .text
  .global initAD
  .global readAD

 initAD:  
      // routine which initializes the A/D lines     
      // in DIDR0, set ADC[0-5]DS all to 1 to turn off digital input buffers
      LDI  R18, 0b00111111 // pins 6 and 7 do not have digital input buffers we should set these to 1 to turn the buffers off
      STS   DDIR0, R18 // DIDR0
      LDI  R18, 0b10000111 // initialize ADEN to 1, ADPS2-0 to 111 and the rest of bits to 0
      STS   ADCSRA, R18 // ADCSRA this contains most of the configuration bits
      
      ret // of initAD

readAD:  
    // routine which has one parameter in r24
    // and then reads the A/D signal and places the result
    // into r24, clearing r25
    // we need to set up the ADMUX and ADSCSRA and then wait on ADSC
    
    // in ADMUX, set REFS1-REFS0 to 01, ADLAR to 1, and MUX3-0 to 4 bits that denote the desired input pin
    LDI  R18, 0b01110000
    ADD  R18, R24 // add the bits from C program
    STS   ADMUX, R18
    // in ADCSRA, set ADSC to 1 to start a conversation
    LDI  R18, 0b11000111
    STS   ADCSRA, R18

    // in a loop, read ADSC until it reads 0
L1:
    LDS  R18, ADCSRA
    ANDI  R18, 0b01000000
    BRNE  L1

    // fetch result byte from ADCH; ignore ADCL which includes the 2 least
    // significant bits for the 10 bit digital value
    CLR  R25
    LDS  R24, ADCH
    ret // of readAD
 
