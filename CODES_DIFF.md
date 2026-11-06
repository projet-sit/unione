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
| Internet Illimité | `*123*5#` | Moov Officiel (06/11/2026) | `to_test` | Mode `menu`. Paliers 15 000 F à 50 000 F. Débits après épuisement à vérifier sur SIM. |
| Internet Secours | `*123#` | Moov Officiel | `to_test` | Mode `menu`. Emprunt de volume data avec remboursement à la recharge. |
| Moov Combo | `*173*{price}#` | Moov Officiel (06/11/2026) | `official` | Mode `direct`. Formule voix + sms + data. |
| Moov Pass Bonus | `*173*1*{price}#` | Moov Officiel (06/11/2026) | `to_test` | Mode `direct`. Consultation solde : `*173*5*2#`. Activation pour tiers : `*173*4*1#`. |
| Moov Money Achat Forfait | `*855*3*2#` | Moov Officiel | `official` | Paiement d'un forfait via Moov Money. |
| Solde principal | `*104#` | Moov Officiel | `official` | Code direct standard. |

---

## 3. MTN Bénin

| Service | Code officiel / App | Source | Statut / Confiance | Remarques |
|---|---|---|---|---|
| Forfaits Illimités | `*123*77*{price}#` | MTN Officiel (06/11/2026) | `official` | Mode `direct`. Option paiement MoMo : `*880*123*77*{price}#`. Débit réduit à 1 Mbps après volume. |
| Forfaits Volume Mensuels | `*123*77*{price}#` | MTN Officiel (grille 2023/2026) | `third_party` | Mode `direct`. Grille mensuelle 15 500 F à 50 000 F. |
| Forfaits Petit Budget (ZoTchéZé) | `*123*77*{price}#` / `*123#` | Campagne ZoTchéZé 2026 | `to_test` | Volumes contradictoires selon les sources de presse. Libellés "à confirmer" tant que non validés sur MyMTN. |
| Go Pack (mixte) | `*133*77*{price}#` | MTN Officiel | `third_party` | Mode `direct`. Voix + data + SMS. |
| Forfaits Maxi (Appels) | `*123#` | MTN Officiel | `third_party` | Mode `menu`. Anciennement `*173#`. |
| XtraTime (Secours) | `*785#` | MTN Officiel | `official` | Emprunt crédit + 10 % frais. |
| Statut forfait volume | `*123*2#` | MTN Officiel | `official` | Consultation du solde du forfait volume. |
| Désactiver forfait volume | `*123*7#` | MTN Officiel | `official` | Code officiel corrigé (`*123*7#` au lieu de `*123*7*#`). |
| Réactiver forfait Extra | `*119#` | MTN Officiel | `official` | Réactivation avec bonus Extra. |
| Solde principal | `*126#` | Code embarqué prioritaire | `low` | `*126#` conservé par priorité app. `*123#` est réservé au portail forfaits. |
