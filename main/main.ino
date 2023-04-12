void setup() {
  Serial.begin(9600);
  pinMode(3, OUTPUT);
  pinMode(2, OUTPUT);
}

void loop() {
  // Liga o semaforo A - vermelho 
  digitalWrite(3, LOW);
  digitalWrite(2, LOW);
  Serial.println("Func");
  delay(500);
}
