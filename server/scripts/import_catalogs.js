#!/usr/bin/env node
'use strict';
/**
 * import_catalogs.js – convertit un CSV d'offres en JSON catalogs.json
 *
 * Usage :
 *   node scripts/import_catalogs.js <fichier.csv> [--output <dest.json>]
 *
 * Format CSV attendu (séparateur virgule, première ligne = en-têtes) :
 *   catalogId, operator, catalogLabel, tabId, tabLabel,
 *   offerId, title, validityLabel, priceInt, badges, hint, confidence, verifiedAt
 *
 * Exemple de ligne :
 *   celtiis_connect,celtiis,Forfaits Internet,daily,Quotidien,
 *   celtiis_connect_500,1 Go,24 heures,500,"WhatsApp gratuit,TikTok gratuit",
 *   Choisissez Connect 500,official,2026-11-06
 *
 * Le script :
 *   1. Lit le CSV
 *   2. Regroupe les offres par catalogId / tabId
 *   3. Fusionne avec le JSON existant (conserve les champs non couverts : launch, payWith, source)
 *   4. Écrit le résultat dans --output (défaut : ../assets/data/catalogs.json)
 *
 * Les champs launch, payWith et source doivent être édités manuellement
 * dans le JSON existant – ils ne figurent pas dans le CSV.
 */

const fs   = require('fs');
const path = require('path');

// ── Parsing des arguments ────────────────────────────────────────────────────
const args   = process.argv.slice(2);
const csvArg = args.find(a => !a.startsWith('--'));
const outIdx = args.indexOf('--output');
const OUTPUT = outIdx !== -1
  ? path.resolve(args[outIdx + 1])
  : path.resolve(__dirname, '../../assets/data/catalogs.json');

if (!csvArg) {
  console.error('Usage : node scripts/import_catalogs.js <fichier.csv> [--output <dest.json>]');
  process.exit(1);
}

const CSV_FILE = path.resolve(csvArg);

// ── Lecture CSV ──────────────────────────────────────────────────────────────
const lines = fs.readFileSync(CSV_FILE, 'utf-8')
  .split(/\r?\n/)
  .filter(l => l.trim() && !l.startsWith('#'));

const headers = parseCsvLine(lines[0]);
const rows    = lines.slice(1).map(l => {
  const vals = parseCsvLine(l);
  return Object.fromEntries(headers.map((h, i) => [h.trim(), (vals[i] ?? '').trim()]));
});

// ── Construction du JSON ─────────────────────────────────────────────────────
// Lecture du JSON existant pour préserver launch, payWith, source, etc.
let existing = { version: 1, catalogs: {} };
if (fs.existsSync(OUTPUT)) {
  try { existing = JSON.parse(fs.readFileSync(OUTPUT, 'utf-8')); } catch (_) {}
}

for (const row of rows) {
  const {
    catalogId, operator, catalogLabel,
    tabId, tabLabel,
    offerId, title, validityLabel, priceInt, badges, hint, confidence, verifiedAt,
  } = row;

  if (!catalogId || !offerId) continue;

  // Initialise le catalogue s'il n'existe pas
  if (!existing.catalogs[catalogId]) {
    existing.catalogs[catalogId] = {
      operator: operator || 'unknown',
      label: catalogLabel || catalogId,
      tabs: [],
      launch: { mode: 'direct', code: '' }, // à remplir manuellement
      offers: [],
    };
  }

  const cat = existing.catalogs[catalogId];

  // Mise à jour du label / operator
  if (operator)      cat.operator = operator;
  if (catalogLabel)  cat.label    = catalogLabel;
  if (verifiedAt)    cat.verifiedAt = verifiedAt;

  // Onglet
  if (tabId && !cat.tabs.find(t => t.id === tabId)) {
    cat.tabs.push({ id: tabId, label: tabLabel || tabId });
  }

  // Offre : mise à jour ou ajout
  const existingOffer = cat.offers.find(o => o.id === offerId);
  const badgesArr = badges ? badges.split('|').map(b => b.trim()).filter(Boolean) : [];
  const offer = {
    id:            offerId,
    tab:           tabId,
    price:         parseInt(priceInt, 10) || 0,
    title:         title || offerId,
    validityLabel: validityLabel || '',
    ...(badgesArr.length && { badges: badgesArr }),
    ...(hint && { hint }),
    confidence:    confidence || 'to_test',
  };

  if (existingOffer) {
    Object.assign(existingOffer, offer);
  } else {
    cat.offers.push(offer);
  }
}

// Incrémente la version
existing.version = (existing.version || 1) + 1;

fs.writeFileSync(OUTPUT, JSON.stringify(existing, null, 2), 'utf-8');
console.log(`✓ ${rows.length} ligne(s) traitées → ${OUTPUT} (version ${existing.version})`);

// ── Utilitaire CSV simple (gère les guillemets) ──────────────────────────────
function parseCsvLine(line) {
  const result = [];
  let cur = '';
  let inQuote = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === '"') {
      if (inQuote && line[i + 1] === '"') { cur += '"'; i++; }
      else inQuote = !inQuote;
    } else if (ch === ',' && !inQuote) {
      result.push(cur); cur = '';
    } else {
      cur += ch;
    }
  }
  result.push(cur);
  return result;
}
