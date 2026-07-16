const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getPool, sql } = require('../config/database');
const auth = require('../middleware/auth');

const router = express.Router();

// POST /api/auth/register
router.post('/register', async (req, res) => {
  const { fullName, email, password } = req.body;
  if (!fullName || !email || !password)
    return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin' });

  try {
    const pool = await getPool();
    const existing = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT Id FROM Users WHERE Email = @email');
    if (existing.recordset.length > 0)
      return res.status(409).json({ message: 'Email đã được sử dụng' });

    const hash = await bcrypt.hash(password, 10);
    const initials = fullName.trim().split(' ').map(w => w[0]).slice(-2).join('').toUpperCase();
    const colors = ['#8B2FC9', '#E91E8C', '#0284C7', '#16A34A', '#D97706'];
    const avatarColor = colors[Math.floor(Math.random() * colors.length)];

    const insertResult = await pool.request()
      .input('fullName', sql.NVarChar, fullName)
      .input('email', sql.NVarChar, email)
      .input('passwordHash', sql.NVarChar, hash)
      .input('initials', sql.NVarChar, initials)
      .input('avatarColor', sql.NVarChar, avatarColor)
      .query(`INSERT INTO Users (FullName, Email, PasswordHash, AvatarInitials, AvatarColor)
              OUTPUT INSERTED.Id
              VALUES (@fullName, @email, @passwordHash, @initials, @avatarColor)`);

    const newId = insertResult.recordset[0].Id;
    const autoNickname = `user${newId}`;

    const userResult = await pool.request()
      .input('userId', sql.Int, newId)
      .input('nickname', sql.NVarChar, autoNickname)
      .query(`UPDATE Users SET Nickname = @nickname WHERE Id = @userId;
              SELECT Id, FullName, Email, AvatarInitials, AvatarColor, Nickname FROM Users WHERE Id = @userId`);

    const user = userResult.recordset[0];
    const token = jwt.sign({ userId: user.Id }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.status(201).json({ token, user });
  } catch (err) {
    console.error('[register]', err);
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// PATCH /api/auth/nickname
router.patch('/nickname', auth, async (req, res) => {
  const { nickname } = req.body;
  if (!nickname || !nickname.trim())
    return res.status(400).json({ message: 'Nickname không được để trống' });
  if (nickname.trim().length > 50)
    return res.status(400).json({ message: 'Nickname tối đa 50 ký tự' });
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('userId', sql.Int, req.userId)
      .input('nickname', sql.NVarChar, nickname.trim())
      .query(`UPDATE Users SET Nickname = @nickname WHERE Id = @userId;
              SELECT Nickname FROM Users WHERE Id = @userId`);
    res.json({ nickname: result.recordset[0].Nickname });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ message: 'Vui lòng nhập email và mật khẩu' });

  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT * FROM Users WHERE Email = @email');
    if (result.recordset.length === 0)
      return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng' });

    const user = result.recordset[0];
    const valid = await bcrypt.compare(password, user.PasswordHash);
    if (!valid)
      return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng' });

    const token = jwt.sign({ userId: user.Id }, process.env.JWT_SECRET, { expiresIn: '30d' });
    const { PasswordHash, ...safeUser } = user;
    res.json({ token, user: safeUser });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

module.exports = router;
