package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net"
	"net/http"
	"os"
	"strconv"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/xuri/excelize/v2"
)

type SensorData struct {
	Temp      float64   `json:"temp"`
	Hum       float64   `json:"hum"`
	Soil      int       `json:"soil"`
	Rain      bool      `json:"rain"`
	Relay     bool      `json:"relay"`
	CardUID   string    `json:"card_uid"`
	Light     int       `json:"light"`
	Lamps     []bool    `json:"lamps"`
	LampsAuto []bool    `json:"lamps_auto"`
	Time      time.Time `json:"time"`
}

type Card struct {
	UID  string `json:"uid"`
	Name string `json:"name"`
}

var (
	latestData     SensorData
	targetRelay    bool
	weatherInfo    string = "--°C"
	history        []map[string]interface{}
	lampCommands   []bool       = []bool{false, false, false, false, false, false}
	lampAutoModes  []bool       = []bool{false, false, false, false, false, false}
	lampTimers     [6]time.Time // Timers for lamps
	dataLog        []SensorData
	dataFilePath   = "data.json"
	cardsFilePath  = "cards.json"
	allowedCards   = []Card{} // List of allowed cards
	solarPanelData = map[string]interface{}{
		"power":       0.0,
		"voltage":     0.0,
		"current":     0.0,
		"efficiency":  0.0,
		"temperature": 0.0,
	}
	weatherForecast = map[string]interface{}{
		"balti": map[string]interface{}{
			"today": map[string]interface{}{
				"temp":      "--",
				"condition": "--",
				"icon":      "🌤️",
			},
			"tomorrow": map[string]interface{}{
				"temp":      "--",
				"condition": "--",
				"icon":      "🌤️",
			},
		},
		"chisinau": map[string]interface{}{
			"today": map[string]interface{}{
				"temp":      "--",
				"condition": "--",
				"icon":      "🌤️",
			},
			"tomorrow": map[string]interface{}{
				"temp":      "--",
				"condition": "--",
				"icon":      "🌤️",
			},
		},
	}
	mu sync.Mutex
)

// ---------- Cards Management ----------

func loadCards() {
	f, err := os.Open(cardsFilePath)
	if err != nil {
		if os.IsNotExist(err) {
			allowedCards = []Card{}
			return
		}
		fmt.Println("Error opening cards.json:", err)
		return
	}
	defer f.Close()
	dec := json.NewDecoder(f)
	if err := dec.Decode(&allowedCards); err != nil {
		fmt.Println("Error decoding cards.json:", err)
		allowedCards = []Card{}
	}
	fmt.Println("Loaded", len(allowedCards), "cards")
}

func saveCards() {
	f, err := os.Create(cardsFilePath)
	if err != nil {
		fmt.Println("Error creating cards.json:", err)
		return
	}
	defer f.Close()
	enc := json.NewEncoder(f)
	enc.SetIndent("", "  ")
	if err := enc.Encode(allowedCards); err != nil {
		fmt.Println("Error encoding cards.json:", err)
	}
}

// ---------- JSON лог ----------

func loadDataLog() {
	f, err := os.Open(dataFilePath)
	if err != nil {
		if os.IsNotExist(err) {
			dataLog = []SensorData{}
			return
		}
		fmt.Println("Error opening data.json:", err)
		dataLog = []SensorData{}
		return
	}
	defer f.Close()

	dec := json.NewDecoder(f)
	var arr []SensorData
	if err := dec.Decode(&arr); err != nil {
		fmt.Println("Error decoding data.json:", err)
		dataLog = []SensorData{}
		return
	}
	dataLog = arr
	fmt.Println("Loaded", len(dataLog), "records from data.json")
}

func saveDataLog() {
	f, err := os.Create(dataFilePath)
	if err != nil {
		fmt.Println("Error creating data.json:", err)
		return
	}
	defer f.Close()

	enc := json.NewEncoder(f)
	enc.SetIndent("", "  ")
	if err := enc.Encode(dataLog); err != nil {
		fmt.Println("Error encoding data.json:", err)
		return
	}
}

// -----------------------------

func checkTimers() {
	for {
		time.Sleep(1 * time.Second)
		mu.Lock()
		now := time.Now()
		for i := 0; i < 6; i++ {
			// Check if timer expired
			if !lampTimers[i].IsZero() && now.After(lampTimers[i]) {
				lampCommands[i] = false
				lampTimers[i] = time.Time{} // Reset
				fmt.Printf("Lamp %d timer expired, turning OFF\n", i+1)
			}
			// If lamp is turned off manually, cancel timer
			if !lampCommands[i] {
				lampTimers[i] = time.Time{}
			}
		}
		mu.Unlock()
	}
}

func updateWeather() {
	for {
		// Обновление текущей погоды для Кишинева
		url := fmt.Sprintf("http://api.openweathermap.org/data/2.5/weather?q=Chisinau&appid=f0c522c085058c24e9218d66508f6ca6&units=metric&lang=ru")
		resp, err := http.Get(url)
		if err == nil {
			var data map[string]interface{}
			json.NewDecoder(resp.Body).Decode(&data)
			if main, ok := data["main"].(map[string]interface{}); ok {
				mu.Lock()
				weatherInfo = fmt.Sprintf("%.1f°C", main["temp"].(float64))
				mu.Unlock()
			}
			resp.Body.Close()
		}

		// Обновление прогноза погоды для Белиц и Кишинева
		updateWeatherForecast()

		// Обновление данных солнечных панелей
		updateSolarPanelData()

		time.Sleep(15 * time.Minute)
	}
}

func updateWeatherForecast() {
	// Прогноз для Белиц
	baltiTodayTemp := 15.0 + rand.Float64()*10.0
	baltiTomorrowTemp := 14.0 + rand.Float64()*12.0

	baltiTodayCond := []string{"Солнечно", "Облачно", "Дождь", "Ясно"}[rand.Intn(4)]
	baltiTomorrowCond := []string{"Солнечно", "Облачно", "Дождь", "Ясно"}[rand.Intn(4)]

	baltiTodayIcon := "☀️"
	if baltiTodayCond == "Облачно" {
		baltiTodayIcon = "☁️"
	} else if baltiTodayCond == "Дождь" {
		baltiTodayIcon = "🌧️"
	}

	baltiTomorrowIcon := "☀️"
	if baltiTomorrowCond == "Облачно" {
		baltiTomorrowIcon = "☁️"
	} else if baltiTomorrowCond == "Дождь" {
		baltiTomorrowIcon = "🌧️"
	}

	// Прогноз для Кишинева
	chisinauTodayTemp := 18.0 + rand.Float64()*8.0
	chisinauTomorrowTemp := 17.0 + rand.Float64()*10.0

	chisinauTodayCond := []string{"Солнечно", "Облачно", "Дождь", "Ясно"}[rand.Intn(4)]
	chisinauTomorrowCond := []string{"Солнечно", "Облачно", "Дождь", "Ясно"}[rand.Intn(4)]

	chisinauTodayIcon := "☀️"
	if chisinauTodayCond == "Облачно" {
		chisinauTodayIcon = "☁️"
	} else if chisinauTodayCond == "Дождь" {
		chisinauTodayIcon = "🌧️"
	}

	chisinauTomorrowIcon := "☀️"
	if chisinauTomorrowCond == "Облачно" {
		chisinauTomorrowIcon = "☁️"
	} else if chisinauTomorrowCond == "Дождь" {
		chisinauTomorrowIcon = "🌧️"
	}

	mu.Lock()
	weatherForecast["balti"] = map[string]interface{}{
		"today": map[string]interface{}{
			"temp":      fmt.Sprintf("%.1f°C", baltiTodayTemp),
			"condition": baltiTodayCond,
			"icon":      baltiTodayIcon,
		},
		"tomorrow": map[string]interface{}{
			"temp":      fmt.Sprintf("%.1f°C", baltiTomorrowTemp),
			"condition": baltiTomorrowCond,
			"icon":      baltiTomorrowIcon,
		},
	}

	weatherForecast["chisinau"] = map[string]interface{}{
		"today": map[string]interface{}{
			"temp":      fmt.Sprintf("%.1f°C", chisinauTodayTemp),
			"condition": chisinauTodayCond,
			"icon":      chisinauTodayIcon,
		},
		"tomorrow": map[string]interface{}{
			"temp":      fmt.Sprintf("%.1f°C", chisinauTomorrowTemp),
			"condition": chisinauTomorrowCond,
			"icon":      chisinauTomorrowIcon,
		},
	}
	mu.Unlock()
}

func updateSolarPanelData() {
	// Генерируем фейковые данные для солнечных панелей
	hour := time.Now().Hour()
	var power, voltage, current, efficiency, temperature float64

	// Симуляция в зависимости от времени суток
	if hour >= 6 && hour < 18 {
		// Дневное время - высокая производительность
		power = 1500 + rand.Float64()*1000   // 1500-2500 Вт
		voltage = 24 + rand.Float64()*6      // 24-30 В
		current = 50 + rand.Float64()*20     // 50-70 А
		efficiency = 85 + rand.Float64()*10  // 85-95%
		temperature = 35 + rand.Float64()*15 // 35-50°C
	} else {
		// Ночное время - низкая производительность
		power = rand.Float64() * 100         // 0-100 Вт
		voltage = 1 + rand.Float64()*5       // 1-6 В
		current = rand.Float64() * 5         // 0-5 А
		efficiency = 10 + rand.Float64()*15  // 10-25%
		temperature = 20 + rand.Float64()*10 // 20-30°C
	}

	mu.Lock()
	solarPanelData = map[string]interface{}{
		"power":       fmt.Sprintf("%.1f Вт", power),
		"voltage":     fmt.Sprintf("%.1f В", voltage),
		"current":     fmt.Sprintf("%.1f А", current),
		"efficiency":  fmt.Sprintf("%.1f%%", efficiency),
		"temperature": fmt.Sprintf("%.1f°C", temperature),
		"timestamp":   time.Now().Format("15:04:05"),
	}
	mu.Unlock()
}

func getLocalIP() string {
	conn, err := net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		return "127.0.0.1"
	}
	defer conn.Close()

	localAddr := conn.LocalAddr().(*net.UDPAddr)
	return localAddr.IP.String()
}

func main() {
	loadDataLog()
	loadCards()
	go updateWeather()
	go checkTimers()

	r := gin.Default()
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// ESP32 -> сервер (RFID Авторизация)
	r.POST("/api/auth/card", func(c *gin.Context) {
		var req struct {
			CardUID string `json:"card_uid"`
		}
		if err := c.ShouldBindJSON(&req); err == nil {
			mu.Lock()
			fmt.Printf("RFID Access Attempt: %s\n", req.CardUID)

			// Check if card is allowed
			allowed := false
			if len(allowedCards) == 0 {
				// If no cards registered, allow all (setup mode) or you can deny.
				// Let's allow for now to easily register first card.
				allowed = true
			} else {
				for _, card := range allowedCards {
					if card.UID == req.CardUID {
						allowed = true
						break
					}
				}
			}

			if allowed {
				// 1. Включаем Лампу 1
				lampCommands[0] = true
				lampAutoModes[0] = false

				// 2. Обновляем время последнего доступа
				latestData.CardUID = req.CardUID

				mu.Unlock()
				c.JSON(200, gin.H{"status": "granted", "message": "Welcome home"})
			} else {
				mu.Unlock()
				c.JSON(403, gin.H{"status": "denied", "message": "Access denied"})
			}
		} else {
			c.JSON(400, gin.H{"error": "Invalid data"})
		}
	})

	// Security Management APIs
	r.GET("/api/security/cards", func(c *gin.Context) {
		mu.Lock()
		defer mu.Unlock()
		c.JSON(200, allowedCards)
	})

	r.POST("/api/security/cards", func(c *gin.Context) {
		var newCard Card
		if err := c.ShouldBindJSON(&newCard); err == nil {
			mu.Lock()
			// Check if exists
			exists := false
			for _, card := range allowedCards {
				if card.UID == newCard.UID {
					exists = true
					break
				}
			}
			if !exists {
				allowedCards = append(allowedCards, newCard)
				saveCards()
			}
			mu.Unlock()
			c.JSON(200, gin.H{"status": "ok"})
		} else {
			c.JSON(400, gin.H{"error": "Invalid data"})
		}
	})

	r.DELETE("/api/security/cards/:uid", func(c *gin.Context) {
		uid := c.Param("uid")
		mu.Lock()
		newCards := []Card{}
		for _, card := range allowedCards {
			if card.UID != uid {
				newCards = append(newCards, card)
			}
		}
		allowedCards = newCards
		saveCards()
		mu.Unlock()
		c.JSON(200, gin.H{"status": "ok"})
	})

	// ESP32 -> сервер
	r.POST("/update", func(c *gin.Context) {
		var newData SensorData
		if err := c.ShouldBindJSON(&newData); err == nil {
			mu.Lock()

			newData.Time = time.Now()

			fmt.Printf("Received data from ESP32: Temp=%.1f°C, Hum=%.1f%%, Relay=%v\n",
				newData.Temp, newData.Hum, newData.Relay)

			latestData = newData

			if len(history) > 50 {
				history = history[1:]
			}
			history = append(history, map[string]interface{}{"t": time.Now().Format("15:04"), "v": newData.Temp})

			dataLog = append(dataLog, newData)
			saveDataLog()

			commandRelay := targetRelay
			fmt.Printf("Sending command to ESP32: command_relay=%v\n", commandRelay)

			mu.Unlock()

			c.JSON(200, gin.H{
				"command_relay":   commandRelay,
				"lamp_commands":   lampCommands,
				"lamp_auto_modes": lampAutoModes,
				"message":         weatherInfo,
			})
		} else {
			fmt.Println("Error parsing ESP32 data:", err)
			c.JSON(400, gin.H{"error": "Invalid data format"})
		}
	})

	// состояние для веба и часов на ESP32
	r.GET("/api/status", func(c *gin.Context) {
		mu.Lock()
		defer mu.Unlock()

		clock := time.Now().Format("15:04")

		// Calculate remaining time for timers
		timers := make([]int, 6)
		now := time.Now()
		for i := 0; i < 6; i++ {
			if !lampTimers[i].IsZero() && lampTimers[i].After(now) {
				timers[i] = int(lampTimers[i].Sub(now).Seconds())
			} else {
				timers[i] = 0
			}
		}

		// Optimized response with only necessary data
		response := gin.H{
			"data":             latestData,
			"history":          history,
			"lock":             false,
			"learning":         false,
			"weather":          weatherInfo,
			"last_access":      fmt.Sprintf("Last entry: %s", latestData.CardUID), // Показываем UID последней карты
			"lamps":            lampCommands,
			"lamps_auto":       lampAutoModes,
			"timers":           timers, // NEW: Remaining time in seconds
			"clock":            clock,
			"solar_panel":      solarPanelData,
			"weather_forecast": weatherForecast,
		}

		// Add caching headers for better performance
		c.Header("Cache-Control", "public, max-age=5")
		c.JSON(200, response)
	})

	// Endpoint specifically for Solar Panel component
	r.GET("/api/solar-panel", func(c *gin.Context) {
		mu.Lock()
		defer mu.Unlock()
		c.Header("Cache-Control", "public, max-age=2")
		c.JSON(200, solarPanelData)
	})

	// --------- НОВЫЙ API ДЛЯ 2‑х ESP: /v3/time ---------
	r.GET("/v3/time", func(c *gin.Context) {
		now := time.Now()
		c.JSON(200, gin.H{
			"time": now.Format("15:04:05"), // 23:59:59
			"hm":   now.Format("15:04"),    // 23:59
			"date": now.Format("2006-01-02"),
			"ts":   now.Unix(), // Unix timestamp
		})
	})
	// ---------------------------------------------------

	r.POST("/api/lamp/:id/toggle", func(c *gin.Context) {
		id, _ := strconv.Atoi(c.Param("id"))
		if id >= 0 && id < 6 {
			mu.Lock()
			lampCommands[id] = !lampCommands[id]
			lampAutoModes[id] = false
			mu.Unlock()
			fmt.Printf("Lamp %d toggled: %v\n", id+1, lampCommands[id])
		}
		c.JSON(200, gin.H{"status": "ok"})
	})

	// New endpoint to set a timer for a lamp
	r.POST("/api/lamp/:id/timer", func(c *gin.Context) {
		id, _ := strconv.Atoi(c.Param("id"))
		var req struct {
			Minutes int `json:"minutes"`
		}
		if err := c.ShouldBindJSON(&req); err == nil && id >= 0 && id < 6 {
			mu.Lock()
			// Turn on the lamp
			lampCommands[id] = true
			lampAutoModes[id] = false
			// Set the timer
			if req.Minutes > 0 {
				lampTimers[id] = time.Now().Add(time.Duration(req.Minutes) * time.Minute)
				fmt.Printf("Lamp %d timer set for %d minutes\n", id+1, req.Minutes)
			} else {
				// If 0 or negative, just turn on without timer (or maybe cancel timer?)
				lampTimers[id] = time.Time{}
				fmt.Printf("Lamp %d turned on without timer\n", id+1)
			}
			mu.Unlock()
			c.JSON(200, gin.H{"status": "ok"})
		} else {
			c.JSON(400, gin.H{"error": "Invalid data or ID"})
		}
	})

	// New endpoint to set specific state
	r.POST("/api/lamp/:id/state", func(c *gin.Context) {
		id, _ := strconv.Atoi(c.Param("id"))
		var req struct {
			State bool `json:"state"`
		}
		if err := c.ShouldBindJSON(&req); err == nil && id >= 0 && id < 6 {
			mu.Lock()
			lampCommands[id] = req.State
			lampAutoModes[id] = false
			mu.Unlock()
			fmt.Printf("Lamp %d set to: %v\n", id+1, req.State)
			c.JSON(200, gin.H{"status": "ok"})
		} else {
			c.JSON(400, gin.H{"error": "Invalid data or ID"})
		}
	})

	r.POST("/api/lamp/:id/auto", func(c *gin.Context) {
		id, _ := strconv.Atoi(c.Param("id"))
		if id >= 0 && id < 6 {
			mu.Lock()
			lampAutoModes[id] = !lampAutoModes[id]
			mu.Unlock()
			fmt.Printf("Lamp %d auto mode: %v\n", id+1, lampAutoModes[id])
		}
		c.JSON(200, gin.H{"status": "ok"})
	})

	r.POST("/api/lamps/all", func(c *gin.Context) {
		var req struct {
			State bool `json:"state"`
		}
		if err := c.ShouldBindJSON(&req); err == nil {
			mu.Lock()
			for i := 0; i < 6; i++ {
				lampCommands[i] = req.State
				lampAutoModes[i] = false
			}
			mu.Unlock()
			fmt.Printf("All lamps set to: %v\n", req.State)
		}
		c.JSON(200, gin.H{"status": "ok"})
	})

	r.POST("/api/toggle", func(c *gin.Context) {
		mu.Lock()
		targetRelay = !targetRelay
		fmt.Printf("Relay toggle requested. New target state: %v\n", targetRelay)
		mu.Unlock()
		c.JSON(200, gin.H{"status": "ok"})
	})

	r.POST("/api/relay/on", func(c *gin.Context) {
		mu.Lock()
		targetRelay = true
		fmt.Printf("Relay ON requested. New target state: %v\n", targetRelay)
		mu.Unlock()
		c.JSON(200, gin.H{"status": "ok", "relay": "on"})
	})

	r.POST("/api/relay/off", func(c *gin.Context) {
		mu.Lock()
		targetRelay = false
		fmt.Printf("Relay OFF requested. New target state: %v\n", targetRelay)
		mu.Unlock()
		c.JSON(200, gin.H{"status": "ok", "relay": "off"})
	})

	r.GET("/api/export", func(c *gin.Context) {
		mu.Lock()
		data := history
		mu.Unlock()
		f := excelize.NewFile()
		f.SetCellValue("Sheet1", "A1", "Время")
		f.SetCellValue("Sheet1", "B1", "Температура")
		for i, v := range data {
			f.SetCellValue("Sheet1", "A"+strconv.Itoa(i+2), v["t"])
			f.SetCellValue("Sheet1", "B"+strconv.Itoa(i+2), v["v"])
		}
		c.Header("Content-Disposition", "attachment; filename=Report.xlsx")
		f.Write(c.Writer)
	})

	// LedStripState struct
	type LedStripState struct {
		State      bool `json:"state"`
		R          int  `json:"r"`
		G          int  `json:"g"`
		B          int  `json:"b"`
		Brightness int  `json:"brightness"`
	}

	var (
		// ... existing variables ...
		ledStripState = LedStripState{
			State:      true,
			R:          255,
			G:          0,
			B:          0,
			Brightness: 100,
		}
	// ...
	)

	// ...

	// Endpoint for ESP2 to get lamp commands AND sensor data
	r.GET("/api/esp2/state", func(c *gin.Context) {
		mu.Lock()
		defer mu.Unlock()
		c.JSON(200, gin.H{
			"lamp_commands": lampCommands,
			"sensors": gin.H{
				"temp": latestData.Temp,
				"hum":  latestData.Hum,
				"soil": latestData.Soil,
			},
		})
	})

	// Endpoint for ESP2 to get lamp commands
	r.GET("/api/lamps/commands", func(c *gin.Context) {
		mu.Lock()
		defer mu.Unlock()
		c.JSON(200, gin.H{
			"lamp_commands": lampCommands,
			// We can also send auto modes if ESP2 needs to know, but main logic is usually on server or app
			// For now just commands
		})
	})

	// New endpoints for LED Strip
	r.GET("/api/ledstrip/config", func(c *gin.Context) {
		mu.Lock()
		defer mu.Unlock()
		c.JSON(200, ledStripState)
	})

	r.POST("/api/ledstrip/set", func(c *gin.Context) {
		var newState LedStripState
		if err := c.ShouldBindJSON(&newState); err == nil {
			mu.Lock()
			ledStripState = newState
			fmt.Printf("LED Strip Updated: On=%v, RGB=(%d,%d,%d), Bri=%d\n",
				newState.State, newState.R, newState.G, newState.B, newState.Brightness)
			mu.Unlock()
			c.JSON(200, gin.H{"status": "ok"})
		} else {
			c.JSON(400, gin.H{"error": "Invalid data"})
		}
	})

	fmt.Printf("Server starting on %s:8080\n", getLocalIP())
	// ...
	r.Run("0.0.0.0:8080")
}
