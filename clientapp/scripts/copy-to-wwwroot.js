#!/usr/bin/env node
import fs from 'fs-extra';
import path from 'path';
import minimist from 'minimist';
import { fileURLToPath } from 'url';

// Read destination from environment variable or CLI arg
const argv = minimist(process.argv.slice(2));
const envDest = process.env.WWWROOT || process.env.APP_WWWROOT;
const cliDest = argv.dest || argv.d;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const defaultRelative = path.join(__dirname, '..', '..', 'server', 'wwwroot');
const dest = path.resolve(cliDest || envDest || defaultRelative);
const src = path.resolve(path.join(__dirname, '..', 'dist'));

async function copy() {
  try {
    if (!await fs.pathExists(src)) {
      console.error(`Build output not found: ${src}`);
      process.exit(2);
    }

    // Make sure destination exists
    await fs.ensureDir(dest);

    // Remove all files in destination (but not the folder itself)
    const destFiles = await fs.readdir(dest);
    for (const f of destFiles) {
      await fs.remove(path.join(dest, f));
    }

    // Copy contents of dist into dest
    await fs.copy(src, dest, { overwrite: true, recursive: true });

    console.log(`Copied build from ${src} -> ${dest}`);
  } catch (err) {
    console.error('Failed to copy build to wwwroot:', err);
    process.exit(1);
  }
}

copy();
