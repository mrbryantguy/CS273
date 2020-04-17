
  .equ ADCL, 0x0078
  .equ ADCH, 0x0079
  .equ ADCSRA, 0x007A
  .equ ADCSRB, 0x007B
  .equ ADMUX, 0x007C
  .equ DDIR0, 0x007E
  .equ ADSC, 6 // bit 6 on the ADCSRA

#
# Global data
#
#   
    .data
    .macro pushall
     push r16
     push r17
     push r18
     push r19
     push r20
     push r21
     push r22
     push r23
     push r24
     push r25
     push r26
     push r27
     push r28
     push r29
     push r30
     push r31
     .endm ; of pushall

     .macro popall
     pop r31
     pop r30
     pop r29
     pop r28
     pop r27
     pop r26
     pop r25
     pop r24
     pop r23
     pop r22
     pop r21
     pop r20
     pop r19
     pop r18
     pop r17
     pop r16
     .endm ; of popall
     
  .text
  .global initAD
  .global readAD

 initAD:  // routine which initializes the A/D lines     
      // in DIDR0, set ADC[0-5]DS all to 1 to turn off digital input buffers
      pushall
      LDI  R16, 0b11111111 // pins 6 and 7 do not have digital input buffers
                           // we should set these to 1 to turn the buffers off
      STS   DDIR0, R16 // DIDR0
      LDI  R16, 0b10000111 // initialize ADEN to 1, ADPS2-0 to 111 and the rest of bits to 0
      STS   ADCSRA, R16 // ADCSRA this contains most of the configuration bits
      
      popall
      ret // of initAD

readAD:  // routine which has one parameter in r24
    // and then reads the A/D signal and places the result
    // into r24, clearing r25
    // we need to set up the ADMUX and ADSCSRA and then wait on ADSC
    pushall
    
    // in ADMUX, set REFS1-REFS0 to 01, ADLAR to 1, and MUX3-0 to 4 bits that denote the desired input pin
    LDI  R16, 0b01110000
    ADD  R16, R24
    STS   ADMUX, R16
    // in ADCSRA, set ADSC to 1 to start a conversation
    LDI  R16, 0b11000111
    STS   ADCSRA, R16

    // in a loop, read ADSC until it reads 0
L1:
    LDS  R16, ADCSRA
    ANDI  R16, 0b01000000
    CPI   R16, 0b0
    BRNE  L1

    // fetch result byte from ADCH; ignore ADCL which includes the 2 least
    // significant bits for the 10 bit digital value
    CLR  R25
    LDS  R25, ADCH
    STS  24, R25

    popall
    ret // of readAD
 
