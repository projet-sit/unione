# UNIONE — Checklist de test sur téléphone réel

L'USSD ne se teste pas sur émulateur. Installez l'APK sur un téléphone
Android avec SIM, cochez chaque cas, puis remplissez « Résultat » (OK / KO
+ description) et « Code corrigé » (commit ou noté « — » si aucun).

Le lancement doit se comporter exactement comme une composition manuelle :
UNIONE envoie un `ACTION_CALL` avec l'URI `tel:` encodée, sans jamais choisir
ni transmettre de SIM. C'est Android qui affiche sa fenêtre de choix de SIM
(ou utilise la SIM par défaut des appels), puis le dialogue USSD opérateur.

| # | Test | Résultat | Code corrigé |
|---|------|----------|--------------|
| 1 | **Deux SIM, « Demander à chaque fois »** : la fenêtre de choix est celle d'Android (pas celle d'UNIONE) | | |
| 2 | **Deux SIM, SIM par défaut fixe** : le lancement utilise cette SIM sans rien demander | | |
| 3 | **Une seule SIM** : le lancement USSD se fait directement, sans demande de choix | | |
| 4 | **Permission refusée** : le composeur s'ouvre pré-rempli et un message en français explique le repli | | |
| 5 | **Permission ré-acceptée après refus** : le lancement direct reprend normalement | | |
| 6 | **SIM absente / carte retirée** : message d'erreur clair, pas de blocage ni de crash | | |
| 7 | **MTN — code simple (solde)** : la réponse USSD s'affiche | | |
| 8 | **Moov Africa — code simple (solde)** : la réponse USSD s'affiche | | |
| 9 | **Celtiis — code simple (solde)** : la réponse USSD s'affiche | | |
| 10 | **MTN — code à menu `*880#` (MTN MoMo)** : le dialogue du menu MoMo s'ouvre | | |
| 11 | **Moov Africa — code à menu (`*855#`, Moov Money)** : le dialogue du menu s'ouvre | | |
| 12 | **Celtiis — code à menu** : le dialogue du menu s'ouvre | | |
| 13 | **URI finale** : le log debug affiche `tel:*880%23` (et non `tel:*880`) | | |
| 14 | **Aucun PIN** : aucun code PIN n'est saisi ni enregistré par UNIONE | | |
| 15 | **Offres MTN** : ouvrir le catalogue, voir les forfaits, lancer un achat (ou le repli composeur) | | |
| 16 | **Offres Moov Africa** : ouvrir le catalogue, voir les forfaits, lancer un achat (ou le repli composeur) | | |
| 17 | **Offres Celtiis** : ouvrir le catalogue, voir les forfaits, lancer un achat (ou le repli composeur) | | |
| 18 | **Mode avion** : l'app s'ouvre avec les données embarquées ; un lancement USSD échoue proprement, sans crash | | |
| 19 | **Pas de réseau** : idem ci-dessus, et la synchro en arrière-plan ne bloque pas l'UI | | |
| 20 | **Mentions légales** : texte lisible en mode clair ET en mode sombre (À propos + Conditions d'utilisation) | | |

## Notes
- Noter le modèle de téléphone, la version Android et le nombre de SIM pour chaque test.
- En cas de KO sur un code USSD, transmettre le code concerné et la réponse de l'opérateur ; ne jamais transmettre de code PIN.
- Si l'URI loguée est correcte (`tel:*880%23`) mais que le dialogue USSD ne s'ouvre pas, le problème vient de la permission ou de l'appareil, pas de l'encodage.
