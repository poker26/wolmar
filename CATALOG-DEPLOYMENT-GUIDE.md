# Руководство по развертыванию каталога монет

## Обзор
Каталог монет - это отдельная система для создания и просмотра каталога монет на основе данных аукционов. Система состоит из:
- **Парсера каталога** (`catalog-parser.js`) - извлекает данные о монетах из аукционов
- **Веб-сервера каталога** (`catalog-server.js`) - предоставляет API и веб-интерфейс
- **Веб-интерфейса** (`catalog-public/`) - пользовательский интерфейс для просмотра каталога

## Архитектура
- **Основной сайт**: http://server:3001 (аукционы, парсеры)
- **Каталог монет**: http://server:3000 (каталог монет)
- **База данных**: PostgreSQL (общая для обеих систем)

## Развертывание на сервере

### 1. Подготовка локально
```bash
# Остановите парсер каталога
taskkill /F /IM node.exe

# Зафиксируйте изменения
git add catalog-parser.js catalog-server.js catalog-monitor.js catalog-public/ catalog-progress.json
git commit -m "Обновление каталога монет с улучшенным парсингом веса и пробы"

# Отправьте на сервер
git push origin catalog-parser
```

### 2. Настройка на сервере
```bash
# Подключитесь к серверу
ssh root@server

# Перейдите в директорию проекта
cd /var/www/wolmar-parser

# Получите последние изменения
git pull origin catalog-parser

# Установите зависимости (если нужно)
npm install

# Остановите существующие процессы
pm2 stop catalog-parser 2>/dev/null || true
pm2 stop catalog-server 2>/dev/null || true

# Запустите парсер каталога
pm2 start catalog-parser.js --name catalog-parser

# Запустите веб-сервер каталога
pm2 start catalog-server.js --name catalog-server

# Сохраните конфигурацию PM2
pm2 save
```

### 3. Автоматическое развертывание
Используйте скрипт `setup-catalog-on-server.sh`:
```bash
chmod +x setup-catalog-on-server.sh
./setup-catalog-on-server.sh
```

## Мониторинг

### Проверка статуса
```bash
pm2 status
pm2 logs catalog-parser
pm2 logs catalog-server
```

### Перезапуск сервисов
```bash
pm2 restart catalog-parser
pm2 restart catalog-server
```

### Остановка сервисов
```bash
pm2 stop catalog-parser
pm2 stop catalog-server
```

## Структура файлов

### Основные файлы
- `catalog-parser.js` - парсер каталога монет
- `catalog-server.js` - веб-сервер каталога (порт 3000)
- `catalog-monitor.js` - мониторинг прогресса парсера
- `catalog-progress.json` - файл прогресса парсера

### Веб-интерфейс
- `catalog-public/index.html` - главная страница каталога
- `catalog-public/app.js` - JavaScript логика
- `catalog-public/style.css` - стили

### Конфигурация
- `config.js` - настройки базы данных
- `package.json` - зависимости Node.js

## API каталога

### Основные эндпоинты
- `GET /api/catalog/coins` - получить список монет
- `GET /api/catalog/filters` - получить фильтры
- `GET /api/catalog/coins/:id` - получить монету по ID

### Параметры фильтрации
- `metal` - металл (Au, Ag, Cu, Pt)
- `condition` - состояние (UNC, XF, VF, F, VG, G)
- `country` - страна
- `yearFrom` / `yearTo` - диапазон годов
- `minMintage` / `maxMintage` - диапазон тиража
- `search` - поиск по описанию

## Особенности парсинга

### Извлечение веса и пробы
Парсер автоматически извлекает:
- **Вес монеты** (в граммах)
- **Вес в унциях** (для драгоценных металлов)
- **Пробу** (для драгоценных металлов)
- **Содержание чистого металла** (расчетное)

### Поддерживаемые форматы
- `Au 15,55` - 15.55 грамм золота
- `Ag 31,1` - 31.1 грамм серебра
- `Pt 15,55` - 15.55 грамм платины
- `1/5 oz` - 0.2 унции
- `2,7гр` - 2.7 грамма
- `999 проба` - проба 999

## Устранение неполадок

### Парсер не запускается
```bash
# Проверьте логи
pm2 logs catalog-parser

# Перезапустите
pm2 restart catalog-parser
```

### Веб-сервер недоступен
```bash
# Проверьте порт 3000
netstat -tlnp | grep 3000

# Перезапустите веб-сервер
pm2 restart catalog-server
```

### Проблемы с базой данных
```bash
# Проверьте подключение
node -e "const { Pool } = require('pg'); const config = require('./config'); const pool = new Pool(config.dbConfig); pool.query('SELECT 1').then(() => console.log('OK')).catch(console.error);"
```

## Обновление

### Обновление кода
```bash
# На сервере
git pull origin catalog-parser
pm2 restart catalog-parser
pm2 restart catalog-server
```

### Обновление данных
```bash
# Остановите парсер
pm2 stop catalog-parser

# Очистите БД (если нужно)
node clear-catalog-db.js

# Запустите парсер заново
pm2 start catalog-parser.js --name catalog-parser
```

## Безопасность

### Рекомендации
- Используйте HTTPS в продакшене
- Ограничьте доступ к API
- Регулярно обновляйте зависимости
- Мониторьте логи на предмет ошибок

### Резервное копирование
```bash
# Создайте резервную копию БД
pg_dump -h localhost -U username -d database_name > catalog_backup.sql

# Восстановите из резервной копии
psql -h localhost -U username -d database_name < catalog_backup.sql
```