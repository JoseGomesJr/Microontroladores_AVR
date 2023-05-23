#include <Wire.h>
#include <LiquidCrystal_I2C.h>


LiquidCrystal_I2C lcd(0x27, 16, 2);  // Endereço I2C do display e configuração do tamanho


int motor_l = 6;
int motor_r = 5;
int val_r = 90;   
int val_l = 90;
int led_warning = DD7;
float ganho_p = 1.2;
bool saiu_esqueda = false;
bool saiu_direita = false;

int sensor_right = A4;
int sensor_left = A3;

void setup() {
  Serial.begin(9600);

  //Configurações do display
  lcd.begin(16, 2);
  lcd.clear();
  lcd.print("Tensao (V) - Motor1:");
  lcd.setCursor(0, 1);
  lcd.print("Tensao (V) - Motor2:");


  pinMode(motor_l, OUTPUT);  // configura pino como saída
  pinMode(motor_r, OUTPUT);  // configura pino como saída
  pinMode(led_warning, OUTPUT);  // configura pino como saída
  pinMode(sensor_left, INPUT);
  pinMode(sensor_right, INPUT);

  digitalWrite(led_warning, LOW);
  analogWrite(motor_l, 0);
  analogWrite(motor_r, 0);
  delay(5000);
}

void control_p(bool direction){

  if(direction){
    val_r = val_r * ganho_p;
    Serial.println("Curva para direita");
    saiu_esqueda = true;
    val_l = 80;
  }
  else{
    Serial.println("Curva para esquerda");
    val_l = val_l * ganho_p;
    saiu_direita = true;
    val_r = 80;
  }
  
  digitalWrite(led_warning, HIGH);
  val_l = constrain(val_l,0,110);
  val_r = constrain(val_r,0,110);

}

void sensor_read( int sensor_right, int sensor_left )
{
  if (sensor_right < 425) {
    control_p(true);
    return;
  }
  if(sensor_left < 330 ){
    control_p(false);
    return;
  }

  digitalWrite(led_warning, LOW);
  saiu_esqueda = false;
  saiu_direita = false;
  val_l = 90;
  val_r = 90;
}

void exibir_display() {
  int valorPWM1 = analogRead(sensor_left);  // Leitura do valor PWM para o motor esquerdo  
  int valorPWM2 = analogRead(sensor_right);  // Leitura do valor PWM para o motor direito 
  
  float tensao1 = (valorPWM1 / 1023.0) * 5.0;  // Cálculo da tensão para o motor esquerdo
  float tensao2 = (valorPWM2 / 1023.0) * 5.0;  // Cálculo da tensão para o motor direito
  
  // Atualiza os valores no display
  lcd.setCursor(14, 0);
  lcd.print("    ");  // Limpa o espaço anterior
  lcd.setCursor(14, 0);
  lcd.print(tensao1, 2);  // Exibe a tensão do motor esquerdo  
  
  lcd.setCursor(14, 1);
  lcd.print("    ");  // Limpa o espaço anterior
  lcd.setCursor(14, 1);
  lcd.print(tensao2, 2);  // Exibe a tensão do motor direito  
  
  delay(500);  // Aguarda 500ms antes de atualizar novamente
}

void loop() {

  int leitura_r = analogRead(sensor_right);
  int leitura_l = analogRead(sensor_left);
  
  Serial.print("Leitura da direita: ");
  Serial.println(leitura_r);
  Serial.print("Leitura da esquerda: ");
  Serial.println( leitura_l);
  
  analogWrite(motor_l, val_l);
  analogWrite(motor_r, val_r);

  sensor_read(leitura_r, leitura_l);

  Serial.print("Potencia da esquerda: ");
  Serial.println( val_l);
  Serial.print("Potencia da direita: ");
  Serial.println(val_r);

  exibir_display();
}
