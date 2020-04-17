extern "C" {
  void initAD();
  byte readAD(byte pin);
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  initAD(); // call assembly init A/D routine
}

void loop() {
  // put your main code here, to run repeatedly:
  byte v;
  v = readAD(2); // call assembly read sensor routine, A/D pin #2
  Serial.print(" light = ");
  Serial.print(v, HEX);
  Serial.print("\n");
  delay(1000); // delay one second
}
