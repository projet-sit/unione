# UNIONE API – Backend Node.js

Serveur Express minimal qui expose les catalogues de forfaits à l'app Flutter UNIONE.

## Structure

```
server/
├── src/
│   └── server.js          # Point d'entrée Express
├── scripts/
│   └── import_catalogs.js # Import CSV → catalogs.json
├── package.json
└── .env.example
```

## Démarrage

```bash
cd server
npm install
cp .env.example .env      # ajuster si besoin
npm run dev               # nodemon (rechargement auto)
# ou
npm start                 # production
```

## Endpoint

### `GET /v1/catalogs`

Retourne le contenu de `catalogs.json` avec un **ETag** (MD5 du contenu).  
L'app Flutter envoie `If-None-Match: <etag>` → `304 Not Modified` si pas de changement.

```
Cache-Control: public, max-age=3600
ETag: "abc123..."
Content-Type: application/json
```

### `GET /health`

```json
{ "status": "ok" }
```

## Mettre à jour les tarifs depuis un CSV

1. Prépare un fichier CSV avec les colonnes :

```
catalogId,operator,catalogLabel,tabId,tabLabel,offerId,title,validityLabel,priceInt,badges,hint,confidence,verifiedAt
```

> Sépare plusieurs badges avec `|` dans la colonne `badges`.

2. Lance le script :

```bash
npm run import -- mon_fichier.csv
# ou vers un fichier de sortie différent :
node scripts/import_catalogs.js mon_fichier.csv --output /chemin/vers/catalogs.json
```

3. Le script **fusionne** les données CSV avec le JSON existant :  
   - Les champs `launch`, `payWith`, `source` (remplis manuellement) sont **préservés**.  
   - Les offres existantes sont mises à jour ; les nouvelles sont ajoutées.  
   - La version est incrémentée automatiquement.

4. Redémarre l'API (ou `nodemon` le fait tout seul) → l'ETag change → Flutter re-télécharge.

## Variables d'environnement

| Variable        | Défaut                              | Description                        |
|-----------------|-------------------------------------|------------------------------------|
| `PORT`          | `3000`                              | Port d'écoute                      |
| `CATALOGS_FILE` | `../assets/data/catalogs.json`      | Chemin vers le JSON des catalogues |

## Déploiement

Ce serveur est **stateless** (lit un fichier JSON à chaque requête).  
Il peut tourner sur n'importe quel hébergeur Node.js (Railway, Render, VPS…).  
Pour la prod, pointe `CATALOGS_FILE` vers un fichier hors du dépôt Git,  
ou remplace la lecture par une base de données.
