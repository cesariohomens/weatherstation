#pragma once

#include <WebServer.h>
#include "bme280.h"

class WebServerHandler {
 public:
  void begin(Bme280Service& sensor);
  void handleClient();

 private:
  void handleRoot();
  void handleReadings();

  WebServer server{80};
  Bme280Service* sensor{nullptr};
};

