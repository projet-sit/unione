# Différences et Concordance des Codes USSD (CODES_DIFF.md)

Ce document recense les correspondances, sources et écarts relevés entre les codes embarqués dans l'application UNIONE, la documentation officielle et les sources tierces.

Règle : un code est considéré comme `official` uniquement s'il figure sur un site officiel de l'opérateur (moov-africa.bj, mtn.bj, my.mtn.bj, celtiis.bj) ou de l'ARCEP Bénin (arcep.bj). Les blogs et sites tiers servent d'indice uniquement.

Aucun code USSD n'est en dur dans le code Dart ou Kotlin. Tous les codes proviennent exclusivement des fichiers JSON embarqués (`assets/data/ussd_tree.json`, `assets/data/catalogs.json`).

---

## 1. Celtiis Bénin

| Service | Code | Source | Statut / Confiance | Remarques |
|---|---|---|---|---|
| Forfaits Internet (Connect) | `*199*2#` | celtiis.bj/forfaits/gamme-connect/ | `official` | Menu. Activation : composez `*199*2#` et choisissez le forfait. |
| Internet IllimiNet | `*199*4#` | celtiis.bj/forfaits/gamme-illiminet/ | `official` | Menu. Certaines sources rapportent `*199*8#` (à vérifier). |
| Forfaits Top Appel | `*199*1*2#` | celtiis.bj/forfaits/gamme-top-appel/ | `official` | Menu. Crédit + SMS tous réseaux. |
| Forfaits MyMix | `*199*3#` | celtiis.bj/forfaits/gamme-mymix/ | `official` | Menu. Voix + SMS + Data. |
| Solde principal | `*104#` | celtiis.bj/particuliers/mobile/pay-as-you-go/ | `official` | Suivi consommation. |
| Solde Forfait | `*104*1*2#` | Code existant app | `medium` | À tester sur SIM. |
| Mon numéro | `*199*7*4#` | Code existant app | `medium` | À tester sur SIM. |
| Service client | `7373` | Celtiis Officiel | `official` | Appel vocal direct (launchKind: `call`). |
| Celtiis Cash | `*889#` | Code existant app | `a_verifier` | ARCEP (06/2026) attribue `*889#` à Coris Bank, pas à Celtiis. À vérifier sur SIM. |
| Transfert international C'Cash | `*889*4#` | Code existant app | `a_verifier` | Dépend de la validation de `*889#`. |
| Pass Chrono / Roaming / Hello | `*199#` | celtiis-officiel | `to_test` | Navigation manuelle dans le menu. |

---

## 2. Moov Africa Bénin

| Service | Code | Source | Statut / Confiance | Remarques |
|---|---|---|---|---|
| Portail offres et services | `*199#` | moov-africa.bj/codes-utiles/ | `official` | |
| Connaitre son numéro | `*199*1*3#` | moov-africa.bj/codes-utiles/ | `official` | |
| Consulter son solde | `*104#` | moov-africa.bj/codes-utiles/ | `official` | |
| Forfaits Internet (menu) | `*123#` | moov-africa.bj/codes-utiles/ | `official` | Page officielle ne donne que ce code. Pas de raccourci direct confirmé. |
| Internet Illimité | `*123*5#` | moov-africa.bj/forfaits-internet-illimites/ | `official` | Menu. |
| Internet Secours | `*123*9#` | moov-africa.bj | `official` | Menu. |
| Moov Money menu | `*855#` | moov-africa.bj/codes-utiles/ | `official` | |
| Crédit pour moi | `*855*3*1*1*{montant}#` | moov-africa.bj/achat-de-credit-et-forfaits/ | `official` | PIN saisi par l'opérateur uniquement. |
| Crédit pour un proche | `*855*3*1*2*{numero}*{montant}#` | moov-africa.bj/achat-de-credit-et-forfaits/ | `official` | Format `10` pour le numéro. |
| Achat forfait via Moov Money | `*855*3*2#` | moov-africa.bj/achat-de-credit-et-forfaits/ | `official` | Menu, choix du forfait après. |
| Transfert Moov→Moov | `*855*1*1*1*{numero}*{numero}*{montant}#` | moov-africa.bj/achat-de-credit-et-forfaits/ | `high` | Numéro répété deux fois. Code secret retiré. |
| Transfert Moov→autre réseau | `*855*1*2*{prenom}*{nom}*{numero}*{montant}#` | moov-africa.bj/achat-de-credit-et-forfaits/ | `high` | Prénom et nom requis. Code secret retiré. |
| PI-SPI (interopérable UEMOA) | `*855*6#` | moov-africa.bj | `high` | Page « PI SPI ». |
| Paiement marchand | `*855*4*1*{marchand}*{montant}*{reference}#` | moov-africa.bj (SBEE) | `high` | Page « Paiement marchand ». |
| Moov Fidelis | `*133#` | moov-africa.bj/codes-utiles/ | `official` | |
| Moov Bomi | `*855*2#` | Code existant app | `low` | Aucune source officielle trouvée. |
| Moov Combo | `*173*{price}#` | Code existant app | `medium` | À confirmer sur SIM (pas de source directe trouvée). |
| Moov Pass Bonus | `*173*1*{price}#` | Code existant app | `a_verifier` | e-catalogue montre `*173*77*montant#` via MoMo. Code direct non confirmé. |

---

## 3. MTN Bénin

| Service | Code | Source | Statut / Confiance | Remarques |
|---|---|---|---|---|
| MTN MoMo menu | `*880#` | ARCEP (attribué à MTN Mobile Money), mtn.bj | `official` | |
| Forfait Maxi via MoMo | `*880*45#` | mtn.bj/helppersonal/faq-mtn-maxi/ | `official` | |
| Go Pack (montant libre) | `*133*77*{montant}#` | my.mtn.bj (activation GoPack) | `high` | Même page que Go Pack. Code « montant libre » pour Internet, pour soi. |
| Go Pack (menu) | `*123#` puis « Tous les forfaits Go Pack » | my.mtn.bj | `high` | Navigation manuelle. |
| Forfaits Maxi (menu) | `*123#` puis « Tous les forfaits Maxi » | my.mtn.bj | `high` | |
| XtraTime internet (avance) | `*785#` puis « internet » | my.mtn.bj | `high` | Emprunt remboursé au prochain rechargement. |
| Statut forfait volume | `*123*2#` | my.mtn.bj | `official` | |
| Désactiver forfait volume | `*123*7#` | my.mtn.bj (Forfait Libre) | `official` | |
| Réactiver forfait Extra | `*119#` | MTN Officiel | `official` | |
| Transfert entre abonnés MoMo | `*880#` puis « Envoi d'argent » | mtn.bj | `medium` | Raccourci direct non publié. Lancement du menu. |
| PI-SPI (option 8) | `*880#` puis option 8 | Communiqué MTN (nov 2026) | `high` | Changements à partir du 2 novembre 2026. |
| Envoi vers non abonné | `*880#` puis « Envoi d'argent », « Non abonné » | mtn.bj | `high` | Menu, pas de raccourci publié. |
| Solde principal | `*126#` | Code existant app | `low` | Blog tiers rapporte `*124#`. À vérifier sur SIM. |
| Mon numéro | `*103#` | Code existant app | `low` | À vérifier sur SIM. |
| Menu complet MTN | `*199#` | Code existant app | `low` | À vérifier sur SIM. |
| Forfaits Illimités | `*123*77*{price}#` | Code existant app | `a_verifier` | Non confirmé sur my.mtn.bj. |
| Forfaits Volume Mensuels | `*123*77*{price}#` | Code existant app | `third_party` | Grille 2023/2026, source tierce. |
| Forfaits Maxi (direct) | `*173*77*{price}#` | mtn.bj FAQ Maxi | `official` | `*173#` ou `*173*77*Montant#`. |
| Go Pack via MoMo | `*880*172*77*{montant}#` | my.mtn.bj | `official` | |
| Forfait Internet via MoMo | `*880*123*77*{montant}#` | mtn-bj | `high` | |
| Anciens raccourcis (`*880*123*77*{montant}#`, `*173*77*{montant}#`) | n/a | low | Pages anciennes : ne pas utiliser sans re-vérification. |

---

## 4. Parcours guidés (flow) — nouveaux nœuds dans ussd_tree.json

| Opérateur | Parcours | Code (pour moi) | Code (pour un autre) | Statut |
|---|---|---|---|---|
| MTN | Forfait Internet | `*133*77*{montant}#` | — (non disponible) | `ok` |
| MTN | Forfait Appel | `*133*77*{montant}#` | — (non disponible) | `a_verifier` |
| MTN | Transfert MoMo | `*880#` (menu) | `*880#` (menu) | `ok` / `a_verifier` |
| Moov | Forfait Internet | `*123#` (menu) | — | `ok` |
| Moov | Forfait Appel | `*173#` (menu) | — | `ok` |
| Moov | Transfert même réseau | `*855*1*1*1*{numero}*{numero}*{montant}#` | — | `ok` |
| Moov | Transfert autre réseau | — | `*855*1*2*{prenom}*{nom}*{numero}*{montant}#` | `ok` |
| Celtiis | Forfait Internet | `*199*2#` (menu) | — | `ok` |
| Celtiis | Forfait Appel | `*199*3#` (menu) | — | `ok` |
| Celtiis | Transfert même réseau | `*889#` (menu) | — | `a_verifier` |
| Celtiis | Transfert autre réseau | — | — (non disponible) | `a_verifier` / `low` |

Règle : une combinaison sans code vérifié est désactivée avec « Bientôt disponible » (`status: "a_verifier"`). Aucun code n'est jamais deviné.

---

## 5. Absence de codes en dur

Aucun code USSD n'est en dur dans le code Dart ou Kotlin. Tous les codes proviennent exclusivement des fichiers JSON embarqués. Le code `rootCode: '*199#'` dans `catalog_screen.dart` (supprimé) était un faux opérateur de secours jamais utilisé pour le lancement.

---

## 6. Écarts notables

| Opérateur | Service | Code actuel | Code source officielle | Écart | Action |
|---|---|---|---|---|---|
| Celtiis | Celtiis Cash | `*889#` | ARCEP attribue `*889#` à Coris Bank | Incertain | `a_verifier`, tester sur SIM |
| MTN | Solde principal | `*126#` | Blog tiers rapporte `*124#` | Incertain | `low`, tester sur SIM |
| MTN | Forfaits Illimités | `*123*77*{price}#` | Aucune source officielle directe | Non confirmé | `a_verifier` |
| Moov | Pass Bonus | `*173*1*{price}#` | e-catalogue montre `*173*77*montant#` via MoMo | Non confirmé | `a_verifier` |
| Celtiis | IllimiNet | `*199*4#` | Certaines sources donnent `*199*8#` | Doute sur le code | Garder `*199*4#`, mettre `*199*8#` en alt |

---

## 7. Priorités de test sur téléphone réel

Offres en `medium`, `low` ou `a_verifier` à tester en priorité :

1. **Celtiis** : `*889#` (Celtiis Cash), `*104*1*2#` (solde forfait), `*199*7*4#` (mon numéro)
2. **Moov** : `*173*{price}#` (Combo), `*173*1*{price}#` (Pass Bonus), `*855*2#` (Bomi)
3. **MTN** : `*126#` (solde principal), `*103#` (mon numéro), `*123*77*{price}#` (forfaits illimités), `*119#` (réactiver Extra)

Checklist par opérateur (sur vrai SIM) :
- [ ] Un forfait « Pour moi » (montant libre ou offre rapide)
- [ ] Un forfait « Pour quelqu'un » (si activé)
- [ ] Un transfert même réseau
- [ ] Un transfert autre réseau (si activé)
- [ ] Un montant libre invalide (doit être rejeté)
- [ ] Le dialogue du code secret de l'opérateur s'affiche après validation
