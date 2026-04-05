#define ENABLE_DATABASE
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <FirebaseClient.h>

// ===== WIFI =====
#define WIFI_SSID     "JajangMyeon"
#define WIFI_PASSWORD "solGE1228"

// ===== FIREBASE =====
#define DATABASE_URL  "https://sensor-test1-default-rtdb.asia-southeast1.firebasedatabase.app"

// ===== COUNT SENSORS =====
#define ENTRANCE_SENSOR 27
#define EXIT_SENSOR     25

WiFiClientSecure ssl_client;
using AsyncClient = AsyncClientClass;
AsyncClient aClient(ssl_client);

FirebaseApp app;
RealtimeDatabase Database;

NoAuth no_auth;

// ===== TIMING =====
const unsigned long STABLE_MS = 300;

// ===== SLOT SENSORS =====
const int NUM_SLOTS = 6;
const int irPins[NUM_SLOTS] = {4, 16, 5, 18, 21, 22};
const char* slotNames[NUM_SLOTS] = {"A", "B", "C", "D", "E", "F"};

// ===== SLOT STATE =====
String lastSentStatus[NUM_SLOTS];
String lastReadStatus[NUM_SLOTS];
unsigned long lastChangeAt[NUM_SLOTS];

// ===== COUNT STATE =====
String lastEntranceRead = "";
String lastEntranceSent = "";
unsigned long lastEntranceChangeAt = 0;

String lastExitRead = "";
String lastExitSent = "";
unsigned long lastExitChangeAt = 0;

int carsEntered = 0;
// DAILY COUNTS
int carsEnteredToday = 0;
int carsExitedToday = 0;

void writeCarsEntered() {
  bool ok = Database.set(aClient, "/parking/carsEntered", carsEntered);

  Serial.print("WRITING /parking/carsEntered = ");
  Serial.println(carsEntered);

  if (ok) {
    Serial.println("COUNT WRITE OK");
  } else {
    Serial.print("COUNT WRITE FAIL: ");
    Serial.print(aClient.lastError().message().c_str());
    Serial.print(" (CODE ");
    Serial.print(aClient.lastError().code());
    Serial.println(")");
  }
}

// WRITE CARS ENTERED TODAY
void writeCarsEnteredToday() {
  bool ok = Database.set(aClient, "/parking/carsEnteredToday", carsEnteredToday);

  Serial.print("WRITING /parking/carsEnteredToday = ");
  Serial.println(carsEnteredToday);

  if (ok) {
    Serial.println("ENTERED TODAY WRITE OK");
  } else {
    Serial.print("ENTERED TODAY WRITE FAIL: ");
    Serial.print(aClient.lastError().message().c_str());
    Serial.print(" (CODE ");
    Serial.print(aClient.lastError().code());
    Serial.println(")");
  }
}

// WRITE CARS EXITED TODAY
void writeCarsExitedToday() {
  bool ok = Database.set(aClient, "/parking/carsExitedToday", carsExitedToday);

  Serial.print("WRITING /parking/carsExitedToday = ");
  Serial.println(carsExitedToday);

  if (ok) {
    Serial.println("EXITED TODAY WRITE OK");
  } else {
    Serial.print("EXITED TODAY WRITE FAIL: ");
    Serial.print(aClient.lastError().message().c_str());
    Serial.print(" (CODE ");
    Serial.print(aClient.lastError().code());
    Serial.println(")");
  }
}


void setup() {
  Serial.begin(115200);
  delay(200);

  Serial.println("\nBOOTING...");

  // SLOT PINS
  for (int i = 0; i < NUM_SLOTS; i++) {
    pinMode(irPins[i], INPUT);
    lastSentStatus[i] = "";
    lastReadStatus[i] = "";
    lastChangeAt[i] = 0;
  }

  // COUNT PINS
  pinMode(ENTRANCE_SENSOR, INPUT);
  pinMode(EXIT_SENSOR, INPUT);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("CONNECTING TO WIFI");
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }

  Serial.println("\nWIFI CONNECTED!");
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());

  ssl_client.setInsecure();

  Serial.println("INITIALIZING FIREBASE...");
  initializeApp(aClient, app, getAuth(no_auth));
  app.getApp(Database);
  Database.url(DATABASE_URL);

  Serial.println("SETUP DONE.");
}

void loop() {
  app.loop();
  if (!app.ready()) return;

  unsigned long now = millis();

  // ===== SLOT CHECK =====
  for (int i = 0; i < NUM_SLOTS; i++) {
    int sensorValue = digitalRead(irPins[i]);
    String nowStatus = (sensorValue == LOW) ? "occupied" : "vacant";

    if (nowStatus != lastReadStatus[i]) {
      lastReadStatus[i] = nowStatus;
      lastChangeAt[i] = now;
    }

    if ((now - lastChangeAt[i]) >= STABLE_MS && nowStatus != lastSentStatus[i]) {
      lastSentStatus[i] = nowStatus;

      String path = "/parking/slots/" + String(slotNames[i]);

      Serial.print("SLOT ");
      Serial.print(slotNames[i]);
      Serial.print(" -> ");
      Serial.println(nowStatus);

      bool ok = Database.set(aClient, path, nowStatus);

      if (ok) {
        Serial.println("SLOT WRITE OK");
      } else {
        Serial.print("SLOT WRITE FAIL: ");
        Serial.print(aClient.lastError().message().c_str());
        Serial.print(" (CODE ");
        Serial.print(aClient.lastError().code());
        Serial.println(")");
      }
    }
  }

  // ===== ENTRANCE CHECK =====
  int entranceValue = digitalRead(ENTRANCE_SENSOR);
  String entranceStatus = (entranceValue == LOW) ? "triggered" : "idle";

  if (entranceStatus != lastEntranceRead) {
    lastEntranceRead = entranceStatus;
    lastEntranceChangeAt = now;
  }

  if ((now - lastEntranceChangeAt) >= STABLE_MS && entranceStatus != lastEntranceSent) {
    lastEntranceSent = entranceStatus;

    if (entranceStatus == "triggered") {
      carsEntered++;
      carsEnteredToday++;

      Serial.println("ENTRANCE TRIGGERED");

      writeCarsEntered();
      writeCarsEnteredToday();
    }
  }

  // ===== EXIT CHECK =====
  int exitValue = digitalRead(EXIT_SENSOR);
  String exitStatus = (exitValue == LOW) ? "triggered" : "idle";

  if (exitStatus != lastExitRead) {
    lastExitRead = exitStatus;
    lastExitChangeAt = now;
  }

  if ((now - lastExitChangeAt) >= STABLE_MS && exitStatus != lastExitSent) {
    lastExitSent = exitStatus;

    if (exitStatus == "triggered") {
      if (carsEntered > 0) {
        carsEntered--;
      }

      carsExitedToday++;

      Serial.println("EXIT TRIGGERED");

      writeCarsEntered();
      writeCarsExitedToday();
    }
  }

  delay(10);
}