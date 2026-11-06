'use strict';
/**
 * UNIONE API – point d'entrée
 *
 * GET /v1/catalogs  Retourne le fichier catalogs.json avec ETag.
 *                   L'app Flutter utilise If-None-Match pour éviter
 *                   de re-télécharger si le contenu n'a pas changé.
 */

require('dotenv').config();
const express = require('express');
const cors    = require('cors');
const fs      = require('fs');
const path    = require('path');
const crypto  = require('crypto');

const app  = express();
const PORT = process.env.PORT || 3000;

// Chemin vers le JSON des catalogues (par défaut : asset Flutter)
const CATALOGS_FILE = path.resolve(
  __dirname,
  process.env.CATALOGS_FILE || '../../assets/data/catalogs.json',
);

app.use(cors());
app.use(express.json());

// ---------------------------------------------------------------------------
// GET /v1/catalogs
// ---------------------------------------------------------------------------
app.get('/v1/catalogs', (req, res) => {
  let raw;
  try {
    raw = fs.readFileSync(CATALOGS_FILE, 'utf-8');
  } catch (err) {
    return res.status(503).json({ error: 'Catalogues indisponibles.', detail: err.message });
  }

  // ETag = MD5 du contenu (suffit pour la mise en cache Flutter)
  const etag = `"${crypto.createHash('md5').update(raw).digest('hex')}"`;

  if (req.headers['if-none-match'] === etag) {
    return res.status(304).end();
  }

  res.set({
    'Content-Type': 'application/json; charset=utf-8',
    'ETag': etag,
    'Cache-Control': 'public, max-age=3600', // 1 h – l'app revalide avec ETag
  });

  return res.send(raw);
});

// Sanity check
app.get('/health', (_req, res) => res.json({ status: 'ok' }));

app.listen(PORT, () => {
  console.log(`UNIONE API démarrée sur http://localhost:${PORT}`);
  console.log(`  GET /v1/catalogs  →  ${CATALOGS_FILE}`);
});
