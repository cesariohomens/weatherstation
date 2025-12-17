#include <Arduino.h>
#include "wifi.h"
#include "bme280.h"
#include "webserver.h"

WifiAp wifiAp;
Bme280Service bme280;
WebServerHandler webServer;

void setup() {
  Serial.begin(115200);
  delay(200);

  wifiAp.start();
  Serial.print("AP iniciado em ");
  Serial.println(wifiAp.ip());

  if (!bme280.begin()) {
    Serial.println("Falha ao iniciar BME280. Verifique as ligacoes I2C.");
  }

  webServer.begin(bme280);
}

void loop() {
  webServer.handleClient();
  delay(10);
}