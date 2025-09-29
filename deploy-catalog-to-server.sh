#!/bin/bash

echo "🚀 Развертывание каталога монет на сервере через Git..."

# Проверяем, что мы в правильной директории
if [ ! -f "catalog-parser.js" ]; then
    echo "❌ Файл catalog-parser.js не найден. Запустите скрипт из корневой директории проекта."
    exit 1
fi

# Останавливаем существующие процессы каталога
echo "🛑 Остановка существующих процессов каталога..."
pm2 stop catalog-parser 2>/dev/null || true
pm2 stop catalog-server 2>/dev/null || true

# Создаем резервную копию текущего состояния
echo "💾 Создание резервной копии..."
cp catalog-progress.json catalog-progress.json.backup 2>/dev/null || true

# Коммитим все изменения каталога
echo "📝 Коммит изменений каталога..."
git add catalog-parser.js catalog-server.js catalog-monitor.js catalog-public/ catalog-progress.json
git commit -m "Обновление каталога монет с улучшенным парсингом веса и пробы"

# Пушим изменения на сервер
echo "📤 Отправка изменений на сервер..."
git push origin catalog-parser

echo "✅ Изменения отправлены на сервер!"
echo ""
echo "📋 Следующие шаги на сервере:"
echo "1. git pull origin catalog-parser"
echo "2. npm install (если нужно)"
echo "3. node catalog-parser.js (для запуска парсера)"
echo "4. node catalog-server.js (для запуска веб-сервера)"
echo ""
echo "🌐 После запуска каталог будет доступен на:"
echo "   http://server:3000"
