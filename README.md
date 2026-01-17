# 🏠 Smart Home Automation System

## 📋 Project Overview

This is a **complete smart home automation system** with a **web dashboard**, **ESP32 controller**, and **backend services**. The system provides real-time monitoring and control of lamps, sensors, solar panels, and various home automation devices.

## 🗂️ Project Structure

```
ctm-project-smarthause-main/
├── README.md                    # This file - Project overview
├── esp32/                      # ESP32 Firmware & Hardware
│   ├── README.md                # ESP32 documentation
│   ├── WIRING_GUIDE.md          # Wiring instructions
│   ├── LAMP_CONTROL_GUIDE.md    # Advanced lamp control
│   ├── COMPLETE_SETUP_GUIDE.md  # Complete setup guide
│   ├── platformio.ini           # ESP32 project config
│   └── src/
│       └── main.cpp             # Main firmware
├── frontend/                   # Web Dashboard (Next.js)
│   ├── components/              # React components
│   │   ├── Dashboard.js         # Main dashboard
│   │   └── SolarPanel.js        # Real-time solar panel
│   ├── pages/                   # Next.js pages
│   │   ├── api/                 # API endpoints
│   │   │   └── solar-panel.js   # Mock solar API
│   │   └── index.js             # Main page
│   ├── services/                # API services
│   │   └── api.js               # API client
│   └── styles/                  # CSS styles
│       └── globals.css          # Global styles
├── homesass/                   # Mobile Application (Flutter)
│   ├── lib/                     # Dart source code
│   │   ├── main.dart            # Main application entry
│   │   ├── models/              # Data models
│   │   ├── providers/           # State management
│   │   ├── screens/             # Application screens
│   │   ├── widgets/             # UI components
│   │   └── utils/               # Utilities and constants
│   ├── android/                 # Android platform
│   ├── windows/                 # Windows platform
│   └── pubspec.yaml             # Flutter dependencies
└── GolandProjects/             # Backend Services
    └── awesomeProject/          # Go backend
        ├── main.go              # Main server
        └── data.json            # Sample data
```

## 🎯 System Architecture

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                                                                               │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────────────┐  │
│   │  Web Dashboard │    │  ESP32     │    │  Backend Server (Go)          │  │
│   │  (Next.js)    │    │  Controller│    │                                │  │
│   └─────────────┘    └─────────────┘    └─────────────────────────────────┘  │
│          │                   │                         │                      │
│          │ HTTP/JSON         │ WiFi HTTP/JSON          │ REST API             │
│          ▼                   ▼                         ▼                      │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                        Home Network (WiFi)                        │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

## 🔧 System Components

### 1. Web Dashboard (Next.js)

**Location:** `frontend/`

**Features:**
- Real-time data visualization
- Interactive control interface
- Responsive design
- Multiple views (Overview, Lights, Security, History)
- Solar panel monitoring with real-time updates
- Climate data display
- RFID access control
- Relay management

**Key Files:**
- `Dashboard.js` - Main dashboard component
- `SolarPanel.js` - Real-time solar panel monitoring
- `api.js` - API service client
- `solar-panel.js` - Mock API endpoint for solar data

### 2. ESP32 Controller

**Location:** `esp32/`

**Features:**
- **6 Independent Lamp Controls** with PWM dimming
- **Sensor Monitoring**: Temperature, Humidity, Soil Moisture, Rain
- **RFID Access Control** with MFRC522
- **Relay Control** for pumps/water systems
- **Servo Motor Control** for physical devices
- **RGB LED Strip** with multiple effects
- **I2C LCD Display** for local status
- **WiFi Connectivity** with JSON API
- **Real-time Data Transmission** to server

**Key Files:**
- `main.cpp` - Complete firmware with all functionality
- `platformio.ini` - Project configuration
- `README.md` - Comprehensive documentation
- `WIRING_GUIDE.md` - Visual wiring instructions
- `LAMP_CONTROL_GUIDE.md` - Advanced lamp control
- `COMPLETE_SETUP_GUIDE.md` - Complete setup guide

### 3. Mobile Application (Flutter)

**Location:** `homesass/`

**Features:**
- **Cross-platform mobile app** for Android and Windows
- **Real-time dashboard** with all system data
- **Individual lamp control** with visual feedback
- **Solar panel monitoring** with local data
- **Climate data display** (temperature, humidity, etc.)
- **Security and relay control**
- **Settings interface** with "coming soon" notifications
- **Automatic data refresh** every 2 seconds
- **Responsive UI** with Material Design

**Key Features Implemented:**
- **API Integration**: Connects to backend at `http://192.168.100.229:8080`
- **Lamp Management**: Individual and group lamp control
- **Data Visualization**: Real-time updates from backend
- **Local Solar Data**: Solar panel uses local data instead of backend
- **User Feedback**: SnackBar notifications for settings

**Key Files:**
- `lib/main.dart` - Main application entry point
- `lib/providers/api_provider.dart` - API integration and state management
- `lib/screens/main_screen.dart` - Main navigation and screens
- `lib/widgets/lamp_control_card.dart` - Lamp control interface
- `lib/utils/constants.dart` - API endpoints and configuration
- `pubspec.yaml` - Flutter dependencies

### 4. Backend Server (Go)

**Location:** `GolandProjects/awesomeProject/`

**Features:**
- REST API for device control
- Data processing and storage
- Authentication and security
- Device state management
- Historical data logging

**Key Files:**
- `main.go` - Main server implementation
- `data.json` - Sample data structure

## 🚀 Getting Started

### Prerequisites

- **Node.js** (v18+) for frontend
- **PlatformIO** or **Arduino IDE** for ESP32
- **Go** (v1.20+) for backend
- **ESP32 Development Board**
- **Required Sensors & Components** (see ESP32 documentation)

### Installation

#### 1. Frontend Setup

```bash
cd frontend
npm install
npm run dev
```

#### 2. Mobile App Setup (Flutter)

```bash
cd homesass
flutter pub get
flutter run -d android   # For Android
flutter run -d windows   # For Windows
```

**Configuration:**
Edit `homesass/lib/utils/constants.dart` to change API endpoint:

```dart
class ApiEndpoints {
  static const String baseUrl = 'http://192.168.100.229:8080';
  // ... other endpoints
}
```

#### 3. ESP32 Setup

1. Follow wiring guide in `esp32/WIRING_GUIDE.md`
2. Configure WiFi credentials in `esp32/src/main.cpp`
3. Set server IP to match your backend
4. Upload firmware using PlatformIO/Arduino IDE

#### 4. Backend Setup

```bash
cd GolandProjects/awesomeProject
go mod download
go run main.go
```

## 📊 Features

### Real-time Monitoring
- **Solar Panel Data** - Power, voltage, current, efficiency, temperature
- **Climate Data** - Temperature, humidity, soil moisture, light levels
- **System Status** - Relay state, RFID access, security status

### Control Capabilities
- **Lamp Control** - Individual and group control with scenes
- **Relay Management** - Pump/water system control
- **RFID Access** - Secure system access
- **Servo Control** - Physical device management
- **LED Effects** - Ambient lighting control

### Advanced Features
- **Real-time Updates** - 2-second refresh for solar data
- **Data Visualization** - Charts and graphs
- **Historical Data** - Temperature history and logging
- **Responsive Design** - Works on desktop and mobile
- **Error Handling** - Comprehensive error recovery

## 🔌 System Integration

### Data Flow

1. **ESP32 collects sensor data** (temperature, humidity, soil, rain)
2. **ESP32 sends data to backend** via HTTP POST (JSON)
3. **Backend processes data** and stores historical values
4. **Web dashboard fetches data** from backend API
5. **Dashboard displays real-time data** with visualizations
6. **User commands** sent from dashboard → backend → ESP32

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/status` | GET | Get current system status |
| `/api/solar-panel` | GET | Get real-time solar panel data |
| `/api/lamp/:id/toggle` | POST | Toggle individual lamp |
| `/api/lamps/all` | POST | Control all lamps |
| `/api/toggle` | POST | Toggle main relay |
| `/api/rfid/learn` | POST | Activate RFID learn mode |
| `/api/export` | GET | Export historical data |

## 📱 User Interface

### Dashboard Views

1. **Overview** - Main status with all sensors and controls
2. **Lights** - Detailed lamp control interface
3. **Security** - RFID and system security management
4. **History** - Historical data and export

### Key UI Components

- **Real-time Solar Panel Card** - Shows fluctuating solar data
- **Climate Data Card** - Temperature, humidity, soil, light
- **Lamp Control Cards** - Individual lamp management
- **Relay Control** - Main system relay
- **RFID Management** - Access control
- **Weather Forecast** - Local weather information

## 🔧 Configuration

### ESP32 Configuration

Edit `esp32/src/main.cpp`:

```cpp
// WiFi Configuration
const char* ssid = "your-wifi-ssid";
const char* password = "your-wifi-password";
const char* serverUrl = "http://your-server-ip:8080/update";

// Lamp Pin Configuration
const int lampPins[6] = {15, 2, 0, 16, 17, 12};
```

### Frontend Configuration

Edit `frontend/services/api.js`:

```javascript
const API_BASE_URL = '/api'; // Proxy to your backend
```

### Backend Configuration

Edit `GolandProjects/awesomeProject/main.go`:

```go
// Server configuration
const (
    Port = "8080"
    // Database configuration
    // API keys
)
```

## 🚨 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **ESP32 not connecting to WiFi** | Check SSID/password, signal strength |
| **Sensors showing incorrect values** | Verify wiring, check power supply |
| **Lamps not responding** | Check GPIO connections, test with multimeter |
| **Dashboard not loading** | Check backend server, verify CORS settings |
| **Solar data not updating** | Check API endpoint, verify ESP32 connection |
| **RFID not working** | Verify SPI connections, test with known card |

### Debugging Tips

1. **Check serial monitor** for ESP32 debug output
2. **Verify network connectivity** between all components
3. **Test API endpoints** with Postman/curl
4. **Check browser console** for frontend errors
5. **Review server logs** for backend issues

## 📚 Documentation

### Comprehensive Guides

- **ESP32 Setup**: `esp32/README.md`
- **Wiring Guide**: `esp32/WIRING_GUIDE.md`
- **Lamp Control**: `esp32/LAMP_CONTROL_GUIDE.md`
- **Complete Setup**: `esp32/COMPLETE_SETUP_GUIDE.md`

### Component Documentation

- **Frontend**: Next.js with React
- **ESP32**: PlatformIO with Arduino framework
- **Backend**: Go with standard library

## 🎓 Example Usage

### Controlling Lamps (Flutter)

```dart
// Flutter API call using Provider
final apiProvider = Provider.of<ApiProvider>(context);

// Toggle individual lamp
apiProvider.toggleLamp(0, true); // Turn lamp 1 on
apiProvider.toggleLamp(1, false); // Turn lamp 2 off

// Control all lamps
apiProvider.toggleAllLamps(true); // Turn all lamps on
apiProvider.toggleAllLamps(false); // Turn all lamps off
```

### Controlling Lamps (Frontend)

```javascript
// Frontend API call
import { toggleLamp, setAllLamps } from '../services/api';

// Toggle individual lamp
await toggleLamp(1); // Toggle lamp 1

// Set all lamps
await setAllLamps(true); // Turn all lamps on
```

### Reading Sensor Data

```cpp
// ESP32 sensor reading
float temperature = dht.readTemperature();
float humidity = dht.readHumidity();
int soilMoisture = map(analogRead(SOIL_PIN), 4095, 1500, 0, 100);
```

## 🔄 Development Workflow

### Frontend Development

```bash
cd frontend
npm run dev      # Start development server
npm run build    # Build for production
npm run start    # Start production server
```

### Mobile App Development (Flutter)

```bash
cd homesass
flutter pub get          # Install dependencies
flutter run              # Run on connected device
flutter run -d android   # Run on Android emulator/device
flutter run -d windows   # Run on Windows
flutter build apk        # Build Android APK
flutter build appbundle  # Build Android App Bundle
flutter build windows    # Build Windows executable
```

### ESP32 Development

```bash
cd esp32
pio run          # Build firmware
pio run -t upload # Upload to device
pio device monitor # Serial monitor
```

### Backend Development

```bash
cd GolandProjects/awesomeProject
go run main.go   # Start server
go test ./...    # Run tests
go build         # Build binary
```

## 📋 Project Status

| Component | Status | Notes |
|-----------|--------|-------|
| Frontend Dashboard | ✅ Complete | Fully functional |
| Mobile App (Flutter) | ✅ Complete | Android & Windows support |
| ESP32 Firmware | ✅ Complete | All features implemented |
| Backend Server | ✅ Complete | Basic functionality |
| Solar Monitoring | ✅ Complete | Real-time updates |
| Lamp Control | ✅ Complete | 6 lamps with PWM |
| Documentation | ✅ Complete | Comprehensive guides |

## 🙏 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**
3. **Write clear commit messages**
4. **Update documentation**
5. **Submit pull request**

## 📋 License

This project is for **educational and personal use**. Commercial use requires additional licensing.

## 📞 Support

For support:
1. Check documentation first
2. Review troubleshooting guide
3. Consult component datasheets
4. Ask in relevant forums

## 🎯 Future Enhancements

- **Mobile App** - Native iOS/Android control
- **Voice Control** - Alexa/Google Home integration
- **Energy Monitoring** - Power consumption tracking
- **Automation Rules** - IFTTT-style automation
- **Multi-room Support** - Expanded system
- **Cloud Backup** - Data synchronization
- **AI Predictions** - Smart recommendations

This comprehensive README provides a complete overview of the smart home automation system, explaining all components, setup instructions, and usage guidelines.
