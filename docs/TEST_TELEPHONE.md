# UNIONE — Checklist de test sur téléphone réel

L'USSD ne se teste pas sur émulateur. Installez l'APK sur un téléphone
Android avec SIM, cochez chaque cas, puis remplissez « Résultat » (OK / KO
+ description) et « Code corrigé » (commit ou noté « — » si aucun).

| # | Test | Résultat | Code corrigé |
|---|------|----------|--------------|
| 1 | **Double SIM** : le choix de SIM s'affich | | |
| 2 | **Une seule SIM** : le lancement USSD se fait directement, sans demande de choix | | |
| 3 | **SIM absente / carte retirée** : message d'erreur clair, pas de blocage ni de crash | | |
| 4 | **Permission refusée** : le composeur s'ouvre pré-rempli, sans code visible à l'écran | | |
| 5 | **Permission ré-acceptée après refus** : le lancement direct reprend normalement | | |
| 6 | **MTN** : lancer un service de consultation (ex. solde), la réponse USSD s'affiche | | |
| 7 | **Moov Africa** : lancer un service de consultation, la réponse USSD s'affiche | | |
| 8 | **Celtiis** : lancer un service de consultation, la réponse USSD s'affiche | | |
| 9 | **Offres MTN** : ouvrir le catalogue, voir les forfaits, lancer un achat (ou le repli composeur) | | |
| 10 | **Offres Moov Africa** : ouvrir le catalogue, voir les forfaits, lancer un achat (ou le repli composeur) | | |
| 11 | **Offres Celtiis** : ouvrir le catalogue, voir les forfaits, lancer un achat (ou le repli composeur) | | |
| 12 | **Mode avion** : l'app s'ouvre avec les données embarquées ; un lancement USSD échoue proprement, sans crash | | |
| 13 | **Pas de réseau** : idem ci-dessus, et la synchro en arrière-plan ne bloque pas l'UI | | |
| 14 | **Mentions légales** : texte lisible en mode clair ET en mode sombre (À propos + Conditions d'utilisation) | | |

## Notes
- Noter le modèle de téléphone, la version Android et le nombre de SIM pour chaque test.
- En cas de KO sur un code USSD, transmettre le code concerné et la réponse de l'opérateur ; ne jamais transmettre de code PIN.
