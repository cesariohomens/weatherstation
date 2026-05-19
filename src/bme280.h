#pragma once

#if __has_include(<Adafruit_BME280.h>)
#include <Adafruit_BME280.h>
#elif __has_include("Adafruit_BME280.h")
#include "Adafruit_BME280.h"
#elif __has_include("../.pio/libdeps/esp32doit-devkit-v1/Adafruit BME280 Library/Adafruit_BME280.h")
#include "../.pio/libdeps/esp32doit-devkit-v1/Adafruit BME280 Library/Adafruit_BME280.h"
#else
#error "Adafruit_BME280.h not found. Ensure PlatformIO libdeps are installed."
#endif

#include <Adafruit_Sensor.h>
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

 private:
  Adafruit_BME280 bme;
  bool initialized{false};
   bool hasHumidity{true};
  uint8_t selectedAddress{0x76};
  static constexpr uint8_t kAddressPrimary = 0x76;
  static constexpr uint8_t kAddressSecondary = 0x77;
};

