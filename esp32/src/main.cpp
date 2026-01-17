#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include <SPI.h>
#include <MFRC522.h>

// ================= НАСТРОЙКИ СЕТИ =================
const char* ssid = "vr";
const char* password = "123456789";
const char* serverUrl = "http://192.168.50.9:8080/update";
const char* authUrl = "http://192.168.50.9:8080/api/auth/card"; // Endpoint для авторизации

// ================= ПИНЫ ПОДКЛЮЧЕНИЯ =================
#define DHTPIN    4
#define RELAY_PIN 26
#define SOIL_PIN  34 
#define SS_PIN    5  // RFID SDA (SS)
#define RST_PIN   22 // RFID RST
// LED Pins removed - moved to ESP2

// ================= ОБЪЕКТЫ =================
DHT dht(DHTPIN, DHT11);
MFRC522 rfid(SS_PIN, RST_PIN);

// ================= ПЕРЕМЕННЫЕ =================
bool relayState = false;
// ledStates moved to ESP2

void setup() {
    Serial.begin(115200);
    SPI.begin();     // Инициализация SPI шины
    rfid.PCD_Init(); // Инициализация MFRC522
    dht.begin();
    
    // Настройка пина датчика почвы (вход)
    pinMode(SOIL_PIN, INPUT);

    // Настройка реле
    pinMode(RELAY_PIN, OUTPUT);
    digitalWrite(RELAY_PIN, HIGH); // Начальное состояние - выключено (инвертировано)
    Serial.println("Relay initialized. Initial state: OFF");

    // LEDs setup removed

    // Подключение к WiFi
    Serial.println("Connecting to WiFi");
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("\nWiFi Connected!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    Serial.print("Connecting to server: ");
    Serial.println(serverUrl);
}

void loop() {
    // Считывание данных с DHT11
    float temperature = dht.readTemperature();
    float humidity = dht.readHumidity();

    // Считывание данных с датчика влажности почвы
    // Обычно датчики выдают 4095 (сухо) -> 0 (влажно) или наоборот
    // Здесь предполагаем инвертированную логику: чем меньше значение, тем влажнее
    int soilRaw = analogRead(SOIL_PIN);
    int soilPercent = map(soilRaw, 4095, 0, 0, 100); 
    soilPercent = constrain(soilPercent, 0, 100); // Ограничиваем диапазон 0-100%

    // Проверка на корректность данных
    if (isnan(temperature)) temperature = 0.0;
    if (isnan(humidity)) humidity = 0.0;

    // --- RFID Считывание ---
    if (rfid.PICC_IsNewCardPresent() && rfid.PICC_ReadCardSerial()) {
        String uid = "";
        for (byte i = 0; i < rfid.uid.size; i++) {
            uid += String(rfid.uid.uidByte[i] < 0x10 ? "0" : "");
            uid += String(rfid.uid.uidByte[i], HEX);
        }
        uid.toUpperCase();
        
        Serial.print("RFID Detected: ");
        Serial.println(uid);

        // Отправка UID на сервер
        if (WiFi.status() == WL_CONNECTED) {
            HTTPClient http;
            http.begin(authUrl);
            http.addHeader("Content-Type", "application/json");
            
            String json = "{\"card_uid\": \"" + uid + "\"}";
            int httpCode = http.POST(json);
            
            if (httpCode == 200) {
                Serial.println("Auth Success!");
                // Можно помигать светодиодом для подтверждения (например встроенным)
                // digitalWrite(LED_PIN_1, HIGH); 
                // delay(500);
                // digitalWrite(LED_PIN_1, LOW);
            } else {
                Serial.printf("Auth Failed: %d\n", httpCode);
            }
            http.end();
        }
        
        // Halt PICC
        rfid.PICC_HaltA();
        // Stop encryption on PCD
        rfid.PCD_StopCrypto1();
    }
    // -----------------------

    // Отправка данных на сервер
    if (WiFi.status() == WL_CONNECTED) {
        HTTPClient http;
        http.begin(serverUrl);
        http.addHeader("Content-Type", "application/json");

        // Формирование JSON для отправки
        StaticJsonDocument<512> doc;
        doc["temp"] = temperature;
        doc["hum"] = humidity;
        doc["soil"] = soilPercent; // Добавляем влажность почвы
        doc["relay"] = relayState;
        // LEDs array removed from here - moved to ESP2

        String requestBody;
        serializeJson(doc, requestBody);

        Serial.print("Sending data: ");
        Serial.println(requestBody);

        int httpCode = http.POST(requestBody);

        if (httpCode == 200) {
            String response = http.getString();
            Serial.print("Server response: ");
            Serial.println(response);

            // Обработка ответа от сервера
            StaticJsonDocument<512> res;
            DeserializationError error = deserializeJson(res, response);

            if (!error) {
                // Получение команды для реле
                if (res.containsKey("command_relay")) {
                    bool newRelayState = res["command_relay"];
                    Serial.printf("Received command_relay: %s\n", newRelayState ? "ON" : "OFF");
                    if (newRelayState != relayState) {
                        relayState = newRelayState;
                        digitalWrite(RELAY_PIN, relayState ? LOW : HIGH); // Инвертированная логика
                        Serial.printf("Relay state changed to: %s\n", relayState ? "ON" : "OFF");
                    } else {
                        Serial.println("Relay state unchanged");
                    }
                } else {
                    Serial.println("No command_relay in response");
                }

                // LEDs command handling removed from here - moved to ESP2
            } else {
                Serial.print("JSON parse error: ");
                Serial.println(error.c_str());
            }
        } else {
            Serial.print("HTTP Error: ");
            Serial.println(httpCode);
        }

        http.end();
    }

    // Вывод данных в Serial Monitor
    Serial.printf("Temp: %.1fC, Hum: %.1f%%, Soil: %d%%, Relay: %s\n",
                 temperature, humidity, soilPercent, relayState ? "ON" : "OFF");
    
    delay(2000); // Отправка данных каждые 2 секунды
}
