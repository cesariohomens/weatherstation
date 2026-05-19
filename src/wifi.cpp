#include "wifi.h"

#include <ESPmDNS.h>

void WifiAp::start() {
  const IPAddress apIp(192, 168, 4, 1);
  const IPAddress gateway(192, 168, 4, 1);
  const IPAddress subnet(255, 255, 255, 0);

  WiFi.mode(WIFI_AP);
  WiFi.softAPConfig(apIp, gateway, subnet);
  WiFi.softAP(kSsid, kPassword);
  ipAddress = WiFi.softAPIP();

  if (MDNS.begin(kHostname)) {
    MDNS.addService("http", "tcp", 80);
  }
}

IPAddress WifiAp::ip() const { return ipAddress; }
