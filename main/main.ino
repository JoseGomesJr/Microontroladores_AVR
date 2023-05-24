int motor_l = 6;
int motor_r = 5;

int motor_l_f = 9;
int motor_l_b = 10;

int motor_r_f = 11;
int motor_r_b = 12;

int val_r = 50;   
int val_l = 50;
int led_warning = DD7;
int led_warning2 = 8;
float ganho_p = 1.2;
bool saiu_esqueda = false;
bool saiu_direita = false;

int sensor_right = A3;
int sensor_left = A2;


//display A4 -> SDA A5 -> SCL
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 32 // OLED display height, in pixels
#define SCREEN_ADDRESS 0x3C ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

void setupDisplay(void) {
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;);
  }

  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(0,0);
}

void setup() {
  Serial.begin(9600);

  pinMode(motor_l, OUTPUT);  // configura pino como saída
  pinMode(motor_r, OUTPUT);  // configura pino como 
  
  pinMode(motor_l_f, OUTPUT);  // configura pino como saída
  pinMode(motor_l_b, OUTPUT); 

  pinMode(motor_r_f, OUTPUT);  // configura pino como saída
  pinMode(motor_r_b, OUTPUT); 

  pinMode(led_warning, OUTPUT);  // configura pino como saída
  pinMode(led_warning2, OUTPUT);  // configura pino como saída
  pinMode(sensor_left, INPUT);
  pinMode(sensor_right, INPUT);

  setupDisplay();

  digitalWrite(led_warning, LOW);
  digitalWrite(led_warning2, LOW);
  analogWrite(motor_l, 0);
  analogWrite(motor_r, 0);
  delay(5000);
  analogWrite(motor_l, 100);
  analogWrite(motor_r, 100);
  delay(50);
}

void control_p(bool direction){



  if(direction){
    val_r = val_r * ganho_p;
    Serial.println("Curva para direita");
    digitalWrite(led_warning, HIGH);
    digitalWrite(led_warning2, LOW);
    digitalWrite(motor_r_f, HIGH);
    digitalWrite(motor_l_b, HIGH);
    saiu_esqueda = true;
    val_l = 45;
  }
  else{
    Serial.println("Curva para esquerda");
    digitalWrite(led_warning2, HIGH);
    digitalWrite(led_warning, LOW);

    digitalWrite(motor_r_b, HIGH);
    digitalWrite(motor_l_f, HIGH);

    val_l = ganho_p * val_l;
    saiu_direita = true;
    val_r = 45;
  }
  
  
  val_l = constrain(val_l,0,50);
  val_r = constrain(val_r,0,50);

}

void sensor_read( int sensor_right, int sensor_left )
{

  digitalWrite(motor_r_f, LOW);
  digitalWrite(motor_r_b, LOW);

  digitalWrite(motor_l_f, LOW);
  digitalWrite(motor_l_b, LOW);

  if (sensor_right > 425) {
    control_p(true);
    return;
  }
  if(sensor_left > 400 ){
    control_p(false);
    return;
  }

  digitalWrite(led_warning, LOW);
  digitalWrite(led_warning2, LOW);

  digitalWrite(motor_r_f, HIGH);
  digitalWrite(motor_l_f, HIGH);


  saiu_esqueda = false;
  saiu_direita = false;
  val_l = 50;
  val_r = 50;
}

void printInformation(int leitura_l, int leitura_r) {
  float voltage_l = leitura_l * (5.0 / 1023.0);
  float voltage_r = leitura_r * (5.0 / 1023.0);

  display.clearDisplay();
  display.setCursor(0,0);
  display.println("L -> PWM: " + String(leitura_l) + "   " + String(voltage_l) + "V");
  display.println("R -> PWM: " + String(leitura_r) + "   " + String(voltage_r) + "V");
  display.display();
}

void loop() {

  int leitura_r = analogRead(sensor_right);
  int leitura_l = analogRead(sensor_left);
  
  Serial.print("Leitura da direita: ");
  Serial.println(leitura_r);
  Serial.print("Leitura da esquerda: ");
  Serial.println( leitura_l);
  
  analogWrite(motor_l, 100);
  analogWrite(motor_r, 100);
  delay(20);
  analogWrite(motor_l, val_l);
  analogWrite(motor_r, val_r);

  sensor_read(leitura_r, leitura_l);
  printInformation(leitura_l, leitura_r);
  Serial.print("Potencia da esquerda: ");
  Serial.println( val_l);
  Serial.print("Potencia da direita: ");
  Serial.println(val_r);
}
