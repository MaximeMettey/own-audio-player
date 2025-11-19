import express from 'express';
import { getDatabase } from '../models/database.js';

const router = express.Router();

// Get all tracks
router.get('/', (req, res) => {
  try {
    const db = getDatabase();
    const { limit = 50, offset = 0, sort = 'title' } = req.query;

    const validSorts = ['title', 'artist_name', 'album_name', 'duration', 'year', 'created_at'];
    const sortField = validSorts.includes(sort) ? sort : 'title';

    const tracks = db.prepare(`
      SELECT *
      FROM tracks
      ORDER BY ${sortField} ASC
      LIMIT ? OFFSET ?
    `).all(parseInt(limit), parseInt(offset));

    const total = db.prepare('SELECT COUNT(*) as count FROM tracks').get();

    res.json({
      data: tracks,
      pagination: {
        total: total.count,
        limit: parseInt(limit),
        offset: parseInt(offset)
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get track by ID
router.get('/:id', (req, res) => {
  try {
    const db = getDatabase();
    const { id } = req.params;

    const track = db.prepare('SELECT * FROM tracks WHERE id = ?').get(id);

    if (!track) {
      return res.status(404).json({ error: 'Track not found' });
    }

    res.json(track);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get random tracks
router.get('/random/tracks', (req, res) => {
  try {
    const db = getDatabase();
    const { limit = 20 } = req.query;

    const tracks = db.prepare(`
      SELECT *
      FROM tracks
      ORDER BY RANDOM()
      LIMIT ?
    `).all(parseInt(limit));

    res.json({ data: tracks });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
