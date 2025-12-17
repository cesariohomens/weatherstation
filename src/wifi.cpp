#include "wifi.h"

void WifiAp::start() {
  WiFi.mode(WIFI_AP);
  WiFi.softAP(kSsid, kPassword);
  ipAddress = WiFi.softAPIP();
}

IPAddress WifiAp::ip() const { return ipAddress; }

