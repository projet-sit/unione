# Différences et Concordance des Codes USSD (CODES_DIFF.md)

Ce document recense les correspondances, sources et écarts relevés entre les codes embarqués dans l'application UNIONE, la documentation officielle et les sources tierces.

---

## 1. Celtiis Bénin

| Service | Code officiel / App | Source | Statut / Confiance | Remarques |
|---|---|---|---|---|
| Forfaits Internet (Connect) | `*199*2#` | Celtiis Officiel (06/11/2026) | `official` | Mode `menu`. Suivi consommation : `*104#` puis compteur Internet Connect. |
| Internet IllimiNet | `*199*4#` | Celtiis Officiel (06/11/2026) | `official` | Mode `menu`. Ancienne source rapportait `*199*8#`. Suivi : `*104*2*2*4#`. Débit 2 Mb/s garanti après volume. |
| Forfaits Top Appel | `*199*1*2#` | Celtiis Officiel (06/11/2026) | `official` | Mode `menu`. Crédit d'appel + SMS tous réseaux nationaux. Suivi : `*104#`. |
| Forfaits MyMix | `*199*3#` | Celtiis Officiel (06/11/2026) | `official` | Mode `menu`. Voix + SMS + Data. Suivi : `*104#`. |
| Pass Chrono / Roaming / Hello | `*199#` | Celtiis Officiel | `to_test` | Nœuds USSD avec indication pour naviguer dans le menu principal. |
| Solde principal | `*104*1*1#` | Code existant app | `medium` | À tester sur SIM pour confirmation du palier direct. |
| Service client | `7373` | Celtiis Officiel | `official` | Appel vocal direct (launchKind: `call`). |

---

## 2. Moov Africa Bénin

| Service | Code officiel / App | Source | Statut / Confiance | Remarques |
|---|---|---|---|---|
| Forfaits Internet (Volume) | `*123#` | Moov Officiel (06/11/2026) | `official` | Mode `menu`. Compatible paiement par Moov Money via `*855*3*2#`. |
| Internet Illimité | `*123*5#` | Moov Officiel (06/11/2026) | `official` | Mode `menu`. Paliers 15 000 F à 50 000 F, 24,41 Go+ à 81,38 Go+, 30 jours. Débits après épuisement à vérifier sur SIM. |
| Internet Secours | `*123*9#` | Moov Officiel (07/11/2026) | `official` | Mode `menu`. Emprunt 75 Mo / 170 Mo / 450 Mo, remboursement 100 / 220 / 550 FCFA (24 h / 24 h / 3 jours). |
| Moov Combo | `*173*{price}#` | Moov Officiel (06/11/2026) | `official` | Mode `direct`. Formule voix + sms + data. |
| Moov Pass Bonus | `*173*1*{price}#` | Moov Officiel (07/11/2026) | `official` | Mode `direct`. 100 F → 165, 150 F → 250, 200 F → 335, 500 F → 840, 1 000 F → 1 660, 2 500 F → 4 150, 5 000 F → 8 400. Consultation solde : `*173*5*2#`. |
| Moov Money Achat Forfait | `*855*3*2#` | Moov Officiel | `official` | Paiement d'un forfait via Moov Money. |
| Solde principal | `*104#` | Moov Officiel | `official` | Code direct standard. |

---

## 3. MTN Bénin

| Service | Code officiel / App | Source | Statut / Confiance | Remarques |
|---|---|---|---|---|
| Forfaits Illimités | `*123*77*{price}#` | MTN Officiel (06/11/2026) | `official` | Mode `direct`. Option paiement MoMo : `*880*123*77*{price}#`. Débit réduit à 1 Mbps après volume. |
| Forfaits Volume Mensuels | `*123*77*{price}#` | MTN Officiel (grille 2023/2026) | `third_party` | Mode `direct`. Grille mensuelle 15 500 F à 50 000 F. |
| Forfaits Petit Budget (ZoTchéZé) | `*123*77*{price}#` / `*123#` | Campagne ZoTchéZé 2026 (presse spécialisée) | `third_party` | Grille 2026 : 416 Mo à 100 F, 833 Mo à 200 F, 1 Go Plus à 250 F, 2 Go à 500 F, 5 Go Plus à 1 250 F, 20 Go Plus à 5 000 F. À confronter à MyMTN lors d'une prochaine vérification. |
| Go Pack (mixte) | `*172*77*{price}#` | MTN Officiel (07/11/2026) | `official` | Mode `direct`. Voix + data + SMS. Paliers 100 F à 1 500 F confirmés sur MyMTN (500 F = 48 h) ; 2 500 F et 5 000 F restent issus de sources tierces. |
| Forfaits Maxi (Appels) | `*173*77*{price}#` | MTN Officiel (07/11/2026) | `official` | Mode `direct`. Code officiel par palier ; montants de crédit encore issus de sources tierces. |
| XtraTime (Secours) | `*785#` | MTN Officiel | `official` | Emprunt crédit + 10 % frais. |
| Statut forfait volume | `*123*2#` | MTN Officiel | `official` | Consultation du solde du forfait volume. |
| Désactiver forfait volume | `*123*7#` | MTN Officiel | `official` | Code officiel corrigé (`*123*7#` au lieu de `*123*7*#`). |
| Réactiver forfait Extra | `*119#` | MTN Officiel | `official` | Réactivation avec bonus Extra. |
| Solde principal | `*126#` | Code embarqué prioritaire | `low` | `*126#` conservé par priorité app. `*123#` est réservé au portail forfaits. |

---

## 4. Résolution de la destination USSD d'une offre

Lorsqu'une offre est lancée depuis un catalogue, la destination est choisie
dans cet ordre :

1. `offer.launch` — code propre à l'offre ;
2. `offer.payWith` — option de paiement propre à l'offre ;
3. option de `catalog.payWith` réellement spécifique (elle contient `{price}`
   ou pointe vers la même destination que `catalog.launch`) ;
4. `catalog.launch` — menu ou code direct du catalogue.

Une option de paiement générique (par exemple le menu Moov Money
`*855*3*2#`) ne remplace jamais la destination du catalogue : elle est ignorée
au profit de `catalog.launch`.

