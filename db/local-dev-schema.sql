-- Local development bootstrap schema + seed data for the Wolmar apps.
--
-- IMPORTANT: This is a reconstruction for a LOCAL PostgreSQL instance so the two
-- Express apps can run and be exercised in a self-contained dev environment.
-- Production uses a hosted Supabase database (see env.example / config.example.js),
-- which is the real source of truth. Column set here is derived from the queries in
-- server.js, catalog-server.js, auth-service.js, collection-service.js, and
-- collection-price-service.js.

-- ============================================================================
-- Auction data (Product A: main analytics site, server.js @ 3001)
-- ============================================================================
CREATE TABLE IF NOT EXISTS auction_lots (
    id SERIAL PRIMARY KEY,
    lot_number VARCHAR(50),
    auction_number VARCHAR(50),
    coin_description TEXT,
    avers_image_url TEXT,
    avers_image_path TEXT,
    revers_image_url TEXT,
    revers_image_path TEXT,
    winner_login VARCHAR(100),
    winning_bid DECIMAL(12, 2),
    auction_end_date TIMESTAMP,
    currency VARCHAR(10) DEFAULT 'RUB',
    parsed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_url TEXT,
    bids_count INTEGER,
    lot_status VARCHAR(20),
    year INTEGER,
    letters VARCHAR(10),
    metal VARCHAR(10),
    condition VARCHAR(20),
    weight DECIMAL(10, 2),
    UNIQUE(lot_number, auction_number)
);

-- `weight` was added to the production schema after the parser's original CREATE,
-- so ensure it exists on pre-existing local tables too.
ALTER TABLE auction_lots ADD COLUMN IF NOT EXISTS weight DECIMAL(10, 2);

CREATE TABLE IF NOT EXISTS lot_price_predictions (
    id SERIAL PRIMARY KEY,
    lot_id INTEGER UNIQUE REFERENCES auction_lots(id),
    predicted_price DECIMAL(12,2),
    metal_value DECIMAL(12,2),
    numismatic_premium DECIMAL(12,2),
    confidence_score DECIMAL(4,2),
    sample_size INTEGER,
    prediction_method VARCHAR(50) DEFAULT 'simplified_model',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS auction_lot_urls (
    id SERIAL PRIMARY KEY,
    auction_number VARCHAR(50),
    lot_url TEXT NOT NULL,
    lot_number VARCHAR(50),
    page_number INTEGER,
    url_index INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(auction_number, lot_url)
);

CREATE TABLE IF NOT EXISTS winner_ratings (
    id SERIAL PRIMARY KEY,
    winner_login VARCHAR(100) UNIQUE NOT NULL,
    total_spent DECIMAL(15, 2) DEFAULT 0,
    total_lots INTEGER DEFAULT 0,
    unique_auctions INTEGER DEFAULT 0,
    avg_lot_price DECIMAL(12, 2) DEFAULT 0,
    max_lot_price DECIMAL(12, 2) DEFAULT 0,
    first_auction_date TIMESTAMP,
    last_auction_date TIMESTAMP,
    activity_days INTEGER DEFAULT 0,
    rating INTEGER DEFAULT 1,
    category VARCHAR(20) DEFAULT 'Новичок',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS metals_prices (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL UNIQUE,
    usd_rate DECIMAL(10,4),
    gold_price DECIMAL(10,4),
    silver_price DECIMAL(10,4),
    platinum_price DECIMAL(10,4),
    palladium_price DECIMAL(10,4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- Catalog + users (Product B: catalog site, catalog-server.js @ 3000)
-- ============================================================================
CREATE TABLE IF NOT EXISTS coin_catalog (
    id SERIAL PRIMARY KEY,
    lot_id INTEGER REFERENCES auction_lots(id),
    auction_number INTEGER,
    lot_number VARCHAR(50),
    denomination VARCHAR(100),
    coin_name VARCHAR(500),
    year INTEGER,
    metal VARCHAR(20),
    rarity VARCHAR(10),
    mint VARCHAR(200),
    mintage INTEGER,
    condition VARCHAR(100),
    country VARCHAR(100),
    coin_weight DECIMAL(10,3),
    fineness DECIMAL(10,3),
    pure_metal_weight DECIMAL(10,3),
    weight_oz DECIMAL(10,4),
    bitkin_info TEXT,
    uzdenikov_info TEXT,
    ilyin_info TEXT,
    petrov_info TEXT,
    severin_info TEXT,
    dyakov_info TEXT,
    kazakov_info TEXT,
    avers_image_path VARCHAR(500),
    revers_image_path VARCHAR(500),
    avers_image_url VARCHAR(500),
    revers_image_url VARCHAR(500),
    avers_image_data BYTEA,
    revers_image_data BYTEA,
    original_description TEXT,
    parsed_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS collection_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(200),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_collections (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES collection_users(id),
    coin_id INTEGER NOT NULL,
    notes TEXT,
    condition_rating INTEGER,
    condition VARCHAR(20),
    purchase_price DECIMAL(12,2),
    purchase_date DATE,
    predicted_price DECIMAL(12,2),
    confidence_score DECIMAL(6,3),
    prediction_method VARCHAR(50),
    price_calculation_date TIMESTAMP,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, coin_id)
);

-- ============================================================================
-- Seed data
-- ============================================================================
INSERT INTO auction_lots
    (lot_number, auction_number, coin_description, winner_login, winning_bid,
     auction_end_date, bids_count, lot_status, year, metal, condition, source_url)
VALUES
    ('1', '100', '1 рубль 1899 год, серебро, состояние XF', 'collector_ivan', 15000.00,
     NOW() - INTERVAL '10 days', 12, 'sold', 1899, 'Ag', 'XF', 'https://www.wolmar.ru/auction/100/1'),
    ('2', '100', '10 рублей 1899 год, золото, состояние AU', 'numizmat_pro', 85000.00,
     NOW() - INTERVAL '10 days', 25, 'sold', 1899, 'Au', 'AU', 'https://www.wolmar.ru/auction/100/2'),
    ('3', '100', '50 копеек 1912 год, серебро, состояние VF', 'collector_ivan', 4200.00,
     NOW() - INTERVAL '10 days', 7, 'sold', 1912, 'Ag', 'VF', 'https://www.wolmar.ru/auction/100/3'),
    ('1', '101', '5 копеек 1932 год, медь, состояние F', 'coin_hunter', 900.00,
     NOW() - INTERVAL '3 days', 4, 'sold', 1932, 'Cu', 'F', 'https://www.wolmar.ru/auction/101/1'),
    ('2', '101', '1 рубль 1921 год, серебро, состояние XF', 'numizmat_pro', 22000.00,
     NOW() - INTERVAL '3 days', 31, 'sold', 1921, 'Ag', 'XF', 'https://www.wolmar.ru/auction/101/2')
ON CONFLICT (lot_number, auction_number) DO NOTHING;

UPDATE auction_lots SET weight = 20.00 WHERE auction_number = '100' AND lot_number = '1';
UPDATE auction_lots SET weight = 8.60  WHERE auction_number = '100' AND lot_number = '2';
UPDATE auction_lots SET weight = 10.00 WHERE auction_number = '100' AND lot_number = '3';
UPDATE auction_lots SET weight = 5.00  WHERE auction_number = '101' AND lot_number = '1';
UPDATE auction_lots SET weight = 20.00 WHERE auction_number = '101' AND lot_number = '2';

INSERT INTO lot_price_predictions
    (lot_id, predicted_price, metal_value, numismatic_premium, confidence_score, sample_size, prediction_method)
SELECT al.id, 16000.00, 1408.50, 14591.50, 0.82, 12, 'simplified_model'
FROM auction_lots al WHERE al.auction_number = '100' AND al.lot_number = '1'
ON CONFLICT (lot_id) DO NOTHING;

INSERT INTO lot_price_predictions
    (lot_id, predicted_price, metal_value, numismatic_premium, confidence_score, sample_size, prediction_method)
SELECT al.id, 90000.00, 52632.00, 37368.00, 0.75, 8, 'simplified_model'
FROM auction_lots al WHERE al.auction_number = '100' AND al.lot_number = '2'
ON CONFLICT (lot_id) DO NOTHING;

INSERT INTO metals_prices (date, usd_rate, gold_price, silver_price, platinum_price, palladium_price)
VALUES (CURRENT_DATE, 92.5000, 6800.5000, 78.2500, 3100.0000, 4200.0000)
ON CONFLICT (date) DO NOTHING;

INSERT INTO coin_catalog
    (lot_id, auction_number, lot_number, denomination, coin_name, year, metal, rarity,
     mint, mintage, condition, country, coin_weight, fineness, pure_metal_weight,
     original_description)
VALUES
    (1, 100, '1', '1 рубль', '1 рубль 1899', 1899, 'Ag', 'R',
     'СПБ', 1000000, 'XF', 'Россия', 20.0, 0.900, 18.0, '1 рубль 1899 год, серебро'),
    (2, 100, '2', '10 рублей', '10 рублей 1899', 1899, 'Au', 'RR',
     'СПБ', 500000, 'AU', 'Россия', 8.6, 0.900, 7.74, '10 рублей 1899 год, золото'),
    (3, 100, '3', '50 копеек', '50 копеек 1912', 1912, 'Ag', NULL,
     'СПБ', 2000000, 'VF', 'Россия', 10.0, 0.900, 9.0, '50 копеек 1912 год, серебро')
ON CONFLICT DO NOTHING;

INSERT INTO winner_ratings
    (winner_login, total_spent, total_lots, unique_auctions, avg_lot_price, max_lot_price,
     first_auction_date, last_auction_date, activity_days, rating, category)
VALUES
    ('numizmat_pro', 107000.00, 2, 2, 53500.00, 85000.00,
     NOW() - INTERVAL '10 days', NOW() - INTERVAL '3 days', 7, 5, 'Эксперт'),
    ('collector_ivan', 19200.00, 2, 1, 9600.00, 15000.00,
     NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days', 1, 3, 'Любитель')
ON CONFLICT (winner_login) DO NOTHING;
