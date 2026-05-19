#include "bme280.h"

#include <Arduino.h>

bool Bme280Service::begin() {
  if (initialized) {
    return true;
  }

  Wire.begin();

  // Tenta ambos os endereços comuns (0x76 e 0x77), útil para módulos GYBMEP.
  const uint8_t candidates[2] = {kAddressPrimary, kAddressSecondary};
  for (uint8_t addr : candidates) {
    if (bme.begin(addr)) {
      selectedAddress = addr;
      initialized = true;
      break;
    }
  }

  if (!initialized) {
    return false;
  }

  const uint8_t chipId = bme.sensorID();
  // 0x60 => BME280 (humidade ok), 0x58 => BMP280 (sem humidade).
  if (chipId == 0x60) {
    hasHumidity = true;
  } else if (chipId == 0x58) {
    hasHumidity = false;
  } else {
    initialized = false;
    return false;
  }

  return true;
}

SensorReadings Bme280Service::read() {
  SensorReadings readings{};

  if (!initialized) {
    return readings;
  }

  readings.temperatureC = bme.readTemperature();
  readings.humidity = hasHumidity ? bme.readHumidity() : NAN;
  readings.pressureHpa = bme.readPressure() / 100.0F;
  return readings;
}

