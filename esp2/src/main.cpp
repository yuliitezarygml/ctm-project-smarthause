#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// ================= НАСТРОЙКИ СЕТИ =================
const char* ssid = "vr";
const char* password = "123456789";
const char* serverUrl = "http://192.168.50.9:8080/api/lamps/commands";

// ================= ПИНЫ СВЕТОДИОДОВ =================
// Pins 12-14 and 27, 26, 25 are common on ESP32 DevKit V1
// Adjust if your wiring is different
#define LED_PIN_1 12
#define LED_PIN_2 13 // NOTE: If using onboard LED (GPIO 2), change this
#define LED_PIN_3 14
#define LED_PIN_4 27
#define LED_PIN_5 26
#define LED_PIN_6 25

// ================= ПЕРЕМЕННЫЕ =================
bool ledStates[6] = {false, false, false, false, false, false};

void setup() {
  Serial.begin(115200);
  
  // Инициализация светодиодов
  pinMode(LED_PIN_1, OUTPUT);
  pinMode(LED_PIN_2, OUTPUT);
  pinMode(LED_PIN_3, OUTPUT);
  pinMode(LED_PIN_4, OUTPUT);
  pinMode(LED_PIN_5, OUTPUT);
  pinMode(LED_PIN_6, OUTPUT);
  
  digitalWrite(LED_PIN_1, LOW);
  digitalWrite(LED_PIN_2, LOW);
  digitalWrite(LED_PIN_3, LOW);
  digitalWrite(LED_PIN_4, LOW);
  digitalWrite(LED_PIN_5, LOW);
  digitalWrite(LED_PIN_6, LOW);

  Serial.println("LEDs initialized.");

  // Подключение к WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println(" Connected!");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(serverUrl);
    int httpCode = http.GET();

    if (httpCode == 200) {
      String payload = http.getString();
      
      StaticJsonDocument<512> doc;
      DeserializationError error = deserializeJson(doc, payload);

      if (!error) {
        if (doc.containsKey("lamp_commands")) {
            JsonArray lampCommands = doc["lamp_commands"];
            for (int i = 0; i < 6 && i < lampCommands.size(); i++) {
                bool newState = lampCommands[i];
                if (newState != ledStates[i]) {
                    ledStates[i] = newState;
                    int pin;
                    switch(i) {
                        case 0: pin = LED_PIN_1; break;
                        case 1: pin = LED_PIN_2; break;
                        case 2: pin = LED_PIN_3; break;
                        case 3: pin = LED_PIN_4; break;
                        case 4: pin = LED_PIN_5; break;
                        case 5: pin = LED_PIN_6; break;
                    }
                    digitalWrite(pin, ledStates[i] ? HIGH : LOW);
                    Serial.printf("LED %d set to %s\n", i+1, ledStates[i] ? "ON" : "OFF");
                }
            }
        }
      } else {
        Serial.print("JSON Error: ");
        Serial.println(error.c_str());
      }
    } else {
        Serial.printf("HTTP Error: %d\n", httpCode);
    }
    http.end();
  } else {
    Serial.println("WiFi Disconnected!");
  }

  // Periodic status log
  static unsigned long lastLog = 0;
  if (millis() - lastLog > 2000) {
      lastLog = millis();
      Serial.print("Status: [");
      for(int i=0; i<6; i++) {
          Serial.print(ledStates[i] ? "ON" : "OFF");
          if(i<5) Serial.print(", ");
      }
      Serial.println("]");
  }
  
  delay(500); // Опрос каждые 0.5 секунды для быстрой реакции
}
