#include "bme280.h"

#include <math.h>

bool Bme280Service::begin() {
  if (initialized) {
    return true;
  }

  Wire.begin();

  for (uint8_t address : {kI2cAddressPrimary, kI2cAddressSecondary}) {
    if (!bme.begin(address)) {
      continue;
    }

    const uint8_t chipId = bme.sensorID();
    if (chipId == kChipIdBme280) {
      hasHumidity = true;
    } else if (chipId == kChipIdBmp280) {
      hasHumidity = false;
    } else {
      continue;
    }

    initialized = true;
    return true;
  }

  return false;
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
