// Plant monitor: soil moisture page on port 80, ntfy check three times a day.
#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WebServer.h>
#include <time.h>
#include "secrets.h"

// Static address on the LAN; DNS is Pi-hole
IPAddress local_IP(10, 0, 10, 184);   // example addresses
IPAddress gateway(10, 0, 10, 1);
IPAddress subnet(255, 255, 255, 0);
IPAddress dns(10, 0, 10, 53);

// Calibration: raw reading in dry air and in water
const int DRY_VALUE = 700;
const int WET_VALUE = 300;
const int THRESHOLD = 40;          // percent; below this the plant needs water

const int alertHours[] = {8, 12, 20};
int lastAlertHour = -1;

ESP8266WebServer server(80);

int readMoisture() {
  int raw = analogRead(A0);
  return constrain(map(raw, DRY_VALUE, WET_VALUE, 0, 100), 0, 100);
}

void handleRoot() {
  int percent = readMoisture();
  String status = (percent < THRESHOLD) ? "needs water" : "OK";
  server.send(200, "text/plain", "Moisture: " + String(percent) + "% (" + status + ")");
}

void sendAlert(int percent) {
  WiFiClientSecure client;
  client.setInsecure();            // skips cert validation to save memory; fine for a plant reading
  HTTPClient http;
  String status = (percent < THRESHOLD) ? "needs water" : "OK";
  http.begin(client, "https://ntfy.sh/" + String(NTFY_TOPIC));
  http.addHeader("Content-Type", "text/plain");
  http.POST("Plant check: " + String(percent) + "% (" + status + ")");
  http.end();
}

void setup() {
  Serial.begin(115200);

  if (!WiFi.config(local_IP, gateway, subnet, dns)) {
    Serial.println("Static IP config failed");
  }
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.print("\nConnected, IP address: ");
  Serial.println(WiFi.localIP());

  // Fixed UTC-7 offset, no DST. Wait at most 10 s for NTP so the web server
  // always starts. (The first version waited forever and never served a page.)
  configTime(-7 * 3600, 0, "pool.ntp.org", "time.nist.gov");
  time_t now = time(nullptr);
  int attempts = 0;
  while (now < 100000 && attempts < 20) {
    delay(500);
    now = time(nullptr);
    attempts++;
  }

  server.on("/", handleRoot);
  server.begin();
}

void loop() {
  server.handleClient();

  static unsigned long lastCheck = 0;
  if (millis() - lastCheck >= 300000UL) {   // every 5 minutes
    lastCheck = millis();
    int percent = readMoisture();
    Serial.println(percent);

    time_t now = time(nullptr);
    if (now < 100000) return;               // clock not set yet; skip scheduled alerts
    int currentHour = localtime(&now)->tm_hour;

    for (int i = 0; i < 3; i++) {
      if (currentHour == alertHours[i] && currentHour != lastAlertHour) {
        sendAlert(percent);
        lastAlertHour = currentHour;
        break;
      }
    }
  }
}
