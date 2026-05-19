#include <Arduino.h>

#include "bme280.h"
#include "webserver.h"
#include "wifi.h"

WifiAp wifiAp;
Bme280Service bme280;
WebServerHandler webServer;

void setup() {
  Serial.begin(115200);
  delay(200);

  wifiAp.start();
  Serial.print("AP started at ");
  Serial.println(wifiAp.ip());

  if (!bme280.begin()) {
    Serial.println("BME280 init failed. Check I2C wiring.");
  }

  webServer.begin(bme280);
}

void loop() {
  webServer.handleClient();
  delay(10);
}
