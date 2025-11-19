import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

import { initDatabase } from './models/database.js';
import artistsRouter from './api/artists.js';
import albumsRouter from './api/albums.js';
import tracksRouter from './api/tracks.js';
import streamRouter from './api/stream.js';
import libraryRouter from './api/library.js';
import searchRouter from './api/search.js';
import playlistsRouter from './api/playlists.js';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;
const API_PREFIX = process.env.API_PREFIX || '/api';

// Middleware
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS || '*',
  credentials: true
}));
app.use(compression());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Initialize database
try {
  initDatabase();
  console.log('✓ Database initialized successfully');
} catch (error) {
  console.error('✗ Failed to initialize database:', error);
  process.exit(1);
}

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// API Routes
app.use(`${API_PREFIX}/artists`, artistsRouter);
app.use(`${API_PREFIX}/albums`, albumsRouter);
app.use(`${API_PREFIX}/tracks`, tracksRouter);
app.use(`${API_PREFIX}/stream`, streamRouter);
app.use(`${API_PREFIX}/library`, libraryRouter);
app.use(`${API_PREFIX}/search`, searchRouter);
app.use(`${API_PREFIX}/playlists`, playlistsRouter);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Start server
app.listen(PORT, () => {
  console.log('');
  console.log('🎵 Own Audio Player Server');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📡 API endpoint: http://localhost:${PORT}${API_PREFIX}`);
  console.log(`📚 Music library: ${process.env.MUSIC_LIBRARY_PATH || 'Not configured'}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('');
  console.log('Available endpoints:');
  console.log(`  GET  ${API_PREFIX}/library/scan - Scan music library`);
  console.log(`  GET  ${API_PREFIX}/artists - List all artists`);
  console.log(`  GET  ${API_PREFIX}/albums - List all albums`);
  console.log(`  GET  ${API_PREFIX}/tracks - List all tracks`);
  console.log(`  GET  ${API_PREFIX}/stream/:id - Stream a track`);
  console.log(`  GET  ${API_PREFIX}/search?q=... - Search library`);
  console.log('');
});

export default app;
