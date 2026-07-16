require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const tutorialRoutes = require('./routes/tutorials');
const categoryRoutes = require('./routes/categories');
const favoriteRoutes = require('./routes/favorites');
const myOrigamiRoutes = require('./routes/myOrigami');
const friendRoutes = require('./routes/friends');
const notificationRoutes = require('./routes/notifications');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/tutorials', tutorialRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/favorites', favoriteRoutes);
app.use('/api/my-origami', myOrigamiRoutes);
app.use('/api/friends', friendRoutes);
app.use('/api/notifications', notificationRoutes);

app.get('/api/health', (_, res) => res.json({ status: 'OK', time: new Date() }));

// Catch-all: trả JSON thay vì HTML khi route không tồn tại
app.use((req, res) => {
  res.status(404).json({ message: `Cannot ${req.method} ${req.path}` });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('[Unhandled]', err);
  res.status(500).json({ message: 'Lỗi server', error: err.message });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Origami API running on http://localhost:${PORT}`));
