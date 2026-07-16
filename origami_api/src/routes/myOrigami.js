const express = require('express');
const { getPool, sql } = require('../config/database');
const auth = require('../middleware/auth');

const router = express.Router();

// GET /api/my-origami
router.get('/', auth, async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('userId', sql.Int, req.userId)
      .query(`SELECT t.*, uo.CompletedAt
              FROM UserOrigami uo
              JOIN Tutorials t ON t.Id = uo.TutorialId
              WHERE uo.UserId = @userId
              ORDER BY uo.CompletedAt DESC`);

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

// POST /api/my-origami/:tutorialId  — đánh dấu hoàn thành
router.post('/:tutorialId', auth, async (req, res) => {
  try {
    const pool = await getPool();
    const insertResult = await pool.request()
      .input('userId', sql.Int, req.userId)
      .input('tutorialId', sql.Int, req.params.tutorialId)
      .query(`IF NOT EXISTS (SELECT 1 FROM UserOrigami WHERE UserId=@userId AND TutorialId=@tutorialId)
              BEGIN
                INSERT INTO UserOrigami (UserId, TutorialId) VALUES (@userId, @tutorialId);
                SELECT 1 AS inserted;
              END
              ELSE SELECT 0 AS inserted`);

    const inserted = insertResult.recordset[0]?.inserted === 1;
    if (inserted) {
      const tutorialResult = await pool.request()
        .input('tutorialId', sql.Int, req.params.tutorialId)
        .query('SELECT Title FROM Tutorials WHERE Id=@tutorialId');
      const title = tutorialResult.recordset[0]?.Title ?? 'bài origami';

      await pool.request()
        .input('userId', sql.Int, req.userId)
        .input('title', sql.NVarChar, 'Hoàn thành bài!')
        .input('body', sql.NVarChar, `Chúc mừng! Bạn đã hoàn thành "${title}".`)
        .input('icon', sql.NVarChar, 'trophy')
        .query('INSERT INTO Notifications (UserId, Title, Body, Icon) VALUES (@userId, @title, @body, @icon)');
    }

    res.json({ message: 'Đã thêm vào My Origami' });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// DELETE /api/my-origami/:tutorialId
router.delete('/:tutorialId', auth, async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('userId', sql.Int, req.userId)
      .input('tutorialId', sql.Int, req.params.tutorialId)
      .query('DELETE FROM UserOrigami WHERE UserId=@userId AND TutorialId=@tutorialId');
    res.json({ message: 'Đã xoá khỏi My Origami' });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

module.exports = router;
