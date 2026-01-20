// frontend/pages/api/alice.js
export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method Not Allowed' });
  }

  const { request, session, version } = req.body;
  const command = request.command.toLowerCase();
  
  // Адрес вашего GO-сервера
  const GO_SERVER_URL = 'http://192.168.50.9:8080';

  console.log(`[Alice] Получена команда: "${command}"`);

  let responseText = 'Я вас не поняла. Скажите "включи свет" или "статус".';
  let endSession = false;

  try {
    // 1. Приветствие
    if (request.original_utterance === '' || command === 'помощь') {
      responseText = 'Привет! Я управляю вашим умным домом.';
    } 
    
    // 2. Включить свет (ВСЕ лампы)
    else if (command.includes('включи свет') || command.includes('зажги свет')) {
      console.log(`[Alice] Включаю ВСЕ лампы через Go-сервер...`);
      
      const resp = await fetch(`${GO_SERVER_URL}/api/lamps/all`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ state: true }) // true = включить
      });

      if (resp.ok) {
         responseText = 'Хорошо, включаю освещение.';
      } else {
         responseText = 'Сервер умного дома вернул ошибку.';
         console.error(`[Alice] Ошибка Go-сервера: ${resp.status}`);
      }
      endSession = true;
    }

    // 3. Выключить свет
    else if (command.includes('выключи свет') || command.includes('погаси свет')) {
      console.log(`[Alice] Выключаю ВСЕ лампы...`);
      
      const resp = await fetch(`${GO_SERVER_URL}/api/lamps/all`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ state: false }) // false = выключить
      });

      if (resp.ok) {
        responseText = 'Выключила свет.';
      } else {
        responseText = 'Ошибка связи с сервером.';
      }
      endSession = true;
    }

    // 4. Управление Кондиционером (Реле)
    else if (command.includes('кондиционер') || command.includes('реле')) {
        let action = '/api/toggle'; // По умолчанию переключаем
        let text = 'Переключила кондиционер.';

        if (command.includes('включи')) {
            action = '/api/relay/on';
            text = 'Включила кондиционер.';
        } else if (command.includes('выключи')) {
            action = '/api/relay/off';
            text = 'Выключила кондиционер.';
        }

        const resp = await fetch(`${GO_SERVER_URL}${action}`, { method: 'POST' });
        if (resp.ok) responseText = text;
        else responseText = 'Не удалось управлять реле.';
        
        endSession = true;
    }

    // 5. Статус / Погода
    else if (command.includes('статус') || command.includes('погода')) {
      console.log(`[Alice] Запрашиваю статус...`);
      const resp = await fetch(`${GO_SERVER_URL}/api/status`);
      
      if (resp.ok) {
        const json = await resp.json();
        // В Go-сервере структура: { "data": { "temp": 25.5, ... } }
        const temp = json.data?.temp?.toFixed(1) || '?';
        const hum = json.data?.hum?.toFixed(0) || '?';
        responseText = `В доме ${temp} градусов, влажность ${hum} процентов.`;
      } else {
        responseText = 'Ошибка получения данных.';
      }
      endSession = true;
    }

  } catch (error) {
    console.error('[Alice] Critical Error:', error.message);
    responseText = 'Нет связи с сервером умного дома (Go). Проверьте, запущен ли он.';
  }

  res.status(200).json({
    version,
    session,
    response: {
      text: responseText,
      end_session: endSession,
    },
  });
}
