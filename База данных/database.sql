-- Эта структура хороша тем, что:

-- 1. легко расширяется;
-- 2. выглядит профессионально на экзамене;
-- 3. подходит под большинство ТЗ;
-- показывает связи таблиц;
-- содержит роли и безопасность;
-- уже готова под backend.

sql
-- =========================================================
-- СОЗДАНИЕ БАЗЫ ДАННЫХ
-- =========================================================

CREATE DATABASE web_app_db;

-- Подключение к БД
-- \c web_app_db


-- =========================================================
-- ТАБЛИЦА ПОЛЬЗОВАТЕЛЕЙ
-- =========================================================

CREATE TABLE users (
    id SERIAL PRIMARY KEY,

    full_name VARCHAR(255) NOT NULL,

    login VARCHAR(100) UNIQUE NOT NULL,

    email VARCHAR(255) UNIQUE NOT NULL,

    phone VARCHAR(30),

    password_hash TEXT NOT NULL,

    -- Является ли пользователь организатором/админом
    is_organizer BOOLEAN DEFAULT FALSE,

    -- Можно добавить обычную роль
    role VARCHAR(50) DEFAULT 'user',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================
-- ТАБЛИЦА КАТЕГОРИЙ
-- (универсальная таблица)
-- =========================================================

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,

    name VARCHAR(255) NOT NULL UNIQUE,

    description TEXT
);


-- =========================================================
-- ОСНОВНАЯ ТАБЛИЦА ОБЪЕКТОВ СИСТЕМЫ
-- =========================================================
-- В зависимости от темы это может быть:
-- товары
-- мероприятия
-- книги
-- услуги
-- заявки
-- объявления
-- курсы
-- и т.д.

CREATE TABLE items (
    id SERIAL PRIMARY KEY,

    title VARCHAR(255) NOT NULL,

    description TEXT,

    price DECIMAL(10,2),

    image_path TEXT,

    quantity INTEGER DEFAULT 0,

    category_id INTEGER REFERENCES categories(id)
        ON DELETE SET NULL,

    created_by INTEGER REFERENCES users(id)
        ON DELETE CASCADE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================
-- ТАБЛИЦА ЗАКАЗОВ / ЗАЯВОК
-- =========================================================

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,

    user_id INTEGER NOT NULL REFERENCES users(id)
        ON DELETE CASCADE,

    status VARCHAR(50) DEFAULT 'new',

    total_price DECIMAL(10,2) DEFAULT 0,

    address TEXT,

    comment TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================
-- ТОВАРЫ ВНУТРИ ЗАКАЗА
-- =========================================================

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,

    order_id INTEGER NOT NULL REFERENCES orders(id)
        ON DELETE CASCADE,

    item_id INTEGER NOT NULL REFERENCES items(id)
        ON DELETE CASCADE,

    quantity INTEGER NOT NULL DEFAULT 1
);


-- =========================================================
-- ТАБЛИЦА ИЗОБРАЖЕНИЙ
-- =========================================================

CREATE TABLE images (
    id SERIAL PRIMARY KEY,

    item_id INTEGER REFERENCES items(id)
        ON DELETE CASCADE,

    image_url TEXT NOT NULL
);


-- =========================================================
-- ТАБЛИЦА ОТЗЫВОВ
-- =========================================================

CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id)
        ON DELETE CASCADE,

    item_id INTEGER REFERENCES items(id)
        ON DELETE CASCADE,

    rating INTEGER CHECK (rating >= 1 AND rating <= 5),

    comment TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================
-- ИНДЕКСЫ ДЛЯ УСКОРЕНИЯ
-- =========================================================

CREATE INDEX idx_users_email ON users(email);

CREATE INDEX idx_users_login ON users(login);

CREATE INDEX idx_orders_user_id ON orders(user_id);

CREATE INDEX idx_items_category_id ON items(category_id);


-- =========================================================
-- ПРИМЕР СОЗДАНИЯ АДМИНА / ОРГАНИЗАТОРА
-- =========================================================

INSERT INTO users (
    full_name,
    login,
    email,
    phone,
    password_hash,
    is_organizer,
    role
)
VALUES (
    'Администратор',
    'admin',
    'admin@mail.com',
    '+79999999999',
    '$2b$10$examplehash',
    TRUE,
    'admin'
);


-- =========================================================
-- ПРИМЕР КАТЕГОРИЙ
-- =========================================================

INSERT INTO categories (name, description)
VALUES
('Категория 1', 'Описание категории'),
('Категория 2', 'Описание категории');


-- =========================================================
-- ПРИМЕР ТОВАРА / ОБЪЕКТА
-- =========================================================

INSERT INTO items (
    title,
    description,
    price,
    quantity,
    category_id,
    created_by
)
VALUES (
    'Пример объекта',
    'Описание объекта',
    1500.00,
    10,
    1,
    1
);
