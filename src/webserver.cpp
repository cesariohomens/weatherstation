#include "webserver.h"

#include <Arduino.h>
#include <WiFi.h>

namespace {

const char INDEX_HTML[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Weatherstation</title>
  <style>
    :root {
      --bg: #f5f7fa;
      --card: #ffffff;
      --text: #1f2933;
      --muted: #667481;
      --shadow: 0 6px 18px rgba(0,0,0,0.06);
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: system-ui, -apple-system, "Segoe UI", sans-serif;
      background: var(--bg);
      color: var(--text);
    }
    .container {
      max-width: 1100px;
      padding: 16px;
      margin: 0 auto;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 14px;
      gap: 8px;
      flex-wrap: wrap;
    }
    .title { font-size: 22px; margin: 0; }
    .muted { color: var(--muted); font-size: 13px; }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 12px;
    }
    .card {
      background: var(--card);
      border-radius: 12px;
      box-shadow: var(--shadow);
      padding: 14px;
      min-height: 160px;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    .card-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
      color: var(--muted);
      font-size: 14px;
    }
    .chip {
      display: inline-flex;
      align-items: center;
      padding: 2px 8px;
      border-radius: 999px;
      font-size: 12px;
      font-weight: 600;
      color: #fff;
    }
    .chip.temp { background: #e74c3c; }
    .chip.hum { background: #3498db; }
    .chip.pres { background: #f1c40f; color: #3b3b3b; }
    .value {
      font-size: 32px;
      font-weight: 650;
      letter-spacing: 0.3px;
    }
    .bar {
      width: 100%;
      height: 12px;
      border-radius: 999px;
      background: #e6e9ef;
      overflow: hidden;
    }
    .bar-fill {
      height: 100%;
      width: 0%;
      border-radius: 999px;
      transition: width 0.35s ease;
    }
    .bar.temp { background: #fbe3e0; }
    .bar-fill.temp { background: #e74c3c; }
    .bar.hum { background: #e1effa; }
    .bar-fill.hum { background: #3498db; }
    .bar.pres { background: #fff5d6; }
    .bar-fill.pres { background: #f1c40f; }
    @media (max-width: 480px) {
      .title { font-size: 20px; }
      .value { font-size: 28px; }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1 class="title">Weatherstation</h1>
      <span class="muted">Atualiza a cada 3s</span>
    </div>
    <div class="grid">
      <div class="card">
        <div class="card-row">
          <span>Temperatura</span>
          <span class="chip temp">°C</span>
        </div>
        <div id="tempValue" class="value">--.- °C</div>
        <div class="bar temp" aria-label="Temperatura">
          <div id="tempBar" class="bar-fill temp" style="width:0%"></div>
        </div>
      </div>
      <div class="card">
        <div class="card-row">
          <span>Humidade</span>
          <span class="chip hum">%</span>
        </div>
        <div id="humValue" class="value">--.- %</div>
        <div class="bar hum" aria-label="Humidade">
          <div id="humBar" class="bar-fill hum" style="width:0%"></div>
        </div>
      </div>
      <div class="card">
        <div class="card-row">
          <span>Pressão</span>
          <span class="chip pres">hPa</span>
        </div>
        <div id="pressValue" class="value">----.- hPa</div>
        <div class="bar pres" aria-label="Pressao">
          <div id="pressBar" class="bar-fill pres" style="width:0%"></div>
        </div>
      </div>
    </div>
  </div>

  <script>
    const clamp = (v, min, max) => Math.min(Math.max(v, min), max);

    function updateGauges(data) {
      const temp = Number(data.temperature) || 0;
      const hum = Number(data.humidity) || 0;
      const press = Number(data.pressure) || 0;

      document.getElementById("tempValue").textContent = `${temp.toFixed(1)} °C`;
      document.getElementById("humValue").textContent = `${hum.toFixed(1)} %`;
      document.getElementById("pressValue").textContent = `${press.toFixed(1)} hPa`;

      const tempPct = clamp(((temp + 10) / 60) * 100, 0, 100); // -10 to 50 °C
      const humPct = clamp(hum, 0, 100);
      const pressPct = clamp(((press - 950) / 150) * 100, 0, 100); // 950-1100 hPa

      document.getElementById("tempBar").style.width = `${tempPct}%`;
      document.getElementById("humBar").style.width = `${humPct}%`;
      document.getElementById("pressBar").style.width = `${pressPct}%`;
    }

    async function fetchReadings() {
      try {
        const response = await fetch("/api/readings");
        if (!response.ok) throw new Error("HTTP " + response.status);
        const data = await response.json();
        updateGauges(data);
      } catch (err) {
        console.error("Erro ao obter leituras:", err);
      }
    }

    fetchReadings();
    setInterval(fetchReadings, 3000);
  </script>
</body>
</html>
)rawliteral";

}  // namespace

void WebServerHandler::begin(Bme280Service& sensorRef) {
  sensor = &sensorRef;

  server.on("/", HTTP_GET, [this]() { handleRoot(); });
  server.on("/api/readings", HTTP_GET, [this]() { handleReadings(); });
  server.onNotFound([this]() { server.send(404, "text/plain", "Not found"); });
  server.begin();
}

void WebServerHandler::handleClient() { server.handleClient(); }

void WebServerHandler::handleRoot() { server.send_P(200, "text/html", INDEX_HTML); }

void WebServerHandler::handleReadings() {
  if (sensor == nullptr) {
    server.send(500, "application/json", "{\"error\":\"sensor not ready\"}");
    return;
  }

  const auto readings = sensor->read();
  char payload[160];
  snprintf(payload, sizeof(payload),
           "{\"temperature\":%.2f,\"humidity\":%.2f,\"pressure\":%.2f}",
           readings.temperatureC, readings.humidity, readings.pressureHpa);
  server.send(200, "application/json", payload);
}

