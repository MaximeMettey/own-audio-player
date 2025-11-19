import express from 'express';
import fs from 'fs';
import { getDatabase } from '../models/database.js';

const router = express.Router();

// Stream audio file
router.get('/:id', (req, res) => {
  try {
    const db = getDatabase();
    const { id } = req.params;

    // Get track info
    const track = db.prepare('SELECT * FROM tracks WHERE id = ?').get(id);

    if (!track) {
      return res.status(404).json({ error: 'Track not found' });
    }

    if (!fs.existsSync(track.file_path)) {
      return res.status(404).json({ error: 'Audio file not found on disk' });
    }

    const stat = fs.statSync(track.file_path);
    const fileSize = stat.size;
    const range = req.headers.range;

    if (range) {
      // Parse Range header
      const parts = range.replace(/bytes=/, '').split('-');
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
      const chunkSize = (end - start) + 1;

      // Create read stream
      const stream = fs.createReadStream(track.file_path, { start, end });

      // Set headers for partial content
      res.writeHead(206, {
        'Content-Range': `bytes ${start}-${end}/${fileSize}`,
        'Accept-Ranges': 'bytes',
        'Content-Length': chunkSize,
        'Content-Type': getContentType(track.format),
        'Cache-Control': 'public, max-age=3600'
      });

      stream.pipe(res);
    } else {
      // Stream entire file
      res.writeHead(200, {
        'Content-Length': fileSize,
        'Content-Type': getContentType(track.format),
        'Accept-Ranges': 'bytes',
        'Cache-Control': 'public, max-age=3600'
      });

      const stream = fs.createReadStream(track.file_path);
      stream.pipe(res);
    }
  } catch (error) {
    console.error('Streaming error:', error);
    res.status(500).json({ error: error.message });
  }
});

function getContentType(format) {
  const contentTypes = {
    'mp3': 'audio/mpeg',
    'MPEG': 'audio/mpeg',
    'flac': 'audio/flac',
    'FLAC': 'audio/flac',
    'ogg': 'audio/ogg',
    'Ogg': 'audio/ogg',
    'm4a': 'audio/mp4',
    'mp4': 'audio/mp4',
    'wav': 'audio/wav',
    'WAVE': 'audio/wav',
    'aac': 'audio/aac',
    'opus': 'audio/opus'
  };

  return contentTypes[format] || 'audio/mpeg';
}

export default router;
