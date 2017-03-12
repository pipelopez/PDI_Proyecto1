//Variables necesarias
int val = 10;
int velocidadAdelante = 100;
int velocidadAdelante2 = 120;
int velocidadGiro = 50;
//Motor Derecho
int pin6 = 6;
int pin7 = 7;
int pin8 = 8;
//Motor Izquierdo
int pin11 = 11;
int pin12 = 12;
int pin13 = 13;


/*------------------------------------------------------------------------
  --1. Inicializo el sistema -----------------------------------------------
  ------------------------------------------------------------------------*/
void setup()
{
  //Comunicación Serial
  Serial.begin(9600);
  //Motor Derecho
  pinMode(pin6, OUTPUT);//Pin Analogo
  pinMode(pin7, OUTPUT);
  pinMode(pin8, OUTPUT);
  //Motor Izquierdo
  pinMode(pin11, OUTPUT);//Pin Analogo
  pinMode(pin12, OUTPUT);
  pinMode(pin13, OUTPUT);
  analogWrite(pin6, velocidadAdelante2);
  analogWrite(pin11, velocidadAdelante);
  digitalWrite(pin13, LOW);
  digitalWrite(pin7, LOW);
}

/*
*/
void loop()
{
  /*NOTA:
    Casos para cada valor de val:
    10: Girar a la derecha
    20: Girar a la izquierda
    30: Detenerse
    40: Seguir adelante
  */
  if (Serial.available() > 0) {
    /*whatever is available from the serial is read here*/
    val = Serial.read();

    if (val != 0) {
      if (val == 10) {
        digitalWrite(pin13, LOW);
        digitalWrite(pin7, HIGH);
        delay(150);
      }
      if (val==20) {
        digitalWrite(pin13, LOW);
        digitalWrite(pin7, HIGH);
        delay(100);
      }
      if (val==30) {
        digitalWrite(pin13, HIGH);
        digitalWrite(pin7, LOW);
        delay(100);
      }
      if (val==40) {
        digitalWrite(pin13, HIGH);
        digitalWrite(pin7, LOW);
        delay(150);
      } 
      digitalWrite(pin13, HIGH);
      digitalWrite(pin7, HIGH);
      delay(4000);
      digitalWrite(pin13, LOW);
      digitalWrite(pin7, LOW);
    }
  }
}
