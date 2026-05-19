#pragma once

#include <Adafruit_BME280.h>
#include <Wire.h>

struct SensorReadings {
  float temperatureC;
  float humidity;
  float pressureHpa;
};

class Bme280Service {
 public:
  bool begin();
  SensorReadings read();
  bool isReady() const { return initialized; }

 private:
  static constexpr uint8_t kChipIdBme280 = 0x60;
  static constexpr uint8_t kChipIdBmp280 = 0x58;
  static constexpr uint8_t kI2cAddressPrimary = 0x76;
  static constexpr uint8_t kI2cAddressSecondary = 0x77;

  Adafruit_BME280 bme;
  bool initialized{false};
  bool hasHumidity{true};
};
