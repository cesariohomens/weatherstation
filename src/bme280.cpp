#include "bme280.h"

bool Bme280Service::begin() {
  if (initialized) {
    return true;
  }

  Wire.begin();
  initialized = bme.begin(kAddress);
  return initialized;
}

SensorReadings Bme280Service::read() {
  SensorReadings readings{};

  if (!initialized) {
    return readings;
  }

  readings.temperatureC = bme.readTemperature();
  readings.humidity = bme.readHumidity();
  readings.pressureHpa = bme.readPressure() / 100.0F;
  return readings;
}

