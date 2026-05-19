#include <Arduino.h>

#include "bme280.h"
#include "captive_portal.h"
#include "webserver.h"
#include "wifi.h"

WifiAp wifiAp;
CaptivePortal captivePortal;
Bme280Service bme280;
WebServerHandler webServer;

void setup() {
  Serial.begin(115200);
  delay(200);

  wifiAp.start();
  captivePortal.begin(wifiAp.ip());
  Serial.print(F("AP started at "));
  Serial.println(wifiAp.ip());
  Serial.println(F("Open http://weatherstation.local"));

  if (!bme280.begin()) {
    Serial.println(F("BME280 init failed. Check I2C wiring."));
  }

  webServer.begin(bme280);
}

void loop() {
  captivePortal.process();
  webServer.handleClient();
  delay(2);
}
