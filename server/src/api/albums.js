import express from 'express';
import { getDatabase } from '../models/database.js';

const router = express.Router();

// Get all albums
router.get('/', (req, res) => {
  try {
    const db = getDatabase();
    const { limit = 50, offset = 0, sort = 'title' } = req.query;

    const validSorts = ['title', 'artist_name', 'year', 'track_count', 'created_at'];
    const sortField = validSorts.includes(sort) ? sort : 'title';

    const albums = db.prepare(`
      SELECT *
      FROM albums
      ORDER BY ${sortField} ASC
      LIMIT ? OFFSET ?
    `).all(parseInt(limit), parseInt(offset));

    const total = db.prepare('SELECT COUNT(*) as count FROM albums').get();

    res.json({
      data: albums,
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

// Get album by ID
router.get('/:id', (req, res) => {
  try {
    const db = getDatabase();
    const { id } = req.params;

    const album = db.prepare('SELECT * FROM albums WHERE id = ?').get(id);

    if (!album) {
      return res.status(404).json({ error: 'Album not found' });
    }

    // Get album's tracks
    const tracks = db.prepare(`
      SELECT * FROM tracks
      WHERE album_id = ?
      ORDER BY disc_number ASC, track_number ASC
    `).all(id);

    res.json({
      ...album,
      tracks
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get album's tracks
router.get('/:id/tracks', (req, res) => {
  try {
    const db = getDatabase();
    const { id } = req.params;

    const tracks = db.prepare(`
      SELECT * FROM tracks
      WHERE album_id = ?
      ORDER BY disc_number ASC, track_number ASC
    `).all(id);

    res.json({ data: tracks });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
