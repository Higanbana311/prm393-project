const express = require('express');
const { getPool } = require('../config/database');

const router = express.Router();

// GET /api/categories
router.get('/', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .query(`SELECT c.*,
                (SELECT COUNT(*) FROM Tutorials t WHERE t.CategoryId = c.Id) AS Count
              FROM Categories c ORDER BY c.Id`);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

module.exports = router;
