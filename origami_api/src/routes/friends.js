const express = require('express');
const { getPool, sql } = require('../config/database');
const auth = require('../middleware/auth');

const router = express.Router();

// GET /api/friends
router.get('/', auth, async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('userId', sql.Int, req.userId)
      .query(`SELECT u.Id, u.FullName, u.Nickname, u.Email, u.AvatarInitials, u.AvatarColor,
                     (SELECT COUNT(*) FROM UserOrigami WHERE UserId = u.Id) AS Completed
              FROM UserFriends uf
              JOIN Users u ON u.Id = uf.FriendId
              WHERE uf.UserId = @userId
              ORDER BY u.FullName`);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// GET /api/friends/search?name=... — tìm user theo nickname
router.get('/search', auth, async (req, res) => {
  const { name } = req.query;
  if (!name || name.trim().length < 1) return res.json([]);
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('userId', sql.Int, req.userId)
      .input('name', sql.NVarChar, `%${name.trim()}%`)
      .query(`SELECT u.Id, u.FullName, u.Nickname, u.Email, u.AvatarInitials, u.AvatarColor,
                     (SELECT COUNT(*) FROM UserOrigami WHERE UserId = u.Id) AS Completed,
                     CASE WHEN EXISTS (
                       SELECT 1 FROM FriendRequests fr
                       WHERE fr.SenderId = @userId AND fr.ReceiverId = u.Id AND fr.Status = 'pending'
                     ) THEN 1 ELSE 0 END AS HasPendingRequest
              FROM Users u
              WHERE u.Id != @userId
                AND u.Nickname LIKE @name
                AND NOT EXISTS (
                  SELECT 1 FROM UserFriends uf
                  WHERE uf.UserId = @userId AND uf.FriendId = u.Id
                )
              ORDER BY u.Nickname`);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// GET /api/friends/requests — lời mời kết bạn đang chờ (tôi nhận được)
router.get('/requests', auth, async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('userId', sql.Int, req.userId)
      .query(`SELECT fr.Id, fr.CreatedAt,
                     u.Id AS SenderId, u.FullName, u.Nickname, u.AvatarInitials, u.AvatarColor,
                     (SELECT COUNT(*) FROM UserOrigami WHERE UserId = u.Id) AS Completed
              FROM FriendRequests fr
              JOIN Users u ON u.Id = fr.SenderId
              WHERE fr.ReceiverId = @userId AND fr.Status = 'pending'
              ORDER BY fr.CreatedAt DESC`);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// POST /api/friends/request — gửi lời mời kết bạn
router.post('/request', auth, async (req, res) => {
  const { friendId } = req.body;
  if (!friendId) return res.status(400).json({ message: 'Thiếu friendId' });
  const fId = parseInt(friendId, 10);
  if (fId === req.userId)
    return res.status(400).json({ message: 'Không thể kết bạn với chính mình' });
  try {
    const pool = await getPool();

    const alreadyFriends = await pool.request()
      .input('userId', sql.Int, req.userId)
      .input('friendId', sql.Int, fId)
      .query('SELECT 1 FROM UserFriends WHERE UserId=@userId AND FriendId=@friendId');
    if (alreadyFriends.recordset.length > 0)
      return res.status(409).json({ message: 'Đã là bạn bè' });

    const alreadySent = await pool.request()
      .input('senderId', sql.Int, req.userId)
      .input('receiverId', sql.Int, fId)
      .query(`SELECT 1 FROM FriendRequests WHERE SenderId=@senderId AND ReceiverId=@receiverId AND Status='pending'`);
    if (alreadySent.recordset.length > 0)
      return res.status(409).json({ message: 'Đã gửi lời mời rồi' });

    const senderResult = await pool.request()
      .input('userId', sql.Int, req.userId)
      .query('SELECT FullName, Nickname FROM Users WHERE Id=@userId');
    const sender = senderResult.recordset[0];
    const displayName = sender.Nickname || sender.FullName;

    await pool.request()
      .input('senderId', sql.Int, req.userId)
      .input('receiverId', sql.Int, fId)
      .query(`INSERT INTO FriendRequests (SenderId, ReceiverId) VALUES (@senderId, @receiverId)`);

    await pool.request()
      .input('userId', sql.Int, fId)
      .input('title', sql.NVarChar, 'Lời mời kết bạn')
      .input('body', sql.NVarChar, `${displayName} muốn kết bạn với bạn`)
      .input('icon', sql.NVarChar, 'person_add')
      .query('INSERT INTO Notifications (UserId, Title, Body, Icon) VALUES (@userId, @title, @body, @icon)');

    res.json({ message: 'Đã gửi lời mời kết bạn!' });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// POST /api/friends/requests/:id/accept — chấp nhận lời mời
router.post('/requests/:id/accept', auth, async (req, res) => {
  try {
    const pool = await getPool();
    const reqResult = await pool.request()
      .input('id', sql.Int, req.params.id)
      .input('userId', sql.Int, req.userId)
      .query(`SELECT SenderId, ReceiverId FROM FriendRequests WHERE Id=@id AND ReceiverId=@userId AND Status='pending'`);
    if (reqResult.recordset.length === 0)
      return res.status(404).json({ message: 'Không tìm thấy lời mời' });

    const { SenderId, ReceiverId } = reqResult.recordset[0];
    await pool.request()
      .input('userId', sql.Int, SenderId)
      .input('friendId', sql.Int, ReceiverId)
      .query(`IF NOT EXISTS (SELECT 1 FROM UserFriends WHERE UserId=@userId AND FriendId=@friendId)
              BEGIN
                INSERT INTO UserFriends (UserId, FriendId) VALUES (@userId, @friendId);
                INSERT INTO UserFriends (UserId, FriendId) VALUES (@friendId, @userId);
              END`);

    await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM FriendRequests WHERE Id=@id');

    res.json({ message: 'Đã chấp nhận lời mời kết bạn!' });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// DELETE /api/friends/requests/:id — từ chối hoặc huỷ lời mời
router.delete('/requests/:id', auth, async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .input('userId', sql.Int, req.userId)
      .query('DELETE FROM FriendRequests WHERE Id=@id AND (ReceiverId=@userId OR SenderId=@userId)');
    res.json({ message: 'Đã từ chối lời mời' });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// DELETE /api/friends/:friendId
router.delete('/:friendId', auth, async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('userId', sql.Int, req.userId)
      .input('friendId', sql.Int, req.params.friendId)
      .query(`DELETE FROM UserFriends WHERE (UserId=@userId AND FriendId=@friendId)
              OR (UserId=@friendId AND FriendId=@userId)`);
    res.json({ message: 'Đã xoá bạn bè' });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

module.exports = router;
