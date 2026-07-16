const express = require('express');
const { getPool, sql } = require('../config/database');
const auth = require('../middleware/auth');

const router = express.Router();

// GET /api/tutorials/featured
router.get('/featured', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .query('SELECT * FROM Tutorials WHERE IsFeatured = 1 ORDER BY Id');
    const tutorials = await attachTags(pool, result.recordset);
    res.json(tutorials);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// GET /api/tutorials/new
router.get('/new', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .query('SELECT * FROM Tutorials WHERE IsNew = 1 ORDER BY Id');
    const tutorials = await attachTags(pool, result.recordset);
    res.json(tutorials);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// GET /api/tutorials/search?q=... — tìm theo tiêu đề, mô tả hoặc tag
router.get('/search', async (req, res) => {
  const q = (req.query.q || '').trim();
  if (!q) return res.json([]);
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('q', sql.NVarChar, `%${q}%`)
      .query(`SELECT * FROM Tutorials
              WHERE Title LIKE @q OR Description LIKE @q
                 OR Id IN (SELECT TutorialId FROM TutorialTags WHERE Tag LIKE @q)
              ORDER BY Id`);
    const tutorials = await attachTags(pool, result.recordset);
    res.json(tutorials);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// GET /api/tutorials  (?categoryId=... để lọc theo thể loại)
router.get('/', async (req, res) => {
  try {
    const pool = await getPool();
    const categoryId = parseInt(req.query.categoryId, 10);
    const request = pool.request();
    let query = 'SELECT * FROM Tutorials';
    if (!Number.isNaN(categoryId)) {
      request.input('cid', sql.Int, categoryId);
      query += ' WHERE CategoryId = @cid';
    }
    query += ' ORDER BY Id';
    const result = await request.query(query);
    const tutorials = await attachTags(pool, result.recordset);
    res.json(tutorials);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// GET /api/tutorials/:id
router.get('/:id', async (req, res) => {
  try {
    const pool = await getPool();
    const tResult = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT * FROM Tutorials WHERE Id = @id');
    if (tResult.recordset.length === 0)
      return res.status(404).json({ message: 'Không tìm thấy tutorial' });

    const tutorial = tResult.recordset[0];
    const tagsResult = await pool.request()
      .input('tid', sql.Int, tutorial.Id)
      .query('SELECT Tag FROM TutorialTags WHERE TutorialId = @tid ORDER BY SortOrder');
    tutorial.tags = tagsResult.recordset.map(r => r.Tag);

    const stepsResult = await pool.request()
      .input('tid2', sql.Int, tutorial.Id)
      .query('SELECT * FROM TutorialSteps WHERE TutorialId = @tid2 ORDER BY StepOrder');
    tutorial.tutorialSteps = stepsResult.recordset;

    res.json(tutorial);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// POST /api/tutorials/:id/share — chia sẻ mẫu (hoặc thành tích) tới bạn bè
router.post('/:id/share', auth, async (req, res) => {
  const tutorialId = parseInt(req.params.id, 10);
  const { friendIds, type } = req.body;
  if (!Array.isArray(friendIds) || friendIds.length === 0)
    return res.status(400).json({ message: 'Chưa chọn bạn bè để chia sẻ' });

  try {
    const pool = await getPool();

    const tut = await pool.request()
      .input('id', sql.Int, tutorialId)
      .query('SELECT Title FROM Tutorials WHERE Id = @id');
    if (tut.recordset.length === 0)
      return res.status(404).json({ message: 'Không tìm thấy mẫu' });
    const title = tut.recordset[0].Title;

    const me = await pool.request()
      .input('uid', sql.Int, req.userId)
      .query('SELECT FullName, Nickname FROM Users WHERE Id = @uid');
    const sender = me.recordset[0];
    const senderName = (sender.Nickname && sender.Nickname.trim()) || sender.FullName;

    const isCompletion = type === 'completion';
    const notifTitle = isCompletion ? 'Thành tích mới' : 'Mẫu Origami được chia sẻ';
    const icon = isCompletion ? 'emoji_events' : 'share';
    const body = isCompletion
      ? `${senderName} vừa hoàn thành mẫu "${title}"!`
      : `${senderName} đã chia sẻ mẫu "${title}" với bạn`;

    let sent = 0;
    for (const raw of friendIds) {
      const fId = parseInt(raw, 10);
      if (!fId || fId === req.userId) continue;

      // chỉ gửi cho bạn bè thật sự
      const ok = await pool.request()
        .input('uid', sql.Int, req.userId)
        .input('fid', sql.Int, fId)
        .query('SELECT 1 FROM UserFriends WHERE UserId = @uid AND FriendId = @fid');
      if (ok.recordset.length === 0) continue;

      await pool.request()
        .input('userId', sql.Int, fId)
        .input('title', sql.NVarChar, notifTitle)
        .input('body', sql.NVarChar, body)
        .input('icon', sql.NVarChar, icon)
        .query('INSERT INTO Notifications (UserId, Title, Body, Icon) VALUES (@userId, @title, @body, @icon)');
      sent++;
    }

    res.json({ message: `Đã chia sẻ với ${sent} người`, sent });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

async function attachTags(pool, tutorials) {
  if (tutorials.length === 0) return [];
  const ids = tutorials.map(t => t.Id).join(',');
  const tagsResult = await pool.request()
    .query(`SELECT TutorialId, Tag FROM TutorialTags WHERE TutorialId IN (${ids}) ORDER BY SortOrder`);
  const tagsMap = {};
  tagsResult.recordset.forEach(r => {
    if (!tagsMap[r.TutorialId]) tagsMap[r.TutorialId] = [];
    tagsMap[r.TutorialId].push(r.Tag);
  });
  return tutorials.map(t => ({ ...t, tags: tagsMap[t.Id] || [] }));
}

module.exports = router;
