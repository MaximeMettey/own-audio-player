import express from 'express';
import { scanMusicLibrary, getStats } from '../services/libraryService.js';

const router = express.Router();

let isScanning = false;

// Scan music library
router.get('/scan', async (req, res) => {
  if (isScanning) {
    return res.status(409).json({ error: 'Scan already in progress' });
  }

  const libraryPath = process.env.MUSIC_LIBRARY_PATH;

  if (!libraryPath) {
    return res.status(400).json({
      error: 'MUSIC_LIBRARY_PATH not configured',
      message: 'Please set MUSIC_LIBRARY_PATH in your .env file'
    });
  }

  try {
    isScanning = true;
    res.json({
      message: 'Library scan started',
      path: libraryPath
    });

    // Run scan in background
    scanMusicLibrary(libraryPath)
      .then(results => {
        console.log('Scan completed:', results);
      })
      .catch(error => {
        console.error('Scan error:', error);
      })
      .finally(() => {
        isScanning = false;
      });
  } catch (error) {
    isScanning = false;
    res.status(500).json({ error: error.message });
  }
});

// Get library stats
router.get('/stats', (req, res) => {
  try {
    const stats = getStats();
    res.json({
      ...stats,
      scanning: isScanning
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get scan status
router.get('/scan/status', (req, res) => {
  res.json({
    scanning: isScanning
  });
});

export default router;
