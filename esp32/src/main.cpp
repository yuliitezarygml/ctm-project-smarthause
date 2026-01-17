#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <DHT.h>

// ================= НАСТРОЙКИ СЕТИ =================
const char* ssid = "vr";
const char* password = "123456789";
const char* serverUrl = "http://192.168.50.9:8080/update"; // Обновленный IP

// ================= ПИНЫ ПОДКЛЮЧЕНИЯ =================
#define DHTPIN    4
#define RELAY_PIN 26
#define SOIL_PIN  34 // Аналоговый вход для датчика почвы
#define LED_PIN_1 12
#define LED_PIN_2 13
#define LED_PIN_3 14
#define LED_PIN_4 15
#define LED_PIN_5 16
#define LED_PIN_6 17

// ================= ОБЪЕКТЫ =================
DHT dht(DHTPIN, DHT11);

// ================= ПЕРЕМЕННЫЕ =================
bool relayState = false;
bool ledStates[6] = {false, false, false, false, false, false};

void setup() {
    Serial.begin(115200);
    dht.begin();
    
    // Настройка пина датчика почвы (вход)
    pinMode(SOIL_PIN, INPUT);

    // Настройка реле
    pinMode(RELAY_PIN, OUTPUT);
    digitalWrite(RELAY_PIN, HIGH); // Начальное состояние - выключено (инвертировано)
    Serial.println("Relay initialized. Initial state: OFF");

    // Настройка светодиодов
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
    Serial.println("LEDs initialized. All LEDs: OFF");

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
        JsonArray ledsArray = doc.createNestedArray("lamps");
        for (int i = 0; i < 6; i++) {
            ledsArray.add(ledStates[i]);
        }

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

                // Получение команд для светодиодов
                if (res.containsKey("lamp_commands")) {
                    JsonArray lampCommands = res["lamp_commands"];
                    for (int i = 0; i < 6 && i < lampCommands.size(); i++) {
                        bool newLedState = lampCommands[i];
                        if (newLedState != ledStates[i]) {
                            ledStates[i] = newLedState;
                            int ledPin = LED_PIN_1 + i;
                            digitalWrite(ledPin, ledStates[i] ? HIGH : LOW); // Прямая логика
                            Serial.printf("LED %d state changed to: %s\n", i+1, ledStates[i] ? "ON" : "OFF");
                        }
                    }
                } else {
                    Serial.println("No lamp_commands in response");
                }
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
    Serial.printf("Temp: %.1fC, Hum: %.1f%%, Soil: %d%%, Relay: %s, LEDs: [",
                 temperature, humidity, soilPercent, relayState ? "ON" : "OFF");
    for (int i = 0; i < 6; i++) {
        Serial.printf("%s", ledStates[i] ? "ON" : "OFF");
        if (i < 5) Serial.print(", ");
    }
    Serial.println("]");

    delay(2000); // Отправка данных каждые 2 секунды
}
