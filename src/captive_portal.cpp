#include "captive_portal.h"

void CaptivePortal::begin(const IPAddress& apIp) {
  // Wildcard DNS: all hostnames (including weatherstation.local) resolve to the AP IP.
  dnsServer_.start(53, "*", apIp);
}

void CaptivePortal::process() { dnsServer_.processNextRequest(); }
