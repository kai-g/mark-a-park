# mark-a-park

**Project Title:**
      Mark-A-Park: A Parking Availability Monitoring System for Commercial and Hospitality Establishments

**Description:**

Mark-A-Park is an IoT-based parking monitoring solution designed specifically for commercial and hospitality establishments, where large volumes of vehicles arrive and leave within short time periods. The system uses sensors, wireless communication, and a software application to monitor parking occupancy in real time and present the information to both drivers and administrators.The primary goal of the system is to optimize parking usage, reduce congestion, improve user experience, and provide actionable data to event organizers.
      
**Technologies Used:** 
     
      Flutter
      Dart
      IoT
      Cloud Computing (mention the cloud platform you’re using).
    
**Features:**
    
    Hardware Features
      Parking slot sensors
      Entrance and exit vehicle counters
      Real-time parking monitoring
      
    User Features
      Total parking availability display
      Available and occupied slot count
      Color-coded parking status
      2D parking map view   
    
**Installation Instructions:** 
      
      Option 1.
      1. Clone the repository: 
                  git clone https://github.com/kai-g/mark-a-park.git
      2. Using VS Code or Android Studio, open the project.
      3. Install required dependencies: 
                  flutter pub get
      4. Start an emulator or connect an android device
      5. Run application: 
                  flutter run

      Option 2. 
      1. Click the Code button in the project GitHub repository 
      2. Select Download ZIP, then extract the file to your computer.
      3. Using VS Code or Android Studio, open the project.
      4. Open a terminal inside the project folder
      5. Install required dependencies: 
                  flutter pub get
      6. Start an emulator or connect an android device
      7. Run application: 
                  flutter run

**Setup:** 

      IoT Devices
            Install sensors in each parking slot and at entrance/exit of parking gates
            Connect sensors to a microcontroller (ESP32 or Arduino)
            Configure WiFi
            Program the microcontroller to send parking data to the cloud database

      Cloud Service
            Set up a cloud database for real-time parking data
            Connect IoT devices and Flutter application to the cloud platform
            
