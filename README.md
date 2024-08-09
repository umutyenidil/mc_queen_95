#include <Arduino_FreeRTOS.h>
#include <SoftwareSerial.h>

//  constants
int trigPin = 13;
int echoPinRight = 2;  //  right
int echoPinFront = 8;  //  front
int echoPinLeft = 12;  // left
int MotorR1 = 7;
int MotorR2 = 6;
int MotorRE = 9;  // Motor pinlerini tanımlıyoruz.
int MotorL1 = 5;
int MotorL2 = 4;
int MotorLE = 3;
int LDRPin = A0;

//  variables
bool on = false;
int autoPower = 75;
int leftPower = 0;
int rightPower = 0;
bool isManual = true;

SoftwareSerial BTSerial(10, 11);

String data;

void bluetoothTask(void *pvParameters);
void controlTask(void *pvParameters);

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPinRight, INPUT);
  pinMode(echoPinFront, INPUT);
  pinMode(echoPinLeft, INPUT);

  pinMode(MotorL1, OUTPUT);
  pinMode(MotorL2, OUTPUT);
  pinMode(MotorLE, OUTPUT);  //Motorlarımızı çıkış olarak tanımlıyoruz.
  pinMode(MotorR1, OUTPUT);
  pinMode(MotorR2, OUTPUT);
  pinMode(MotorRE, OUTPUT);

  Serial.begin(9600);
  BTSerial.begin(9600);

  xTaskCreate(bluetoothTask, "BluetoothTask", 128, NULL, 1, NULL);
  xTaskCreate(controlTask, "MovementTask", 128, NULL, 1, NULL);
}

void loop() {
}

void bluetoothTask(void *pvParameters) {
  for (;;) {
    handleBluetoothData();
    vTaskDelay(100 / portTICK_PERIOD_MS);  // Delay to prevent task from running too frequently
  }
}

void controlTask(void *pvParameters) {
  for (;;) {
    if (on) {
      if (isManual) {
        dur();
        manualControl(leftPower, rightPower);
      } else {
        driveWithSensors();
      }
    } else {
      dur();
    }
    vTaskDelay(100 / portTICK_PERIOD_MS);  // Delay to prevent task from running too frequently
  }
}

void handleBluetoothData() {
  if (BTSerial.available() > 0) {
    data = BTSerial.readStringUntil('e');
    Serial.println(data);

    if (data == "start") {
      on = true;
    }
    if (data == "stop") {
      on = false;
    }
    if (data == "manual") {
      isManual = true;
    }
    if (data == "auto") {
      isManual = false;
    }
    if (startsWith(data.c_str(), 'i')) {
      int value = atoi(removeFirstLetter(data.c_str()));
      if (value == 1) {
        autoPower = 75;
      } else if (value == 2) {
        autoPower = 120;
      } else if (value == 3) {
        autoPower = 255;
      }
    } else if (startsWith(data.c_str(), 'g')) {
      int value = atoi(removeFirstLetter(data.c_str()));
      leftPower = 75;
      if (value == 1) {
        leftPower = 75;
      } else if (value == 2) {
        leftPower = 120;
      } else if (value == 3) {
        leftPower = 255;
      } else {
        leftPower = 0;
      }
    } else if (startsWith(data.c_str(), 'f')) {
      int value = atoi(removeFirstLetter(data.c_str()));
      leftPower = -75;
      if (value == 1) {
        leftPower = -75;
      } else if (value == 2) {
        leftPower = -120;
      } else if (value == 3) {
        leftPower = -255;
      }
    } else if (startsWith(data.c_str(), 'h')) {
      int value = atoi(removeFirstLetter(data.c_str()));
      Serial.print("h:");
      Serial.println(value);
      rightPower = 75;
      if (value == 1) {
        rightPower = 75;
      } else if (value == 2) {
        rightPower = 120;
      } else if (value == 3) {
        rightPower = 255;
      } else {
        rightPower = 0;
      }
    } else if (startsWith(data.c_str(), 'j')) {
      int value = atoi(removeFirstLetter(data.c_str()));
      Serial.print("j:");
      Serial.println(value);
      rightPower = -75;
      if (value == 1) {
        rightPower = -75;
      } else if (value == 2) {
        rightPower = -120;
      } else if (value == 3) {
        rightPower = -255;
      }
    }
  }
}

void driveWithSensors() {
  int lightPower = analogRead(LDRPin);



  long distanceRight = getDistanceWithDelay(trigPin, echoPinRight);
  long distanceFront = getDistanceWithDelay(trigPin, echoPinFront);
  long distanceLeft = getDistanceWithDelay(trigPin, echoPinLeft);
  Serial.print("distanceRight:");
  Serial.println(distanceRight);
  Serial.print("distanceFront:");
  Serial.println(distanceFront);
  Serial.print("distanceLeft:");
  Serial.println(distanceLeft);
  delay(10);
  if (distanceFront < 20) {
    geri();
    delay(10);
    if (distanceLeft < 20 || distanceRight < 20) {
      if (distanceLeft < 20) {
        sol();
      } else if (distanceRight < 20) {
        sag();
      }
    }
  } else if (distanceLeft < 20 || distanceRight < 20) {
    if (distanceLeft < 20) {
      sol();
    } else if (distanceRight < 20) {
      sag();
    }
  } else {
    sol();
  }

  ileri();
}

void manualControl(int leftPower, int rightPower) {

  if (rightPower < 0) {
    digitalWrite(MotorR1, HIGH);  // Sağ motorun ileri hareketi pasif
    digitalWrite(MotorR2, LOW);   // Sağ motorun geri hareketi aktif
  } else {
    digitalWrite(MotorR1, LOW);  // Sağ motorun ileri hareketi pasif
    digitalWrite(MotorR2, HIGH);
  }

  if (leftPower < 0) {
    digitalWrite(MotorL1, HIGH);  // Sağ motorun ileri hareketi pasif
    digitalWrite(MotorL2, LOW);   // Sağ motorun geri hareketi aktif
  } else {
    digitalWrite(MotorL1, LOW);  // Sağ motorun ileri hareketi pasif
    digitalWrite(MotorL2, HIGH);
  }

  analogWrite(MotorRE, abs(rightPower));  // Sağ motorun hızı 150

  analogWrite(MotorLE, abs(leftPower));  // Sol motorun hızı 150
}

void dur() {
  digitalWrite(MotorR1, LOW);  // Sağ motorun ileri hareketi aktif
  digitalWrite(MotorR2, LOW);  // Sağ motorun geri hareketi pasif
  digitalWrite(MotorL1, LOW);  // Sağ motorun ileri hareketi aktif
  digitalWrite(MotorL2, LOW);  // Sağ motorun geri hareketi pasif
}

void geri() {                       // Robotun ileri yönde hareketi için fonksiyon tanımlıyoruz.
  digitalWrite(MotorR1, HIGH);      // Sağ motorun ileri hareketi aktif
  digitalWrite(MotorR2, LOW);       // Sağ motorun geri hareketi pasif
  analogWrite(MotorRE, autoPower);  // Sağ motorun hızı 150
  digitalWrite(MotorL1, HIGH);      // Sol motorun ileri hareketi aktif
  digitalWrite(MotorL2, LOW);       // Sol motorun geri hareketi pasif
  analogWrite(MotorLE, autoPower);  // Sol motorun hızı 150
}
void sag() {                        // Robotun sağa dönme hareketi için fonksiyon tanımlıyoruz.
  digitalWrite(MotorR1, HIGH);      // Sağ motorun ileri hareketi aktif
  digitalWrite(MotorR2, LOW);       // Sağ motorun geri hareketi pasif
  analogWrite(MotorRE, 0);          // Sağ motorun hızı 0 (Motor duruyor)
  digitalWrite(MotorL1, HIGH);      // Sol motorun ileri hareketi aktif
  digitalWrite(MotorL2, LOW);       // Sol motorun geri hareketi pasif
  analogWrite(MotorLE, autoPower);  // Sol motorun hızı 150
}

void sol() {                        // Robotun sağa dönme hareketi için fonksiyon tanımlıyoruz.
  digitalWrite(MotorR1, HIGH);      // Sağ motorun ileri hareketi aktif
  digitalWrite(MotorR2, LOW);       // Sağ motorun geri hareketi pasif
  analogWrite(MotorLE, 0);          // Sağ motorun hızı 0 (Motor duruyor)
  digitalWrite(MotorL1, HIGH);      // Sol motorun ileri hareketi aktif
  digitalWrite(MotorL2, LOW);       // Sol motorun geri hareketi pasif
  analogWrite(MotorRE, autoPower);  // Sol motorun hızı 150
}

void ileri() {                      // Robotun geri yönde hareketi için fonksiyon tanımlıyoruz.
  digitalWrite(MotorR1, LOW);       // Sağ motorun ileri hareketi pasif
  digitalWrite(MotorR2, HIGH);      // Sağ motorun geri hareketi aktif
  analogWrite(MotorRE, autoPower);  // Sağ motorun hızı 150
  digitalWrite(MotorL1, LOW);       // Sol motorun ileri hareketi pasif
  digitalWrite(MotorL2, HIGH);      // Sol motorun geri hareketi aktif
  analogWrite(MotorLE, autoPower);  // Sol motorun hızı 150
}

long getDistance(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(10);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long time = pulseIn(echoPin, HIGH);
  long distance = (time / 29.1) / 2;
  return distance;
}

long getDistanceWithDelay(int trigPin, int echoPin) {
  delay(100);
  return getDistance(trigPin, echoPin);
}

char *removeFirstLetter(char *str) {
  int len = strlen(str);
  if (len > 0) {
    for (int i = 0; i < len - 1; i++) {
      str[i] = str[i + 1];
    }
    str[len - 1] = '\0';  // Terminate the string after shifting
  }
  return str;
}

char *removeFirstLetterNEW(const char *str) {
  // Create a copy of the string without the first character
  char *newStr = (char *)malloc(strlen(str));
  strcpy(newStr, str + 1);
  return newStr;
}

bool startsWith(const char *str, const char *prefix) {
  while (*prefix) {
    if (*prefix != *str) {
      return false;
    }
    prefix++;
    str++;
  }
  return true;
}
