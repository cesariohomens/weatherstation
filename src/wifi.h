#pragma once

#include <WiFi.h>

class WifiAp {
 public:
  void start();
  IPAddress ip() const;

 private:
  static constexpr const char* kSsid = "weatherstation";
  static constexpr const char* kPassword = "123456789";
  IPAddress ipAddress{192, 168, 4, 1};
};

