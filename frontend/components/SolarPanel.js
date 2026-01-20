import React, { useState, useEffect } from 'react';
import { fetchSolarPanelData } from '../services/api';

const SolarPanel = () => {
  const [solarData, setSolarData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [statusHistory, setStatusHistory] = useState([]);

  const fetchSolarData = async () => {
    try {
      setLoading(true);
      const data = await fetchSolarPanelData();

      // Update status history (keep last 10 entries)
      setStatusHistory(prev => {
        const newHistory = [...prev, {
          ...data,
          timestamp: new Date().toISOString()
        }];
        return newHistory.slice(-10); // Keep only last 10 entries
      });

      setSolarData(data);
      setError(null);
    } catch (err) {
      setError(err.message || 'Failed to fetch solar panel data');
      console.error('Error fetching solar panel data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Initial fetch
    fetchSolarData();

    // Set up real-time updates every 2 seconds
    const interval = setInterval(fetchSolarData, 2000);

    return () => {
      clearInterval(interval);
    };
  }, []);

  if (loading && !solarData) {
    return (
      <div className="ha-card fade-in">
        <div className="ha-card-title">
          <span>Солнечные панели</span>
          <span className="ha-status ha-status-auto"></span>
        </div>
        <div className="ha-card-content">
          <div className="text-center py-4">
            <div className="ha-spinner"></div>
            <p className="text-secondary text-sm mt-2">Загрузка данных...</p>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="ha-card fade-in">
        <div className="ha-card-title">
          <span>Солнечные панели</span>
          <span className="ha-status ha-status-off"></span>
        </div>
        <div className="ha-card-content">
          <div className="ha-error">
            <h3 className="text-danger mb-2">Ошибка подключения</h3>
            <p className="text-secondary mb-3">{error}</p>
            <button
              onClick={fetchSolarData}
              className="ha-button ha-button-primary"
            >
              Повторить попытку
            </button>
          </div>
        </div>
      </div>
    );
  }

  if (!solarData) {
    return (
      <div className="ha-card fade-in">
        <div className="ha-card-title">
          <span>Солнечные панели</span>
          <span className="ha-status ha-status-off"></span>
        </div>
        <div className="ha-card-content">
          <p className="text-secondary">Нет данных</p>
        </div>
      </div>
    );
  }

  // Determine status color based on condition
  const getStatusColor = () => {
    if (solarData.status === 'stable') {
      return 'ha-status-on';
    } else {
      return 'ha-status-warning';
    }
  };

  return (
    <div className="ha-card fade-in">
      <div className="ha-card-title">
        <span>Солнечные панели (реальное время)</span>
        <span className={`ha-status ${getStatusColor()}`}></span>
      </div>
      <div className="ha-card-content">
        <div className="grid grid-cols-2 gap-4 mb-3">
          <div>
            <div className="ha-card-row">
              <span className="ha-card-label">Мощность</span>
              <span className="ha-card-value font-bold">{solarData.power}</span>
            </div>
            <div className="ha-card-row">
              <span className="ha-card-label">Напряжение</span>
              <span className="ha-card-value">{solarData.voltage}</span>
            </div>
          </div>
          <div>
            <div className="ha-card-row">
              <span className="ha-card-label">Ток</span>
              <span className="ha-card-value">{solarData.current}</span>
            </div>
            <div className="ha-card-row">
              <span className="ha-card-label">Эффективность</span>
              <span className="ha-card-value">{solarData.efficiency}</span>
            </div>
          </div>
        </div>
        <div className="ha-card-row">
          <span className="ha-card-label">Температура</span>
          <span className="ha-card-value">{solarData.temperature}</span>
        </div>
        <div className="ha-card-row">
          <span className="ha-card-label">Состояние</span>
          <span className="ha-card-value">
            <span className={`ha-status ${getStatusColor()}`}></span>
            {solarData.condition}
          </span>
        </div>
        <div className="ha-card-row">
          <span className="ha-card-label">Последнее обновление</span>
          <span className="ha-card-value text-sm text-secondary">{solarData.timestamp}</span>
        </div>

        {/* Real-time fluctuation indicator */}
        {statusHistory.length > 1 && (
          <div className="mt-3 pt-2 border-t border-gray-200">
            <div className="ha-card-row">
              <span className="ha-card-label">Динамика тока</span>
              <span className="ha-card-value">
                {statusHistory.map((item, index) => (
                  <span key={index} className="inline-block w-2 h-2 mx-1 rounded-full"
                        style={{
                          backgroundColor: item.status === 'stable' ? '#10b981' : '#f59e0b',
                          opacity: 1 - (index * 0.1)
                        }}
                        title={`Ток: ${item.current}, ${item.timestamp}`}>
                  </span>
                ))}
              </span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default SolarPanel;
