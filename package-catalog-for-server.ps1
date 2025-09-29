Write-Host "📦 Упаковка проекта каталога для сервера..." -ForegroundColor Green

# Создаем директорию для каталога
New-Item -ItemType Directory -Path "catalog-deployment" -Force | Out-Null

# Копируем основные файлы каталога
Write-Host "📋 Копирование основных файлов..." -ForegroundColor Yellow
Copy-Item "catalog-parser.js" "catalog-deployment/"
Copy-Item "catalog-server.js" "catalog-deployment/"
Copy-Item "catalog-monitor.js" "catalog-deployment/"
if (Test-Path "catalog-progress.json") {
    Copy-Item "catalog-progress.json" "catalog-deployment/"
} else {
    Write-Host "⚠️ Файл прогресса не найден" -ForegroundColor Yellow
}

# Копируем веб-интерфейс
Write-Host "🌐 Копирование веб-интерфейса..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "catalog-deployment/public" -Force | Out-Null
Copy-Item "catalog-public/*" "catalog-deployment/public/" -Recurse

# Копируем конфигурацию
Write-Host "⚙️ Копирование конфигурации..." -ForegroundColor Yellow
Copy-Item "config.js" "catalog-deployment/"
Copy-Item "package.json" "catalog-deployment/"

# Создаем README для развертывания
$readmeContent = @"
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
"@

$readmeContent | Out-File -FilePath "catalog-deployment/README-DEPLOYMENT.md" -Encoding UTF8

# Создаем скрипт установки
$installScript = @"
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
"@

$installScript | Out-File -FilePath "catalog-deployment/install-catalog.sh" -Encoding UTF8

# Создаем архив
Write-Host "📦 Создание архива..." -ForegroundColor Yellow
Compress-Archive -Path "catalog-deployment/*" -DestinationPath "catalog-deployment.zip" -Force

Write-Host "✅ Проект каталога упакован в catalog-deployment.zip" -ForegroundColor Green
$archiveSize = (Get-Item "catalog-deployment.zip").Length
Write-Host "📁 Размер архива: $([math]::Round($archiveSize/1MB, 2)) MB" -ForegroundColor Cyan

Write-Host ""
Write-Host "📋 Содержимое архива:" -ForegroundColor Yellow
Get-ChildItem "catalog-deployment" -Recurse | Select-Object Name, Length
