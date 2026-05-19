#pragma once

#include <DNSServer.h>
#include <IPAddress.h>

class CaptivePortal {
 public:
  void begin(const IPAddress& apIp);
  void process();

 private:
  DNSServer dnsServer_;
};
