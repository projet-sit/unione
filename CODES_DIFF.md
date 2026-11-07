# Différences et Concordance des Codes USSD (CODES_DIFF.md)

Ce document recense les correspondances, sources et écarts relevés entre les codes embarqués dans l'application UNIONE, la documentation officielle et les sources tierces.

Règle : un code n'est considéré comme `official` que s'il figure sur un site officiel de l'opérateur ou de l'ARCEP Bénin. Les blogs et sites tiers servent d'indice uniquement.

---

## 1. Celtiis Bénin

| Service | Code officiel / App | Source | Statut / Confiance | Remarques |
|---|---|---|---|---|
| Forfaits Internet (Connect) | `*199*2#` | celtiis.bj/forfaits/gamme-connect/ | `official` | Mode `menu`. Suivi : `*104#` puis compteur Internet Connect. |
| Internet IllimiNet | `*199*4#` | celtiis.bj/forfaits/gamme-illiminet/ | `official` | Mode `menu`. Suivi : `*104#` puis compteur IllimiNet. |
| Forfaits Top Appel | `*199*1*2#` | celtiis.bj/forfaits/gamme-top-appel/ | `official` | Mode `menu`. Crédit + SMS tous réseaux. |
| Forfaits MyMix | `*199*3#` | celtiis.bj/forfaits/gamme-mymix/ | `official` | Mode `menu`. Voix + SMS + Data. |
| Solde principal | `*104#` | celtiis.bj/particuliers/mobile/pay-as-you-go/ | `official` | `*104*1*1#` conservé en tant que raccourci possible, à confirmer sur SIM. |
| Mon numéro | `*199*7*4#` | Code existant app | `medium` | À confirmer sur SIM. |
| Solde Forfait | `*104*1*2#` | Code existant app | `medium` | À confirmer sur SIM. |
| Service client | `7373` | Celtiis Officiel | `official` | Appel vocal direct (launchKind: `call`). |
| Celtiis Cash | `*889#` | Code existant app | `a_verifier` | ARCEP (06/2026) attribue `*889#` à Coris Bank, pas à Celtiis. À vérifier sur SIM. |
| Transfert international C'Cash | `*889*4#` | Code existant app | `a_verifier` | Dépend de la validation de `*889#`. |
| Pass Chrono / Roaming / Hello | `*199#` | Celtiis Officiel | `to_test` | Navigation manuelle dans le menu. |

---

## 2. Moov Africa Bénin

| Service | Code officiel / App | Source | Statut / Confiance | Remarques |
|---|---|---|---|---|
| Portail offres et services | `*199#` | moov-africa.bj/codes-utiles/ | `official` | |
| Connaitre son numéro | `*199*1*3#` | moov-africa.bj/codes-utiles/ | `official` | |
| Consulter son solde | `*104#` | moov-africa.bj/codes-utiles/ | `official` | |
| Forfaits Internet (Volume) | `*123#` | moov-africa.bj/codes-utiles/ | `official` | Mode `menu`. Paiement Moov Money : `*855*3*2#`. |
| Internet Illimité | `*123*5#` | moov-africa.bj/forfaits-internet-illimites/ | `official` | Mode `menu`. |
| Internet Secours | `*123*9#` | moov-africa.bj | `official` | Mode `menu`. |
| Moov Combo | `*173*{price}#` | Code existant app | `medium` | À confirmer sur SIM (pas de source directe trouvée). |
| Moov Pass Bonus | `*173*1*{price}#` | Code existant app | `a_verifier` | e-catalogue montre `*173*77*montant#` via Moov Money. Code direct `*173*1*{price}#` non confirmé officiellement. |
| Moov Money menu | `*855#` | moov-africa.bj/codes-utiles/ | `official` | |
| Crédit pour moi | `*855*3*1*1*{montant}#` | moov-africa.bj/achat-de-credit-et-forfaits/ | `official` | PIN saisi par l'opérateur uniquement. |
| Crédit pour un proche | `*855*3*1*2*{numero}*{montant}#` | moov-africa.bj/achat-de-credit-et-forfaits/ | `official` | Format `10` pour le numéro. |
| Achat forfait via Moov Money | `*855*3*2#` | moov-africa.bj/achat-de-credit-et-forfaits/ | `official` | |
| Transfert d'argent | `*855*1*1*1*{numero}*{numero_confirmation}*{montant}#` | Source web 2021 | `a_verifier` | Format historique, à tester. |
| Paiement marchand | `*855*4*1*{numero_marchand}*{montant}*{reference}#` | moov-africa.bj (SBEE via *855*4#) | `high` | |
| Moov Fidelis | `*133#` | moov-africa.bj/codes-utiles/ | `official` | |
| Moov Bomi | `*855*2#` | Code existant app | `low` | Aucune source officielle trouvée. |

---

## 3. MTN Bénin

| Service | Code officiel / App | Source | Statut / Confiance | Remarques |
|---|---|---|---|---|
| Statut forfait volume | `*123*2#` | my.mtn.bj (1045/) | `official` | |
| Désactiver forfait volume | `*123*7#` | my.mtn.bj (Forfait Libre) | `official` | |
| XtraTime (Secours) | `*785#` | ARCEP (attribué à MTN), my.mtn.bj | `official` | |
| MTN MoMo menu | `*880#` | ARCEP (attribué à MTN Mobile Money), mtn.bj | `official` | |
| Forfait Maxi via MoMo | `*880*45#` | mtn.bj/helppersonal/faq-mtn-maxi/ | `official` | |
| Go Pack (direct) | `*172*77*{price}#` | my.mtn.bj (activation GoPack) | `official` | `*172*77*montant#` confirmé. |
| Go Pack via MoMo | `*880*172*77*{montant}#` | my.mtn.bj (activation GoPack) | `official` | |
| Forfaits Illimités | `*123*77*{price}#` | Code existant app | `a_verifier` | Non confirmé sur my.mtn.bj. À vérifier. |
| Forfaits Volume Mensuels | `*123*77*{price}#` | Code existant app | `third_party` | Grille 2023/2026, source tierce. |
| Forfaits Maxi (direct) | `*173*77*{price}#` | mtn.bj FAQ Maxi | `official` | `*173#` ou `*173*77*Montant_forfait#`. |
| Solde principal | `*126#` | Code existant app | `low` | Temo Vision blog rapporte `*124#`. À vérifier sur SIM. |
| Mon numéro | `*103#` | Code existant app | `low` | À vérifier sur SIM. |
| Menu complet MTN | `*199#` | Code existant app | `low` | À vérifier sur SIM. |
| Forfaits Petit Budget (ZoTchéZé) | `*123*77*{price}#` | Presse spécialisée 2026 | `third_party` | À confronter à MyMTN. |
| Réactiver forfait Extra | `*119#` | MTN Officiel | `official` | |

---

## 4. Écarts notables (à résoudre)

| Opérateur | Service | Code actuel | Code source officielle | Écart | Action |
|---|---|---|---|---|---|
| Celtiis | Celtiis Cash | `*889#` | ARCEP attribue `*889#` à Coris Bank | `*889#` peut ne pas être Celtiis | Marquer `a_verifier`, tester sur SIM |
| MTN | Solde principal | `*126#` | Blog tiers rapporte `*124#` | Incertitude sur le code exact | Marquer `low`, tester sur SIM |
| MTN | Forfaits Illimités | `*123*77*{price}#` | Aucune source officielle directe | Code non confirmé par MTN | Marquer `a_verifier` |
| Moov | Pass Bonus | `*173*1*{price}#` | e-catalogue montre `*173*77*montant#` via MoMo | Code direct non confirmé | Marquer `a_verifier` |

---

## 5. Résolution de la destination USSD d'une offre

Lorsqu'une offre est lancée depuis un catalogue, la destination est choisie dans cet ordre :

1. `offer.self.code` — variante "pour moi" (nouveau) ;
2. `offer.other.code` — variante "pour un autre numéro" (nouveau) ;
3. `offer.launch` — code propre à l'offre (rétrocompatibilité) ;
4. `offer.payWith` — option de paiement propre à l'offre ;
5. option de `catalog.payWith` réellement spécifique (contient `{price}` ou pointe vers `catalog.launch`) ;
6. `catalog.launch` — menu ou code direct du catalogue.

Une option de paiement générique (ex. menu Moov Money `*855*3*2#`) ne remplace jamais la destination du catalogue : elle est ignorée au profit de `catalog.launch`.

---

## 6. Priorités de test sur téléphone réel

Offres en `medium`, `low` ou `a_verifier` à tester en priorité :

1. **Celtiis** : `*889#` (Celtiis Cash), `*104*1*1#` (solde principal), `*104*1*2#` (solde forfait), `*199*7*4#` (mon numéro)
2. **Moov** : `*173*{price}#` (Combo), `*173*1*{price}#` (Pass Bonus), `*855*2#` (Bomi)
3. **MTN** : `*126#` (solde principal), `*103#` (mon numéro), `*123*77*{price}#` (forfaits illimités), `*119#` (réactiver Extra)

---

## 7. Absence de codes en dur

Aucun code USSD n'est en dur dans le code Dart ou Kotlin. Tous les codes proviennent exclusivement des fichiers JSON embarqués (`assets/data/ussd_tree.json`, `assets/data/catalogs.json`) ou des variantes `self`/`other` du catalogue de forfaits. Le code `rootCode: '*199#'` dans `catalog_screen.dart` est un faux opérateur de secours jamais utilisé pour le lancement.
