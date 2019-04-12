void setup() {
  // put your setup code here, to run once:
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);

  pinMode(0, OUTPUT);
  pinMode(1, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  pinMode(8, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(12, OUTPUT);
  pinMode(13, OUTPUT);
}

void loop() {
  // read the potentiometers
  int LPot = analogRead(A0);
  int RPot = analogRead(A1);

  //Set Left Outputs
  if((LPot >> 3) & 1)
    digitalWrite(0, HIGH);
  else
    digitalWrite(0, LOW);
  if((LPot >> 4) & 1)
    digitalWrite(1, HIGH);
  else
    digitalWrite(1, LOW);
  if((LPot >> 5) & 1)
    digitalWrite(2, HIGH);
  else
    digitalWrite(2, LOW);
  if((LPot >> 6) & 1)
    digitalWrite(3, HIGH);
  else
    digitalWrite(3, LOW);
  if((LPot >> 7) & 1)
    digitalWrite(4, HIGH);
  else
    digitalWrite(4, LOW);
  if((LPot >> 8) & 1)
    digitalWrite(5, HIGH);
  else
    digitalWrite(5, LOW);
  if((LPot >> 9) & 1)
    digitalWrite(6, HIGH);
  else
    digitalWrite(6, LOW);

  //Set Right Outputs
  if((RPot >> 3) & 1)
    digitalWrite(7, HIGH);
  else
    digitalWrite(7, LOW);
  if((RPot >> 4) & 1)
    digitalWrite(8, HIGH);
  else
    digitalWrite(8, LOW);
  if((RPot >> 5) & 1)
    digitalWrite(9, HIGH);
  else
    digitalWrite(9, LOW);
  if((RPot >> 6) & 1)
    digitalWrite(10, HIGH);
  else
    digitalWrite(10, LOW);
  if((RPot >> 7) & 1)
    digitalWrite(11, HIGH);
  else
    digitalWrite(11, LOW);
  if((RPot >> 8) & 1)
    digitalWrite(12, HIGH);
  else
    digitalWrite(12, LOW);
  if((RPot >> 9) & 1)
    digitalWrite(13, HIGH);
  else
    digitalWrite(13, LOW);
}
