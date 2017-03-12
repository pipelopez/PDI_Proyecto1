//Variables necesarias
int val = 10;
//Se crean dos variables de velocidad, una para cada llanta pues estas tiene diferente velocidad y con esto se controla
int velocidadAdelante = 100;
int velocidadAdelante2 = 120;
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
  
  //Se pone de inicio que el carro este quieto
  analogWrite(pin6, velocidadAdelante2);
  analogWrite(pin11, velocidadAdelante);
  digitalWrite(pin13, LOW);
  digitalWrite(pin7, LOW);
}

/*
*/
void loop()
{

  if (Serial.available() > 0) {
    //se obtiene la variables que le este llegando por la conexión bluetooth
    val = Serial.read();

    if (val != 0) {
      //para moverse a las difernetes posiciones se hace apagando una llanda y encendiendo la otra co eso el carro dara un giro,
      // el tiempo de dicho giro es con el cual se da lso diferentes angulos, esto se calculo  en la practica con el carro enn funcionamiento
      if (val == 10) { //en caso de que la variable de ingreso sea 10 se movera a la primera posicion
        digitalWrite(pin13, LOW);
        digitalWrite(pin7, HIGH);
        delay(150);
      }
      if (val==20) {//en caso de que la variable de ingreso sea 10 se movera a la segunda posicion
        digitalWrite(pin13, LOW);
        digitalWrite(pin7, HIGH);
        delay(100);
      }
      if (val==30) {//en caso de que la variable de ingreso sea 10 se movera a la tercera posicion
        digitalWrite(pin13, HIGH);
        digitalWrite(pin7, LOW);
        delay(100);
      }
      if (val==40) {//en caso de que la variable de ingreso sea 10 se movera a la cuarta posicion
        digitalWrite(pin13, HIGH);
        digitalWrite(pin7, LOW);
        delay(150);
      } 
      //luego de haber realizado el giro necesario avanzara hacia adelante, pro os sigueintes 4 segundos
      //tiempo suficiente para llegar a cada una de las figuras
      digitalWrite(pin13, HIGH);
      digitalWrite(pin7, HIGH);
      delay(4000);
      digitalWrite(pin13, LOW);
      digitalWrite(pin7, LOW);
    }
  }
}
