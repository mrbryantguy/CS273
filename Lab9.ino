// header comments

#include <avr/interrupt.h>
long start_time;
long totduration;
extern byte pinbstate;

extern "C" {
  void ultrasensor();
  void readPINBState();
}

void setup()
{
  Serial.begin(9600);
  
  /*
   * Set the bits of the appropriate PCMSKx register high
   * to enable pin change detection on PB1 (port b pin 1). 
   * PCINT1 in our case.
   */
  PCMSK0 = (1<<PCINT1);

  // Enable the corresponding vector, PCIE0 in our case.
  PCICR = (1<<PCIE0);

  // Enable the interrupt flag
  sei();
  
}

void loop()
{
  ultrasensor();
  delay(1000); // delay a second
}

/*
 * The interrupt service routine that would activate on 
 * a value change of PB1
 */
ISR(PCINT0_vect)
{
  /* The echo pin is changed twib
   * 1. First echo pin is set, this is when the echo is sent,
   * record start time in microseconds
   * 2. Then echo pin is cleared, this is when the echo came
   * back, record the end time now.
   */

   // Read the pin b state to know if its 0 or 1
   readPINBState();

   if(pinbstate == 1)
    start_time = micros();

   if(pinbstate == 0)
   {
     // figure out total time,
     // determine a safe distance (like 5 inches)
     // print out "Safe Distance"  or "Too close" based on your science
     totduration = micros() - start_time;

     if((((totduration / 29 ) / 2)* 0.393701) > 5)
      Serial.println("Safe Distance");
     else
      Serial.println("Too close");
   }
}
