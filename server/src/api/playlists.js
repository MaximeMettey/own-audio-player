import express from 'express';
import { v4 as uuidv4 } from 'uuid';
import { getDatabase } from '../models/database.js';

const router = express.Router();

// Get all playlists
router.get('/', (req, res) => {
  try {
    const db = getDatabase();
    const playlists = db.prepare(`
      SELECT * FROM playlists
      ORDER BY created_at DESC
    `).all();

    res.json({ data: playlists });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get playlist by ID
router.get('/:id', (req, res) => {
  try {
    const db = getDatabase();
    const { id } = req.params;

    const playlist = db.prepare('SELECT * FROM playlists WHERE id = ?').get(id);

    if (!playlist) {
      return res.status(404).json({ error: 'Playlist not found' });
    }

    // Get playlist tracks
    const tracks = db.prepare(`
      SELECT t.*, pt.position
      FROM tracks t
      JOIN playlist_tracks pt ON t.id = pt.track_id
      WHERE pt.playlist_id = ?
      ORDER BY pt.position ASC
    `).all(id);

    res.json({
      ...playlist,
      tracks
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create new playlist
router.post('/', (req, res) => {
  try {
    const db = getDatabase();
    const { name, description = '' } = req.body;

    if (!name || name.trim().length === 0) {
      return res.status(400).json({ error: 'Playlist name required' });
    }

    const id = uuidv4();

    db.prepare(`
      INSERT INTO playlists (id, name, description)
      VALUES (?, ?, ?)
    `).run(id, name.trim(), description.trim());

    const playlist = db.prepare('SELECT * FROM playlists WHERE id = ?').get(id);

    res.status(201).json(playlist);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update playlist
router.put('/:id', (req, res) => {
  try {
    const db = getDatabase();
    const { id } = req.params;
    const { name, description } = req.body;

    const playlist = db.prepare('SELECT * FROM playlists WHERE id = ?').get(id);

    if (!playlist) {
      return res.status(404).json({ error: 'Playlist not found' });
    }

    db.prepare(`
      UPDATE playlists
      SET name = ?, description = ?, updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `).run(name || playlist.name, description || playlist.description, id);

    const updated = db.prepare('SELECT * FROM playlists WHERE id = ?').get(id);

    res.json(updated);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete playlist
router.delete('/:id', (req, res) => {
  try {
    const db = getDatabase();
    const { id } = req.params;

    const result = db.prepare('DELETE FROM playlists WHERE id = ?').run(id);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Playlist not found' });
    }

    res.json({ message: 'Playlist deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add track to playlist
router.post('/:id/tracks', (req, res) => {
  try {
    const db = getDatabase();
    const { id } = req.params;
    const { track_id } = req.body;

    if (!track_id) {
      return res.status(400).json({ error: 'track_id required' });
    }

    // Check if playlist exists
    const playlist = db.prepare('SELECT * FROM playlists WHERE id = ?').get(id);
    if (!playlist) {
      return res.status(404).json({ error: 'Playlist not found' });
    }

    // Check if track exists
    const track = db.prepare('SELECT * FROM tracks WHERE id = ?').get(track_id);
    if (!track) {
      return res.status(404).json({ error: 'Track not found' });
    }

    // Get next position
    const maxPos = db.prepare(`
      SELECT MAX(position) as max_position
      FROM playlist_tracks
      WHERE playlist_id = ?
    `).get(id);

    const position = (maxPos.max_position || 0) + 1;

    // Add track to playlist
    db.prepare(`
      INSERT INTO playlist_tracks (playlist_id, track_id, position)
      VALUES (?, ?, ?)
      ON CONFLICT(playlist_id, track_id) DO NOTHING
    `).run(id, track_id, position);

    // Update playlist track count
    db.prepare(`
      UPDATE playlists
      SET track_count = (SELECT COUNT(*) FROM playlist_tracks WHERE playlist_id = ?),
          updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `).run(id, id);

    res.json({ message: 'Track added to playlist' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Remove track from playlist
router.delete('/:id/tracks/:trackId', (req, res) => {
  try {
    const db = getDatabase();
    const { id, trackId } = req.params;

    const result = db.prepare(`
      DELETE FROM playlist_tracks
      WHERE playlist_id = ? AND track_id = ?
    `).run(id, trackId);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Track not in playlist' });
    }

    // Update playlist track count
    db.prepare(`
      UPDATE playlists
      SET track_count = (SELECT COUNT(*) FROM playlist_tracks WHERE playlist_id = ?),
          updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `).run(id, id);

    res.json({ message: 'Track removed from playlist' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
