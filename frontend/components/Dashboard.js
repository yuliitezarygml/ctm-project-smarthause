/**
 * Упрощенный компонент дашборда для умного дома
 * Управление реле и 6 светодиодами
 */
import React, { useState, useEffect } from 'react';
import SolarPanel from './SolarPanel';
import SecurityPanel from './SecurityPanel';
import { Icons } from './Icons';
import {
  fetchStatus,
  fetchSolarPanelData,
  toggleRelay,
  toggleLamp,
  setLampState,
  setLampTimer,
  setAllLamps
} from '../services/api';

const Dashboard = () => {
  const [status, setStatus] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeNav, setActiveNav] = useState('overview');
  const [isToggling, setIsToggling] = useState(false);
  const [ledToggling, setLedToggling] = useState(Array(6).fill(false));
  const [apiUrl, setApiUrl] = useState('http://192.168.50.9:8080');

  // Timer Modal State
  const [showTimerModal, setShowTimerModal] = useState(false);
  const [timerTargetIds, setTimerTargetIds] = useState([]);
  const [timerMinutes, setTimerMinutes] = useState(5);

  // Helper to format seconds to MM:SS
  const formatTimer = (seconds) => {
    if (!seconds || seconds <= 0) return null;
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${m}:${s.toString().padStart(2, '0')}`;
  };

  // Optimization: Use separate function for polling to avoid useEffect dependency loops
  const fetchData = async (background = false) => {
    try {
      if (!background) setLoading(true); // Only show spinner on initial load or manual refresh
      const data = await fetchStatus();
      setStatus(data);
      setError(null);
    } catch (err) {
      console.error('Error fetching status:', err);
      // Only set error if we don't have stale data
      if (!status) {
        setError(err.message || 'Failed to fetch data');
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Initial fetch
    fetchData(false);

    // Polling interval (5 seconds)
    const interval = setInterval(() => fetchData(true), 2000); // Faster polling for better sync

    return () => clearInterval(interval);
  }, []);

  const handleRelayToggle = async () => {
    try {
      setIsToggling(true);
      
      // Optimistic update
      const newRelayState = !status?.data?.relay;
      setStatus(prev => ({
        ...prev,
        data: { ...prev.data, relay: newRelayState }
      }));

      await toggleRelay();
      // No need to fetch immediately, polling will catch it, or we can fetch in background
      fetchData(true);
    } catch (err) {
      console.error('Error toggling relay:', err);
      // Revert optimistic update on error
      fetchData(true);
    } finally {
      setIsToggling(false);
    }
  };

  const handleLampToggle = async (id) => {
    // Legacy toggle support if needed, but we prefer setLampState now
    try {
        const newLedToggling = [...ledToggling];
        newLedToggling[id] = true;
        setLedToggling(newLedToggling);

        await toggleLamp(id);
        fetchData(true);
    } catch (err) {
        console.error(`Error toggling lamp ${id}:`, err);
    } finally {
        const newLedToggling = [...ledToggling];
        newLedToggling[id] = false;
        setLedToggling(newLedToggling);
    }
  };

  // Improved handler for group switching
  const handleGroupSwitch = async (lampIndices, currentState) => {
      const newState = !currentState;
      
      // 1. Optimistic UI Update immediately
      // Update local state so UI reacts instantly without waiting for network
      setStatus(prev => {
          if (!prev || !prev.lamps) return prev;
          const newLamps = [...prev.lamps];
          lampIndices.forEach(idx => {
              newLamps[idx] = newState;
          });
          return {
              ...prev,
              lamps: newLamps,
              data: { ...prev.data, lamps: newLamps } // Sync both if structure differs
          };
      });

      // 2. Send API requests in parallel
      try {
          const promises = lampIndices.map(id => setLampState(id, newState));
          await Promise.all(promises);
      } catch (err) {
          console.error("Error syncing lamps:", err);
          // Revert or re-fetch on error
          fetchData(true);
      }
  };

  const handleAllLamps = async (state) => {
    try {
      setIsToggling(true);
      
      // Optimistic
      setStatus(prev => {
         if (!prev || !prev.lamps) return prev;
         const newLamps = prev.lamps.map(() => state);
         return {
             ...prev,
             lamps: newLamps,
             data: { ...prev.data, lamps: newLamps }
         };
      });

      await setAllLamps(state);
      fetchData(true);
    } catch (err) {
      console.error('Error setting all lamps:', err);
      fetchData(true);
    } finally {
      setIsToggling(false);
    }
  };

  const openTimerModal = (ids) => {
    setTimerTargetIds(ids);
    setTimerMinutes(5); // Reset to default
    setShowTimerModal(true);
  };

  const submitTimer = async () => {
      setShowTimerModal(false);
      try {
          // Optimistic update (turn on)
          setStatus(prev => {
              if (!prev || !prev.lamps) return prev;
              const newLamps = [...prev.lamps];
              timerTargetIds.forEach(id => {
                  newLamps[id] = true;
              });
              return {
                  ...prev,
                  lamps: newLamps,
                  data: { ...prev.data, lamps: newLamps }
              };
          });

          // Send requests
          const promises = timerTargetIds.map(id => setLampTimer(id, parseInt(timerMinutes)));
          await Promise.all(promises);
          
          alert(`Таймер установлен на ${timerMinutes} мин`);
          fetchData(true);
      } catch (err) {
          console.error("Error setting timer:", err);
          alert("Ошибка установки таймера");
      }
  };

  const handleApiUrlChange = (e) => {
    setApiUrl(e.target.value);
    localStorage.setItem('apiUrl', e.target.value);
  };

  const getCalculatedLight = () => {
    if (!status?.data) return '--';
    const baseLight = status.data.light || 0;
    const activeLamps = status.lamps ? status.lamps.filter(l => l).length : 0;
    // Increase by 50% depending on how many lamps are turned on (assuming 6 lamps max)
    const totalLamps = 6;
    const additionalLight = (activeLamps / totalLamps) * 50;
    return Math.round(baseLight + additionalLight);
  };

  if (loading && !status) {
    return (
      <div className="ha-loading">
        <div className="ha-spinner"></div>
      </div>
    );
  }

  if (error && !status) {
    return (
      <div className="ha-container">
        <div className="ha-main">
          <div className="ha-error">
            <h2 className="text-danger mb-2">Ошибка подключения</h2>
            <p className="text-secondary mb-4">{error}</p>
            <button
              onClick={() => { setLoading(true); fetchData(); }}
              className="ha-button ha-button-primary"
            >
              Повторить попытку
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="ha-container">
      {/* Боковая панель */}
      <div className="ha-sidebar">
        <div className="ha-logo">
          <div className="ha-logo-icon"><Icons.Home /></div>
          <div className="ha-logo-text">Smart Home</div>
        </div>

        <div className="ha-nav">
          <div
            className={`ha-nav-item ${activeNav === 'overview' ? 'active' : ''}`}
            onClick={() => setActiveNav('overview')}
          >
            <div className="ha-nav-icon"><Icons.Dashboard /></div>
            <span>Обзор</span>
          </div>
          <div
            className={`ha-nav-item ${activeNav === 'leds' ? 'active' : ''}`}
            onClick={() => setActiveNav('leds')}
          >
            <div className="ha-nav-icon"><Icons.Lightbulb /></div>
            <span>Свет</span>
          </div>
          <div
            className={`ha-nav-item ${activeNav === 'security' ? 'active' : ''}`}
            onClick={() => setActiveNav('security')}
          >
            <div className="ha-nav-icon"><Icons.User /></div>
            <span>Безопасность</span>
          </div>
          <div
            className={`ha-nav-item ${activeNav === 'settings' ? 'active' : ''}`}
            onClick={() => setActiveNav('settings')}
          >
            <div className="ha-nav-icon"><Icons.Settings /></div>
            <span>Настройки</span>
          </div>
          <div
            className={`ha-nav-item ${activeNav === 'about' ? 'active' : ''}`}
            onClick={() => setActiveNav('about')}
          >
            <div className="ha-nav-icon"><Icons.Info /></div>
            <span>О системе</span>
          </div>
        </div>

        <div className="ha-footer">
          <span className="text-secondary text-sm">Updated: {status?.clock}</span>
        </div>
      </div>

      {/* Основной контент */}
      <div className="ha-main">
        <div className="ha-header">
          <div>
            <h1 className="ha-title">
              {activeNav === 'overview' && 'Панель управления'}
              {activeNav === 'leds' && 'Управление светом'}
              {activeNav === 'settings' && 'Настройки'}
              {activeNav === 'about' && 'О системе'}
            </h1>
            <p className="ha-subtitle">
              {activeNav === 'overview' && 'Мониторинг сенсоров и управление устройствами'}
              {activeNav === 'leds' && 'Контроль светодиодных модулей'}
              {activeNav === 'settings' && 'Конфигурация подключения'}
              {activeNav === 'about' && 'Информация о разработчике'}
            </p>
          </div>
          {activeNav === 'overview' && (
            <div className="ha-status-indicator">
              <span className={`ha-status ${status?.data?.relay ? 'ha-status-on' : 'ha-status-off'}`}></span>
              <span className="text-secondary text-sm">{status?.data?.relay ? 'System Active' : 'System Idle'}</span>
            </div>
          )}
        </div>

        {/* Обзор */}
        {activeNav === 'overview' && (
          <div className="ha-grid-container fade-in">
            <div className="ha-grid">
              {/* Карточка погоды */}
              <div className="ha-card">
                <div className="ha-card-title">
                  <span>Погода</span>
                  <Icons.Sun />
                </div>
                <div className="ha-card-content">
                  <div className="flex items-end gap-2">
                    <div className="text-3xl font-bold text-primary">{status?.weather}</div>
                    <div className="text-secondary text-sm mb-1">Кишинев</div>
                  </div>
                  <div className="text-secondary text-sm mt-2">
                    Влажность: {status?.data?.hum}%
                  </div>
                </div>
              </div>

              {/* Карточка климатических данных */}
              <div className="ha-card ha-card-climate">
                <div className="ha-card-title">
                  <span>Климат</span>
                  <Icons.Thermometer />
                </div>
                <div className="ha-card-content">
                  <div className="grid grid-cols-2 gap-4">
                      <div className="climate-item">
                        <div className="ha-card-row">
                          <span className="ha-card-label flex gap-2 items-center"><Icons.Thermometer size={16}/> Темп.</span>
                          <span className="ha-card-value text-xl">{status?.data?.temp !== undefined ? status.data.temp.toFixed(2) : '--'}°C</span>
                        </div>
                        <div className="ha-card-row text-sm">
                          <span className="ha-card-label flex gap-2 items-center"><Icons.Droplet size={16}/> Влажность</span>
                          <span className="ha-card-value">{status?.data?.hum !== undefined ? status.data.hum.toFixed(1) : '--'}%</span>
                        </div>
                      </div>
                    <div className="climate-item">
                      <div className="ha-card-row">
                        <span className="ha-card-label flex gap-2 items-center"><Icons.Leaf size={16}/> Почва</span>
                        <span className="ha-card-value text-xl">{status?.data?.soil}%</span>
                      </div>
                      <div className="ha-card-row text-sm">
                        <span className="ha-card-label flex gap-2 items-center"><Icons.Sun size={16}/> Свет</span>
                        <span className="ha-card-value">{getCalculatedLight()}%</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Карточка безопасности (RFID) */}
              <div className="mt-6">
                 <SecurityPanel />
              </div>

              {/* Карточка реле */}
              <div className="ha-card">
                <div className="ha-card-title">
                  <span>Кондиционер</span>
                  <Icons.Zap />
                </div>
                <div className="ha-card-content">
                  <div className="ha-entity">
                    <div className="ha-entity-info">
                      <div className={`ha-entity-icon ${status?.data?.relay ? 'bg-success' : 'bg-secondary'}`}>
                        <Icons.Zap />
                      </div>
                      <div>
                        <div className="ha-entity-name">Кондиционер</div>
                        <div className="ha-entity-state">{status?.data?.relay ? 'Включено' : 'Выключено'}</div>
                      </div>
                    </div>
                    <div className="ha-entity-controls">
                      <button
                        onClick={handleRelayToggle}
                        className={`ha-button ${status?.data?.relay ? 'ha-button-danger' : 'ha-button-success'} ${isToggling ? 'ha-button-loading' : ''}`}
                        disabled={isToggling}
                      >
                        {isToggling ? '...' : (status?.data?.relay ? 'ВЫКЛ' : 'ВКЛ')}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

             {/* Карточка солнечных панелей */}
             <div className="mt-6">
                <SolarPanel />
             </div>

            {/* Прогноз погоды - Красивая Горизонтальная Карточка */}
            <div className="weather-normal-container fade-in">
              {/* Кишинев */}
              <div className="weather-day-normal">
                <h3 className="weather-city-title">Кишинев</h3>
                <div className="flex flex-col items-center">
                   <div className="weather-icon-large">{status?.weather_forecast?.chisinau?.today?.icon}</div>
                   <div className="weather-temp-large">{status?.weather_forecast?.chisinau?.today?.temp}</div>
                   <div className="weather-condition">{status?.weather_forecast?.chisinau?.today?.condition}</div>
                   <div className="weather-day-label">Сегодня</div>
                </div>
              </div>

               {/* Бельцы */}
              {/* Давайте сделаем прогноз на завтра для Кишинева вторым блоком для симметрии, как на макетах */}
              <div className="weather-day-normal">
                <h3 className="weather-city-title">Завтра</h3>
                <div className="flex flex-col items-center">
                   <div className="weather-icon-large">{status?.weather_forecast?.chisinau?.tomorrow?.icon}</div>
                   <div className="weather-temp-large">{status?.weather_forecast?.chisinau?.tomorrow?.temp}</div>
                   <div className="weather-condition">{status?.weather_forecast?.chisinau?.tomorrow?.condition}</div>
                   <div className="weather-day-label">Кишинев</div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Управление светодиодами */}
        {activeNav === 'leds' && (
          <div className="ha-card fade-in">
            <div className="ha-card-title">Управление светом</div>
            <div className="ha-card-content">
              <div className="ha-grid">
                
                {/* Дом (Лампы 1 и 2) */}
                <div className="ha-card-inner">
                   <div className="ha-entity">
                      <div className="ha-entity-info">
                        <div className={`ha-entity-icon ${status?.lamps && (status.lamps[0] || status.lamps[1]) ? 'bg-warning' : 'bg-secondary'}`}>
                          <Icons.Home />
                        </div>
                        <div>
                          <div className="ha-entity-name">Дом</div>
                          <div className="ha-entity-state">{status?.lamps && (status.lamps[0] || status.lamps[1]) ? 'Включено' : 'Выключено'}</div>
                        </div>
                      </div>
                      <div className="ha-entity-controls">
                        {status?.timers && (status.timers[0] > 0 || status.timers[1] > 0) && (
                            <span className="ha-timer-badge">
                                {formatTimer(Math.max(status.timers[0], status.timers[1]))}
                            </span>
                        )}
                        <button className="ha-icon-button" style={{marginRight: '12px'}} onClick={() => openTimerModal([0, 1])} title="Таймер">
                            <Icons.Clock size={24} />
                        </button>
                        <label className="ha-switch">
                            <input 
                                type="checkbox" 
                                checked={!!(status?.lamps && (status.lamps[0] || status.lamps[1]))} 
                                onChange={() => handleGroupSwitch([0, 1], !!(status?.lamps && (status.lamps[0] || status.lamps[1])))}
                                disabled={isToggling}
                            />
                            <span className="ha-slider"></span>
                        </label>
                      </div>
                   </div>
                </div>

                {/* Гараж (Лампы 3 и 4) */}
                <div className="ha-card-inner">
                   <div className="ha-entity">
                      <div className="ha-entity-info">
                        <div className={`ha-entity-icon ${status?.lamps && (status.lamps[2] || status.lamps[3]) ? 'bg-warning' : 'bg-secondary'}`}>
                          <Icons.Activity /> 
                        </div>
                        <div>
                          <div className="ha-entity-name">Гараж</div>
                          <div className="ha-entity-state">{status?.lamps && (status.lamps[2] || status.lamps[3]) ? 'Включено' : 'Выключено'}</div>
                        </div>
                      </div>
                      <div className="ha-entity-controls">
                        {status?.timers && (status.timers[2] > 0 || status.timers[3] > 0) && (
                            <span className="ha-timer-badge">
                                {formatTimer(Math.max(status.timers[2], status.timers[3]))}
                            </span>
                        )}
                        <button className="ha-icon-button" style={{marginRight: '12px'}} onClick={() => openTimerModal([2, 3])} title="Таймер">
                            <Icons.Clock size={24} />
                        </button>
                        <label className="ha-switch">
                            <input 
                                type="checkbox" 
                                checked={!!(status?.lamps && (status.lamps[2] || status.lamps[3]))} 
                                onChange={() => handleGroupSwitch([2, 3], !!(status?.lamps && (status.lamps[2] || status.lamps[3])))}
                                disabled={isToggling}
                            />
                            <span className="ha-slider"></span>
                        </label>
                      </div>
                   </div>
                </div>

                {/* Дом 2 (Лампа 5) */}
                <div className="ha-card-inner">
                   <div className="ha-entity">
                      <div className="ha-entity-info">
                        <div className={`ha-entity-icon ${status?.lamps && status.lamps[4] ? 'bg-warning' : 'bg-secondary'}`}>
                          <Icons.Home />
                        </div>
                        <div>
                          <div className="ha-entity-name">Дом 2</div>
                          <div className="ha-entity-state">{status?.lamps && status.lamps[4] ? 'Включено' : 'Выключено'}</div>
                        </div>
                      </div>
                      <div className="ha-entity-controls">
                        {status?.timers && status.timers[4] > 0 && (
                            <span className="ha-timer-badge">
                                {formatTimer(status.timers[4])}
                            </span>
                        )}
                        <button className="ha-icon-button" style={{marginRight: '12px'}} onClick={() => openTimerModal([4])} title="Таймер">
                            <Icons.Clock size={24} />
                        </button>
                        <label className="ha-switch">
                            <input 
                                type="checkbox" 
                                checked={!!(status?.lamps && status.lamps[4])} 
                                onChange={() => handleGroupSwitch([4], !!(status?.lamps && status.lamps[4]))}
                                disabled={isToggling}
                            />
                            <span className="ha-slider"></span>
                        </label>
                      </div>
                   </div>
                </div>

                {/* Двор (Лампа 6) */}
                <div className="ha-card-inner">
                   <div className="ha-entity">
                      <div className="ha-entity-info">
                        <div className={`ha-entity-icon ${status?.lamps && status.lamps[5] ? 'bg-warning' : 'bg-secondary'}`}>
                          <Icons.Sun />
                        </div>
                        <div>
                          <div className="ha-entity-name">Двор</div>
                          <div className="ha-entity-state">{status?.lamps && status.lamps[5] ? 'Включено' : 'Выключено'}</div>
                        </div>
                      </div>
                      <div className="ha-entity-controls">
                        {status?.timers && status.timers[5] > 0 && (
                            <span className="ha-timer-badge">
                                {formatTimer(status.timers[5])}
                            </span>
                        )}
                        <button className="ha-icon-button" style={{marginRight: '12px'}} onClick={() => openTimerModal([5])} title="Таймер">
                            <Icons.Clock size={24} />
                        </button>
                        <label className="ha-switch">
                            <input 
                                type="checkbox" 
                                checked={!!(status?.lamps && status.lamps[5])} 
                                onChange={() => handleGroupSwitch([5], !!(status?.lamps && status.lamps[5]))}
                                disabled={isToggling}
                            />
                            <span className="ha-slider"></span>
                        </label>
                      </div>
                   </div>
                </div>

              </div>
              <div className="flex gap-4 mt-6">
                <button
                  onClick={() => handleAllLamps(true)}
                  className="ha-button ha-button-success flex-1"
                  disabled={isToggling}
                >
                  Включить все
                </button>
                <button
                  onClick={() => handleAllLamps(false)}
                  className="ha-button ha-button-danger flex-1"
                  disabled={isToggling}
                >
                  Выключить все
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Секция безопасности */}
        {activeNav === 'security' && (
          <SecurityPanel />
        )}

        {/* Страница "Обо мне" */}
        {activeNav === 'about' && (
          <div className="ha-card fade-in">
            <div className="ha-card-title">Разработчик</div>
            <div className="ha-card-content">
              <div className="ha-about-content">
                <div className="ha-about-header">
                  <div className="ha-about-avatar">👨💻</div>
                  <div>
                    <h2 className="ha-about-name">Terentii Iulian</h2>
                    <p className="ha-about-title">Full-Stack Developer</p>
                  </div>
                </div>

                <div className="ha-about-section">
                  <h3 className="ha-about-section-title">Обо мне</h3>
                  <p className="ha-about-text">
                    Я опытный разработчик с более чем 5-летним опытом в создании веб и мобильных приложений.
                    Специализируюсь на разработке полного цикла, от бэкенда до фронтенда и мобильных приложений.
                  </p>
                </div>

                <div className="ha-about-section">
                   <h3 className="ha-about-section-title">Навыки</h3>
                    <div className="ha-skills-grid">
                    {['JavaScript', 'TypeScript', 'React', 'Node.js', 'Go', 'Flutter', 'Dart', 'Python', 'ESP32', 'IoT'].map(skill => (
                        <span key={skill} className="ha-skill-tag">{skill}</span>
                    ))}
                    </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Страница "Настройки" */}
        {activeNav === 'settings' && (
          <div className="ha-card fade-in">
            <div className="ha-card-title">Конфигурация</div>
            <div className="ha-card-content">
              <div className="ha-settings-content">
                <div className="ha-settings-section">
                  <h3 className="ha-settings-section-title">Подключение</h3>
                  <div className="ha-settings-form">
                    <div className="ha-form-group">
                      <label htmlFor="apiUrl" className="ha-form-label">API URL</label>
                      <input
                        type="text"
                        id="apiUrl"
                        className="ha-form-input"
                        value={apiUrl}
                        onChange={handleApiUrlChange}
                        placeholder="http://192.168.x.x:8080"
                      />
                      <p className="ha-form-hint">Текущий: {apiUrl}</p>
                    </div>
                    <button
                      onClick={() => {
                        localStorage.setItem('apiUrl', apiUrl);
                        alert('Настройки сохранены!');
                        window.location.reload();
                      }}
                      className="ha-button ha-button-primary"
                    >
                      Сохранить и перезагрузить
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Modal Timer */}
        {showTimerModal && (
          <div className="ha-modal-overlay" onClick={() => setShowTimerModal(false)}>
            <div className="ha-modal" onClick={e => e.stopPropagation()}>
              <h3 className="ha-modal-title">Таймер отключения</h3>
              <div className="ha-form-group">
                  <label className="ha-form-label">Время (минуты)</label>
                  <input 
                      type="number" 
                      min="1" 
                      max="1440"
                      className="ha-form-input" 
                      value={timerMinutes} 
                      onChange={e => setTimerMinutes(e.target.value)}
                  />
                  <p className="ha-form-hint">Свет выключится автоматически через указанное время.</p>
              </div>
              <div className="ha-modal-actions">
                  <button className="ha-button ha-button-secondary" onClick={() => setShowTimerModal(false)}>Отмена</button>
                  <button className="ha-button ha-button-primary" onClick={submitTimer}>Запустить</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard;
