#!/bin/bash

echo "🔧 Настройка каталога монет на сервере..."

# Проверяем, что мы в правильной директории
if [ ! -f "catalog-parser.js" ]; then
    echo "❌ Файл catalog-parser.js не найден. Запустите скрипт из корневой директории проекта."
    exit 1
fi

# Останавливаем существующие процессы
echo "🛑 Остановка существующих процессов..."
pm2 stop catalog-parser 2>/dev/null || true
pm2 stop catalog-server 2>/dev/null || true

# Устанавливаем зависимости
echo "📦 Установка зависимостей..."
npm install

# Проверяем конфигурацию БД
echo "🔍 Проверка конфигурации БД..."
if [ ! -f "config.js" ]; then
    echo "❌ Файл config.js не найден!"
    exit 1
fi

# Проверяем подключение к БД
echo "🔗 Проверка подключения к БД..."
node -e "
const { Pool } = require('pg');
const config = require('./config');
const pool = new Pool(config.dbConfig);
pool.query('SELECT 1')
  .then(() => {
    console.log('✅ Подключение к БД успешно');
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Ошибка подключения к БД:', err.message);
    process.exit(1);
  });
"

if [ $? -ne 0 ]; then
    echo "❌ Не удалось подключиться к БД. Проверьте config.js"
    exit 1
fi

# Создаем PM2 конфигурацию для каталога
echo "⚙️ Создание PM2 конфигурации для каталога..."
cat > ecosystem-catalog.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'catalog-parser',
      script: 'catalog-parser.js',
      cwd: '/var/www/wolmar-parser',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production'
      },
      log_file: '/var/log/pm2/catalog-parser.log',
      out_file: '/var/log/pm2/catalog-parser-out.log',
      error_file: '/var/log/pm2/catalog-parser-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'catalog-server',
      script: 'catalog-server.js',
      cwd: '/var/www/wolmar-parser',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production'
      },
      log_file: '/var/log/pm2/catalog-server.log',
      out_file: '/var/log/pm2/catalog-server-out.log',
      error_file: '/var/log/pm2/catalog-server-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    }
  ]
};
EOF

# Создаем директории для логов
echo "📁 Создание директорий для логов..."
mkdir -p /var/log/pm2

# Запускаем каталог через PM2
echo "🚀 Запуск каталога через PM2..."
pm2 start ecosystem-catalog.config.js

# Сохраняем конфигурацию PM2
pm2 save

echo "✅ Каталог настроен и запущен!"
echo ""
echo "📊 Статус процессов:"
pm2 status

echo ""
echo "🌐 Каталог доступен на:"
echo "   http://server:3000"
echo ""
echo "📋 Полезные команды:"
echo "   pm2 logs catalog-parser    # Логи парсера"
echo "   pm2 logs catalog-server    # Логи веб-сервера"
echo "   pm2 restart catalog-parser  # Перезапуск парсера"
echo "   pm2 restart catalog-server  # Перезапуск веб-сервера"