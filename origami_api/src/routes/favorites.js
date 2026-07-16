const express = require('express');
const { getPool, sql } = require('../config/database');
const auth = require('../middleware/auth');

const router = express.Router();

// GET /api/favorites  — danh sách tutorial yêu thích của user hiện tại
router.get('/', auth, async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('userId', sql.Int, req.userId)
      .query(`SELECT t.*, uf.CreatedAt AS FavoritedAt
              FROM UserFavorites uf
              JOIN Tutorials t ON t.Id = uf.TutorialId
              WHERE uf.UserId = @userId
              ORDER BY uf.CreatedAt DESC`);

    const tutorials = result.recordset;
    if (tutorials.length === 0) return res.json([]);

    const ids = tutorials.map(t => t.Id).join(',');
    const tagsResult = await pool.request()
      .query(`SELECT TutorialId, Tag FROM TutorialTags WHERE TutorialId IN (${ids}) ORDER BY SortOrder`);
    const tagsMap = {};
    tagsResult.recordset.forEach(r => {
      if (!tagsMap[r.TutorialId]) tagsMap[r.TutorialId] = [];
      tagsMap[r.TutorialId].push(r.Tag);
    });
    res.json(tutorials.map(t => ({ ...t, tags: tagsMap[t.Id] || [] })));
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// POST /api/favorites/:tutorialId  — thêm vào yêu thích
router.post('/:tutorialId', auth, async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('userId', sql.Int, req.userId)
      .input('tutorialId', sql.Int, req.params.tutorialId)
      .query(`IF NOT EXISTS (SELECT 1 FROM UserFavorites WHERE UserId=@userId AND TutorialId=@tutorialId)
              INSERT INTO UserFavorites (UserId, TutorialId) VALUES (@userId, @tutorialId)`);
    res.json({ message: 'Đã thêm vào yêu thích' });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// DELETE /api/favorites/:tutorialId  — xoá khỏi yêu thích
router.delete('/:tutorialId', auth, async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('userId', sql.Int, req.userId)
      .input('tutorialId', sql.Int, req.params.tutorialId)
      .query('DELETE FROM UserFavorites WHERE UserId=@userId AND TutorialId=@tutorialId');
    res.json({ message: 'Đã xoá khỏi yêu thích' });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

module.exports = router;
