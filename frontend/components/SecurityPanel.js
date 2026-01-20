import React, { useState, useEffect } from 'react';
import { Icons } from './Icons';
import { fetchCards, addCard, deleteCard, fetchStatus } from '../services/api';

const SecurityPanel = () => {
  const [cards, setCards] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showAddModal, setShowAddModal] = useState(false);
  
  // Form state
  const [newCardUid, setNewCardUid] = useState('');
  const [newCardName, setNewCardName] = useState('');
  const [scanning, setScanning] = useState(false);

  const loadCards = async () => {
    try {
      setLoading(true);
      const data = await fetchCards();
      setCards(data);
      setError(null);
    } catch (err) {
      console.error('Error loading cards:', err);
      setError('Failed to load cards');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadCards();
  }, []);

  const handleAddCard = async (e) => {
    e.preventDefault();
    if (!newCardUid || !newCardName) return;

    try {
      await addCard({ uid: newCardUid, name: newCardName });
      setNewCardUid('');
      setNewCardName('');
      setShowAddModal(false);
      loadCards();
      alert('Card added successfully');
    } catch (err) {
      alert('Error adding card: ' + err.message);
    }
  };

  const handleDeleteCard = async (uid, name) => {
    if (confirm(`Are you sure you want to remove access for ${name}?`)) {
      try {
        await deleteCard(uid);
        loadCards();
      } catch (err) {
        alert('Error deleting card: ' + err.message);
      }
    }
  };

  const scanLastCard = async () => {
    setScanning(true);
    try {
      const status = await fetchStatus();
      if (status && status.last_access) {
        // Parse "Last entry: UID"
        const lastAccess = status.last_access;
        const uid = lastAccess.replace('Last entry: ', '').trim();
        
        if (uid && uid !== 'System ready') {
          setNewCardUid(uid);
        } else {
          alert('No recent card scan found. Please scan a card first.');
        }
      }
    } catch (err) {
      console.error('Scan error:', err);
    } finally {
      setScanning(false);
    }
  };

  if (loading && !cards.length) {
    return <div className="text-center py-8"><div className="ha-spinner"></div></div>;
  }

  return (
    <div className="ha-card fade-in">
      <div className="ha-card-title">
        <span>Управление доступом (RFID)</span>
        <button 
          onClick={() => setShowAddModal(true)}
          className="ha-button ha-button-primary ha-button-sm"
        >
          + Добавить карту
        </button>
      </div>
      
      <div className="ha-card-content">
        {cards.length === 0 ? (
          <div className="text-center py-8 text-secondary">
            <Icons.User />
            <p className="mt-2">Нет добавленных карт. Доступ открыт для всех (режим настройки).</p>
          </div>
        ) : (
          <div className="ha-list">
            {cards.map((card, index) => (
              <div key={index} className="ha-list-item">
                <div className="flex items-center gap-3">
                  <div className="ha-icon-circle bg-primary-soft text-primary">
                    <Icons.User />
                  </div>
                  <div>
                    <div className="font-bold">{card.name}</div>
                    <div className="text-sm text-secondary font-mono">{card.uid}</div>
                  </div>
                </div>
                <button 
                  onClick={() => handleDeleteCard(card.uid, card.name)}
                  className="ha-button-icon text-danger"
                  title="Удалить"
                >
                  <Icons.Trash />
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Modal for Adding Card */}
      {showAddModal && (
        <div className="ha-modal-overlay">
          <div className="ha-modal">
            <div className="ha-modal-header">
              <h3>Добавить карту доступа</h3>
              <button onClick={() => setShowAddModal(false)} className="ha-close-btn">&times;</button>
            </div>
            <form onSubmit={handleAddCard} className="ha-modal-body">
              <div className="ha-form-group">
                <label className="ha-form-label">UID Карты</label>
                <div className="flex gap-2">
                  <input 
                    type="text" 
                    className="ha-form-input font-mono" 
                    placeholder="E2 45 8A ..."
                    value={newCardUid}
                    onChange={(e) => setNewCardUid(e.target.value)}
                    required
                  />
                  <button 
                    type="button"
                    onClick={scanLastCard}
                    className="ha-button ha-button-secondary"
                    title="Получить последний сканированный UID"
                    disabled={scanning}
                  >
                    {scanning ? '...' : <Icons.Scan />}
                  </button>
                </div>
                <p className="ha-form-hint">Нажмите кнопку сканирования, чтобы получить UID последней приложенной карты.</p>
              </div>
              <div className="ha-form-group">
                <label className="ha-form-label">Имя владельца</label>
                <input 
                  type="text" 
                  className="ha-form-input" 
                  placeholder="Иван Иванов"
                  value={newCardName}
                  onChange={(e) => setNewCardName(e.target.value)}
                  required
                />
              </div>
              <div className="ha-modal-footer">
                <button type="button" onClick={() => setShowAddModal(false)} className="ha-button ha-button-text">Отмена</button>
                <button type="submit" className="ha-button ha-button-primary">Сохранить</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default SecurityPanel;
