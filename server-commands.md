# Команды для настройки каталога на сервере

## 1. Подключитесь к серверу:
```bash
ssh root@46.173.19.68
cd /var/www/wolmar-parser
```

## 2. Остановите старые процессы:
```bash
pm2 stop catalog-parser 2>/dev/null || true
pm2 stop catalog-server 2>/dev/null || true
pm2 delete catalog-parser 2>/dev/null || true
pm2 delete catalog-server 2>/dev/null || true
```

## 3. Остановите процессы на порту 3000:
```bash
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
```

## 4. Установите зависимости:
```bash
npm install
```

## 5. Запустите скрипт настройки:
```bash
chmod +x setup-catalog-server.sh
./setup-catalog-server.sh
```

## 6. Проверьте результат:
```bash
pm2 status
curl http://localhost:3000
```

## Альтернативно - ручная настройка:

### Создайте PM2 конфигурацию:
```bash
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
      }
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
      }
    }
  ]
};
EOF
```

### Запустите каталог:
```bash
pm2 start ecosystem-catalog.config.js
pm2 save
```

### Проверьте статус:
```bash
pm2 status
curl http://localhost:3000
```
