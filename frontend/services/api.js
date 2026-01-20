/**
 * Сервис для работы с API бэкенда
 */

const DEFAULT_API_URL = 'http://192.168.50.9:8080';

const getBaseUrl = () => {
  if (typeof window !== 'undefined') {
    const storedUrl = localStorage.getItem('apiUrl');
    if (storedUrl) {
      // Remove trailing slash
      return storedUrl.endsWith('/') ? storedUrl.slice(0, -1) : storedUrl;
    }
  }
  return DEFAULT_API_URL;
};

// Helper function to handle API requests
async function makeApiRequest(endpoint, options = {}) {
  const baseUrl = getBaseUrl();
  const url = `${baseUrl}${endpoint}`;

  try {
    const response = await fetch(url, options);
    if (response.ok) {
      return response;
    }
    throw new Error(`Request failed with status: ${response.status}`);
  } catch (error) {
    console.error(`API request failed for ${url}:`, error);
    throw error;
  }
}

export const fetchStatus = async () => {
  try {
    const response = await makeApiRequest('/api/status');
    return response.json();
  } catch (error) {
    console.error('API Error:', error);
    // Return mock data when API is unavailable for better UX
    return {
      data: {
        temp: 22.5,
        hum: 45.0,
        relay: false,
        lamps: [false, false, false, false, false, false],
        lamps_auto: [true, true, true, true, true, true],
        timers: [0, 0, 0, 0, 0, 0], // Mock timers
        soil: 0,
        light: 0
      },
      history: [],
      lock: false,
      learning: false,
      weather: "22.5°C",
      last_access: "System ready",
      timers: [0, 0, 0, 0, 0, 0], // Top level mock timers
      clock: new Date().toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' }),
      solar_panel: {
        power: "250 W",
        voltage: "12.5 V",
        current: "2.0 A",
        efficiency: "85%",
        temperature: "25°C",
        status: "stable",
        condition: "Sunny"
      },
      weather_forecast: {
        balti: {
          today: { temp: "22.5°C", condition: "Sunny", icon: "☀️" },
          tomorrow: { temp: "23.1°C", condition: "Sunny", icon: "☀️" }
        },
        chisinau: {
          today: { temp: "23.0°C", condition: "Sunny", icon: "☀️" },
          tomorrow: { temp: "24.0°C", condition: "Sunny", icon: "☀️" }
        }
      }
    };
  }
};

export const fetchTime = async () => {
  try {
    const response = await makeApiRequest('/v3/time');
    return response.json();
  } catch (error) {
    throw new Error('Failed to fetch time');
  }
};

export const toggleLamp = async (id) => {
  try {
    const response = await makeApiRequest(`/api/lamp/${id}/toggle`, {
      method: 'POST',
    });
    return response.json();
  } catch (error) {
    throw new Error('Failed to toggle lamp');
  }
};

export const setLampState = async (id, state) => {
  try {
    const response = await makeApiRequest(`/api/lamp/${id}/state`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ state }),
    });
    return response.json();
  } catch (error) {
    throw new Error('Failed to set lamp state');
  }
};

export const setLampTimer = async (id, minutes) => {
  try {
    const response = await makeApiRequest(`/api/lamp/${id}/timer`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ minutes }),
    });
    return response.json();
  } catch (error) {
    throw new Error('Failed to set lamp timer');
  }
};

export const toggleLampAuto = async (id) => {
  try {
    const response = await makeApiRequest(`/api/lamp/${id}/auto`, {
      method: 'POST',
    });
    return response.json();
  } catch (error) {
    throw new Error('Failed to toggle lamp auto mode');
  }
};

export const setAllLamps = async (state) => {
  try {
    const response = await makeApiRequest('/api/lamps/all', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ state }),
    });
    return response.json();
  } catch (error) {
    throw new Error('Failed to set all lamps');
  }
};

export const toggleRelay = async () => {
  try {
    const response = await makeApiRequest('/api/toggle', {
      method: 'POST',
    });
    return response.json();
  } catch (error) {
    throw new Error('Failed to toggle relay');
  }
};

export const exportData = async () => {
  try {
    const response = await makeApiRequest('/api/export');
    const blob = await response.blob();
    const filename = response.headers.get('Content-Disposition')?.split('filename=')[1] || 'Report.xlsx';

    return {
      blob,
      filename
    };
  } catch (error) {
    throw new Error('Failed to export data');
  }
};

export const fetchSolarPanelData = async () => {
  try {
    const response = await makeApiRequest('/api/solar-panel');
    return response.json();
  } catch (error) {
    throw new Error('Failed to fetch solar panel data');
  }
};

export const fetchCards = async () => {
  try {
    const response = await makeApiRequest('/api/security/cards');
    return response.json();
  } catch (error) {
    throw new Error('Failed to fetch cards');
  }
};

export const addCard = async (card) => {
  try {
    const response = await makeApiRequest('/api/security/cards', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(card),
    });
    return response.json();
  } catch (error) {
    throw new Error('Failed to add card');
  }
};

export const deleteCard = async (uid) => {
  try {
    const response = await makeApiRequest(`/api/security/cards/${uid}`, {
      method: 'DELETE',
    });
    return response.json();
  } catch (error) {
    throw new Error('Failed to delete card');
  }
};
