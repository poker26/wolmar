Write-Host "🚀 Развертывание каталога монет на сервере через Git..." -ForegroundColor Green

# Проверяем, что мы в правильной директории
if (-not (Test-Path "catalog-parser.js")) {
    Write-Host "❌ Файл catalog-parser.js не найден. Запустите скрипт из корневой директории проекта." -ForegroundColor Red
    exit 1
}

# Останавливаем существующие процессы каталога
Write-Host "🛑 Остановка существующих процессов каталога..." -ForegroundColor Yellow
Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Создаем резервную копию текущего состояния
Write-Host "💾 Создание резервной копии..." -ForegroundColor Yellow
if (Test-Path "catalog-progress.json") {
    Copy-Item "catalog-progress.json" "catalog-progress.json.backup"
}

# Коммитим все изменения каталога
Write-Host "📝 Коммит изменений каталога..." -ForegroundColor Yellow
git add catalog-parser.js, catalog-server.js, catalog-monitor.js, catalog-public/, catalog-progress.json
git commit -m "Обновление каталога монет с улучшенным парсингом веса и пробы"

# Пушим изменения на сервер
Write-Host "📤 Отправка изменений на сервер..." -ForegroundColor Yellow
git push origin catalog-parser

Write-Host "✅ Изменения отправлены на сервер!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Следующие шаги на сервере:" -ForegroundColor Cyan
Write-Host "1. git pull origin catalog-parser" -ForegroundColor White
Write-Host "2. npm install (если нужно)" -ForegroundColor White
Write-Host "3. node catalog-parser.js (для запуска парсера)" -ForegroundColor White
Write-Host "4. node catalog-server.js (для запуска веб-сервера)" -ForegroundColor White
Write-Host ""
Write-Host "🌐 После запуска каталог будет доступен на:" -ForegroundColor Cyan
Write-Host "   http://server:3000" -ForegroundColor White
