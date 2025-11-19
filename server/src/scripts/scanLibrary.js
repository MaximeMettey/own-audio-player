#!/usr/bin/env node

import dotenv from 'dotenv';
import { initDatabase } from '../models/database.js';
import { scanMusicLibrary } from '../services/libraryService.js';

dotenv.config();

async function main() {
  console.log('🎵 Own Audio Player - Library Scanner');
  console.log('═══════════════════════════════════════\n');

  const libraryPath = process.env.MUSIC_LIBRARY_PATH;

  if (!libraryPath) {
    console.error('❌ Error: MUSIC_LIBRARY_PATH not set in .env file');
    console.log('\nPlease add the following to your .env file:');
    console.log('MUSIC_LIBRARY_PATH=/path/to/your/music');
    process.exit(1);
  }

  try {
    console.log('Initializing database...');
    initDatabase();
    console.log('✓ Database initialized\n');

    console.log(`Scanning library: ${libraryPath}\n`);
    const results = await scanMusicLibrary(libraryPath);

    console.log('\n═══════════════════════════════════════');
    console.log('📊 Scan Results:');
    console.log('═══════════════════════════════════════');
    console.log(`Total files found:    ${results.total}`);
    console.log(`Successfully processed: ${results.processed}`);
    console.log(`Added to library:     ${results.added}`);
    console.log(`Errors:              ${results.errors}`);

    if (results.errors > 0) {
      console.log('\n❌ Files with errors:');
      results.errorFiles.forEach(({ file, error }) => {
        console.log(`  - ${file}`);
        console.log(`    Error: ${error}`);
      });
    }

    console.log('\n✓ Library scan complete!');
  } catch (error) {
    console.error('\n❌ Fatal error:', error.message);
    process.exit(1);
  }
}

main();
