#!/bin/bash

echo "📦 Упаковка проекта каталога для сервера..."

# Создаем директорию для каталога
mkdir -p catalog-deployment

# Копируем основные файлы каталога
echo "📋 Копирование основных файлов..."
cp catalog-parser.js catalog-deployment/
cp catalog-server.js catalog-deployment/
cp catalog-monitor.js catalog-deployment/
cp catalog-progress.json catalog-deployment/ 2>/dev/null || echo "⚠️ Файл прогресса не найден"

# Копируем веб-интерфейс
echo "🌐 Копирование веб-интерфейса..."
mkdir -p catalog-deployment/public
cp -r catalog-public/* catalog-deployment/public/

# Копируем конфигурацию
echo "⚙️ Копирование конфигурации..."
cp config.js catalog-deployment/
cp package.json catalog-deployment/

# Создаем README для развертывания
cat > catalog-deployment/README-DEPLOYMENT.md << 'EOF'
# Развертывание каталога монет на сервере

## Структура проекта
- `catalog-parser.js` - основной парсер каталога
- `catalog-server.js` - веб-сервер каталога (порт 3000)
- `catalog-monitor.js` - мониторинг прогресса
- `public/` - веб-интерфейс каталога
- `config.js` - конфигурация БД
- `package.json` - зависимости

## Команды для развертывания

1. Установка зависимостей:
```bash
npm install
```

2. Запуск парсера каталога:
```bash
node catalog-parser.js
```

3. Запуск веб-сервера каталога:
```bash
node catalog-server.js
```

4. Мониторинг прогресса:
```bash
node catalog-monitor.js progress
```

## Порты
- Каталог: http://server:3000
- Основной сайт: http://server:3001
EOF

# Создаем скрипт установки
cat > catalog-deployment/install-catalog.sh << 'EOF'
#!/bin/bash

echo "🚀 Установка каталога монет на сервере..."

# Проверяем наличие Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js не установлен. Установите Node.js сначала."
    exit 1
fi

# Устанавливаем зависимости
echo "📦 Установка зависимостей..."
npm install

# Проверяем конфигурацию БД
echo "🔍 Проверка конфигурации БД..."
if [ ! -f "config.js" ]; then
    echo "❌ Файл config.js не найден!"
    exit 1
fi

echo "✅ Каталог готов к запуску!"
echo ""
echo "Команды для запуска:"
echo "1. Парсер: node catalog-parser.js"
echo "2. Сервер: node catalog-server.js"
echo "3. Мониторинг: node catalog-monitor.js progress"
EOF

chmod +x catalog-deployment/install-catalog.sh

# Создаем архив
echo "📦 Создание архива..."
tar -czf catalog-deployment.tar.gz catalog-deployment/

echo "✅ Проект каталога упакован в catalog-deployment.tar.gz"
echo "📁 Размер архива: $(du -h catalog-deployment.tar.gz | cut -f1)"
echo ""
echo "📋 Содержимое архива:"
tar -tzf catalog-deployment.tar.gz | head -20
echo "..."
