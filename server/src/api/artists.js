import express from 'express';
import { getDatabase } from '../models/database.js';

const router = express.Router();

// Get all artists
router.get('/', (req, res) => {
  try {
    const db = getDatabase();
    const { limit = 50, offset = 0, sort = 'name' } = req.query;

    const validSorts = ['name', 'album_count', 'track_count', 'created_at'];
    const sortField = validSorts.includes(sort) ? sort : 'name';

    const artists = db.prepare(`
      SELECT *
      FROM artists
      ORDER BY ${sortField} ASC
      LIMIT ? OFFSET ?
    `).all(parseInt(limit), parseInt(offset));

    const total = db.prepare('SELECT COUNT(*) as count FROM artists').get();

    res.json({
      data: artists,
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

// Get artist by ID
router.get('/:id', (req, res) => {
  try {
    const db = getDatabase();
    const { id } = req.params;

    const artist = db.prepare('SELECT * FROM artists WHERE id = ?').get(id);

    if (!artist) {
      return res.status(404).json({ error: 'Artist not found' });
    }

    // Get artist's albums
    const albums = db.prepare(`
      SELECT * FROM albums
      WHERE artist_id = ?
      ORDER BY year DESC, title ASC
    `).all(id);

    // Get artist's top tracks
    const tracks = db.prepare(`
      SELECT * FROM tracks
      WHERE artist_id = ?
      ORDER BY track_number ASC
      LIMIT 20
    `).all(id);

    res.json({
      ...artist,
      albums,
      tracks
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get artist's albums
router.get('/:id/albums', (req, res) => {
  try {
    const db = getDatabase();
    const { id } = req.params;

    const albums = db.prepare(`
      SELECT * FROM albums
      WHERE artist_id = ?
      ORDER BY year DESC, title ASC
    `).all(id);

    res.json({ data: albums });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get artist's tracks
router.get('/:id/tracks', (req, res) => {
  try {
    const db = getDatabase();
    const { id } = req.params;

    const tracks = db.prepare(`
      SELECT * FROM tracks
      WHERE artist_id = ?
      ORDER BY album_name, disc_number, track_number ASC
    `).all(id);

    res.json({ data: tracks });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
