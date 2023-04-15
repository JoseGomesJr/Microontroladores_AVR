void setup() {
  Serial.begin(9600);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
}

void loop() {
  // Liga o semaforo A - vermelho 
  digitalWrite(4, LOW);
  digitalWrite(5, LOW);
  Serial.println("Func");
  delay(500);
}
