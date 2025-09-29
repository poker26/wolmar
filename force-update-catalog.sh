#!/bin/bash

echo "🚀 Принудительное обновление каталога на сервере..."

# Останавливаем все процессы каталога
echo "🛑 Остановка процессов каталога..."
pm2 stop catalog-parser 2>/dev/null || true
pm2 stop catalog-server 2>/dev/null || true

# Сбрасываем все локальные изменения
echo "🔄 Сброс локальных изменений..."
git reset --hard HEAD
git clean -fd

# Получаем последние изменения
echo "📥 Получение последних изменений..."
git pull origin catalog-parser

# Устанавливаем зависимости
echo "📦 Установка зависимостей..."
npm install

# Запускаем каталог
echo "🚀 Запуск каталога..."
pm2 start catalog-parser.js --name catalog-parser
pm2 start catalog-server.js --name catalog-server

# Сохраняем конфигурацию PM2
pm2 save

echo "✅ Каталог обновлен и запущен!"
echo ""
echo "📊 Статус процессов:"
pm2 status

echo ""
echo "🌐 Каталог доступен на:"
echo "   http://server:3000"
