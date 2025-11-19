import fs from 'fs';
import path from 'path';
import { parseFile } from 'music-metadata';
import { v4 as uuidv4 } from 'uuid';
import { getDatabase } from '../models/database.js';
import crypto from 'crypto';

const SUPPORTED_FORMATS = ['.mp3', '.flac', '.ogg', '.m4a', '.wav', '.aac', '.opus'];

function generateId(str) {
  return crypto.createHash('md5').update(str).digest('hex');
}

export async function scanMusicLibrary(libraryPath) {
  if (!libraryPath || !fs.existsSync(libraryPath)) {
    throw new Error(`Invalid library path: ${libraryPath}`);
  }

  console.log(`Scanning music library: ${libraryPath}`);

  const db = getDatabase();
  const files = await findAudioFiles(libraryPath);

  console.log(`Found ${files.length} audio files`);

  const results = {
    total: files.length,
    processed: 0,
    added: 0,
    updated: 0,
    errors: 0,
    errorFiles: []
  };

  // Clear existing data (for fresh scan)
  db.prepare('DELETE FROM playlist_tracks').run();
  db.prepare('DELETE FROM tracks').run();
  db.prepare('DELETE FROM albums').run();
  db.prepare('DELETE FROM artists').run();

  for (const filePath of files) {
    try {
      await processAudioFile(filePath, db);
      results.processed++;
      results.added++;

      if (results.processed % 10 === 0) {
        console.log(`Processed ${results.processed}/${files.length} files...`);
      }
    } catch (error) {
      console.error(`Error processing ${filePath}:`, error.message);
      results.errors++;
      results.errorFiles.push({ file: filePath, error: error.message });
    }
  }

  // Update counts
  updateCounts(db);

  console.log('Scan complete:', results);
  return results;
}

async function findAudioFiles(dir) {
  const files = [];

  async function walk(directory) {
    const items = fs.readdirSync(directory);

    for (const item of items) {
      const fullPath = path.join(directory, item);
      const stat = fs.statSync(fullPath);

      if (stat.isDirectory()) {
        await walk(fullPath);
      } else if (stat.isFile()) {
        const ext = path.extname(item).toLowerCase();
        if (SUPPORTED_FORMATS.includes(ext)) {
          files.push(fullPath);
        }
      }
    }
  }

  await walk(dir);
  return files;
}

async function processAudioFile(filePath, db) {
  const metadata = await parseFile(filePath);
  const stats = fs.statSync(filePath);

  const { common, format } = metadata;

  // Extract metadata
  const title = common.title || path.basename(filePath, path.extname(filePath));
  const artistName = common.artist || common.albumartist || 'Unknown Artist';
  const albumName = common.album || 'Unknown Album';
  const duration = Math.floor(format.duration || 0);
  const trackNumber = common.track?.no || null;
  const discNumber = common.disk?.no || 1;
  const year = common.year || null;
  const genre = common.genre?.join(', ') || null;

  // Generate IDs
  const artistId = generateId(artistName.toLowerCase());
  const albumId = generateId(`${artistName.toLowerCase()}_${albumName.toLowerCase()}`);
  const trackId = generateId(filePath);

  // Insert or update artist
  db.prepare(`
    INSERT INTO artists (id, name)
    VALUES (?, ?)
    ON CONFLICT(id) DO NOTHING
  `).run(artistId, artistName);

  // Insert or update album
  db.prepare(`
    INSERT INTO albums (id, title, artist_id, artist_name, year)
    VALUES (?, ?, ?, ?, ?)
    ON CONFLICT(id) DO UPDATE SET
      year = COALESCE(excluded.year, year)
  `).run(albumId, albumName, artistId, artistName, year);

  // Insert track
  db.prepare(`
    INSERT INTO tracks (
      id, title, artist_id, artist_name, album_id, album_name,
      duration, track_number, disc_number, year, genre,
      file_path, file_size, bitrate, sample_rate, format
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(file_path) DO UPDATE SET
      title = excluded.title,
      artist_name = excluded.artist_name,
      album_name = excluded.album_name,
      duration = excluded.duration,
      track_number = excluded.track_number,
      year = excluded.year,
      genre = excluded.genre,
      file_size = excluded.file_size,
      bitrate = excluded.bitrate
  `).run(
    trackId,
    title,
    artistId,
    artistName,
    albumId,
    albumName,
    duration,
    trackNumber,
    discNumber,
    year,
    genre,
    filePath,
    stats.size,
    format.bitrate || null,
    format.sampleRate || null,
    format.container || null
  );
}

function updateCounts(db) {
  // Update artist counts
  db.prepare(`
    UPDATE artists
    SET
      album_count = (SELECT COUNT(DISTINCT album_id) FROM tracks WHERE artist_id = artists.id),
      track_count = (SELECT COUNT(*) FROM tracks WHERE artist_id = artists.id)
  `).run();

  // Update album counts and duration
  db.prepare(`
    UPDATE albums
    SET
      track_count = (SELECT COUNT(*) FROM tracks WHERE album_id = albums.id),
      duration = (SELECT SUM(duration) FROM tracks WHERE album_id = albums.id)
  `).run();
}

export function getStats() {
  const db = getDatabase();

  const stats = db.prepare(`
    SELECT
      (SELECT COUNT(*) FROM artists) as artists,
      (SELECT COUNT(*) FROM albums) as albums,
      (SELECT COUNT(*) FROM tracks) as tracks,
      (SELECT COUNT(*) FROM playlists) as playlists,
      (SELECT SUM(duration) FROM tracks) as total_duration,
      (SELECT SUM(file_size) FROM tracks) as total_size
  `).get();

  return stats;
}
