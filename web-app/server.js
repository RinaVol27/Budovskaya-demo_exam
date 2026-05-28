id="q4m7"
const express = require('express'); 
const bodyParser = require('body-parser'); 
const cors = require('cors'); 
const bcrypt = require('bcrypt'); 
const jwt = require('jsonwebtoken'); 
const pgp = require('pg-promise')(); 
require('dotenv').config(); 

const app = express(); 

app.use(cors()); app.use(bodyParser.json()); 
app.use(express.static('public')); 

// ====================================================== // 
// ПОДКЛЮЧЕНИЕ К БАЗЕ //
//  ====================================================== 
const db = pgp({ 
    host: process.env.DB_HOST, 
    port: process.env.DB_PORT, 
    database: process.env.DB_NAME, 
    user: process.env.DB_USER, 
    password: process.env.DB_PASSWORD }); 

// ====================================================== // 
// РЕГИСТРАЦИЯ // 
// ====================================================== 
app.post('/register', async (req, res) => { 
    const { full_name, login, email, phone, password } = req.body; try { 
        // Проверка пользователя 
        const existingUser = await db.oneOrNone( 
                'SELECT * FROM users WHERE email = $1 OR login = $2', [email, login] ); 
            if (existingUser) { return res.status(400).json({ message: 'Пользователь уже существует' }); } 
            
            // Хэширование пароля 
            const hashedPassword = await bcrypt.hash(password, 10); 
            
            // Добавление пользователя 
            await db.none( 
                ` INSERT INTO users ( full_name, login, email, phone, password_hash ) VALUES ( $1, $2, $3, $4, $5 ) `, [ full_name, login, email, phone, hashedPassword ] ); 
                res.json({ message: 'Регистрация успешна' }); } 
                catch (err) { console.log(err); res.status(500).json({ message: 'Ошибка сервера' });
            } 
        }
    ); 

// ====================================================== // 
// АВТОРИЗАЦИЯ // 
// ====================================================== 
app.post('/login', async (req, res) => { 
    const { email, password } = req.body; 
    try { 
        // Поиск пользователя 
        const user = await db.oneOrNone( 'SELECT * FROM users WHERE email = $1', [email] ); 
        if (!user) { return res.status(401).json({ message: 'Неверный email или пароль' }); } 

        // Проверка пароля 
        const isMatch = await bcrypt.compare( password, user.password_hash ); 
        if (!isMatch) { return res.status(401).json({ message: 'Неверный email или пароль' }); } 
        
        // JWT токен 
        const token = jwt.sign( 
        { 
            id: user.id, 
            role: user.role, 
            is_organizer: user.is_organizer 
        }, process.env.JWT_SECRET, { expiresIn: '1h' } ); 
        res.json({ message: 'Авторизация успешна', token }); } 
        catch (err) { console.log(err); res.status(500).json({ message: 'Ошибка сервера' }); } }); 
        

// ====================================================== // 
// ЗАПУСК СЕРВЕРА // 
// ====================================================== 
app.listen(process.env.PORT, () => {
    console.log(`Сервер запущен на порту ${process.env.PORT}`);
});