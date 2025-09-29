const { Pool } = require('pg');
const config = require('./config');

async function clearCatalogDB() {
    const pool = new Pool(config.dbConfig);
    
    try {
        console.log('🗑️ Полная очистка БД каталога...\n');
        
        // Удаляем все записи из таблицы каталога
        const deleteResult = await pool.query('DELETE FROM coin_catalog');
        console.log(`✅ Удалено записей: ${deleteResult.rowCount}`);
        
        // Сбрасываем счетчик ID
        await pool.query('ALTER SEQUENCE coin_catalog_id_seq RESTART WITH 1');
        console.log('✅ Счетчик ID сброшен');
        
        // Проверяем, что таблица пуста
        const countResult = await pool.query('SELECT COUNT(*) FROM coin_catalog');
        console.log(`📊 Записей в каталоге: ${countResult.rows[0].count}`);
        
        console.log('\n🎉 БД каталога полностью очищена!');
        
    } catch (error) {
        console.error('❌ Ошибка при очистке БД:', error.message);
    } finally {
        await pool.end();
    }
}

clearCatalogDB();
