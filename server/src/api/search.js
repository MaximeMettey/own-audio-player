import express from 'express';
import { getDatabase } from '../models/database.js';

const router = express.Router();

// Search across all entities
router.get('/', (req, res) => {
  try {
    const db = getDatabase();
    const { q, limit = 20 } = req.query;

    if (!q || q.trim().length === 0) {
      return res.status(400).json({ error: 'Search query required' });
    }

    const searchTerm = `%${q.trim()}%`;
    const limitInt = parseInt(limit);

    // Search artists
    const artists = db.prepare(`
      SELECT * FROM artists
      WHERE name LIKE ?
      ORDER BY name ASC
      LIMIT ?
    `).all(searchTerm, limitInt);

    // Search albums
    const albums = db.prepare(`
      SELECT * FROM albums
      WHERE title LIKE ? OR artist_name LIKE ?
      ORDER BY title ASC
      LIMIT ?
    `).all(searchTerm, searchTerm, limitInt);

    // Search tracks
    const tracks = db.prepare(`
      SELECT * FROM tracks
      WHERE title LIKE ? OR artist_name LIKE ? OR album_name LIKE ?
      ORDER BY title ASC
      LIMIT ?
    `).all(searchTerm, searchTerm, searchTerm, limitInt);

    // Search playlists
    const playlists = db.prepare(`
      SELECT * FROM playlists
      WHERE name LIKE ? OR description LIKE ?
      ORDER BY name ASC
      LIMIT ?
    `).all(searchTerm, searchTerm, limitInt);

    res.json({
      query: q,
      results: {
        artists,
        albums,
        tracks,
        playlists
      },
      counts: {
        artists: artists.length,
        albums: albums.length,
        tracks: tracks.length,
        playlists: playlists.length,
        total: artists.length + albums.length + tracks.length + playlists.length
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
