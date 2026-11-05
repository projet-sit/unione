# Prompt Claude Code : évolution de l'application UNIONE

## Contexte

UNIONE est une application mobile Flutter (v1.0.0) qui regroupe les codes USSD des opérateurs du Bénin : MTN, Moov Africa et Celtiis. Elle est en français, avec un design clair et sobre : fond gris-bleu très clair, cartes blanches très arrondies avec ombre douce, titres en gras, et une couleur d'accent par opérateur (jaune MTN, bleu Moov, bleu nuit Celtiis).

### Écrans actuels

1. **Accueil** : titre « Veuillez sélectionner un réseau : », trois grandes cartes (MTN, Moov Africa, Celtiis, badge « Bénin », chevron), bouton Paramètres (engrenage) en haut à droite.
2. **Services d'un opérateur** : logo de l'opérateur en haut, sous-titre « <Opérateur> Bénin », titre « Services disponibles », grille de cartes à 2 colonnes (icône dans un cercle teinté + libellé).
   - MTN : Solde principal, MTN MoMo, Mon numéro, Menu Services, Portail Forfaits, XtraTime (Avance crédit)
   - Moov : Solde principal, Moov Money, Moov Bomi, Mon numéro, Menu Services, Moov Internet, + un 7e service (icône téléphone)
   - Celtiis : Solde principal, Celtiis Cash, Solde Forfait, Mon numéro, Menu Pass, Programme Fidélité, + un 7e service (icône casque)
3. **Paramètres** : Historique ; Sécurité, Politique de confidentialité, Conditions d'utilisation ; À propos de UNIONE, À propos du développeur, Noter l'application, Partager UNIONE ; bouton « Nous contacter sur WhatsApp ».

## Étape 0 : analyser avant de coder

Avant toute modification, lis le projet et résume-moi en quelques lignes :
- comment les codes USSD sont stockés aujourd'hui (liste en dur, JSON, base locale) ;
- la gestion d'état utilisée (Provider, Riverpod, Bloc, setState…) ;
- comment un service lance un code actuellement ;
- comment l'écran Historique fonctionne (s'il enregistre déjà quelque chose).

Adapte ensuite tout ce qui suit à l'architecture existante. Ne réécris pas ce qui fonctionne, n'ajoute pas de nouvelle gestion d'état si une existe déjà, et garde exactement le style visuel actuel.

## Fonctionnalités à implémenter

### 1. Exécution en un tap

- Un tap sur un service lance le code USSD directement, sans passer manuellement par le composeur.
- Sur Android : utiliser un plugin USSD (évalue les options maintenues, par exemple `ussd_advanced`) ou à défaut un appel `tel:` avec le `#` correctement encodé (`%23`). Demander les permissions à l'exécution (`CALL_PHONE`, `READ_PHONE_STATE`) avec un message explicatif en français.
- Double SIM : si l'appareil a deux SIM, afficher une feuille (bottom sheet) pour choisir la SIM ; mémoriser le dernier choix par opérateur.
- Afficher la réponse USSD dans une feuille ou une boîte de dialogue propre quand le plugin la fournit.
- Repli : si la permission est refusée ou le plugin indisponible (iOS inclus), ouvrir le composeur avec le code pré-rempli.
- Gérer les erreurs (pas de réseau, SIM absente, code refusé) avec des messages clairs.

### 2. Codes à paramètres

- Certains services ont besoin d'une saisie (numéro, montant). Les codes utilisent des variables, par exemple `*880*{numero}*{montant}#`.
- Au tap, afficher un petit formulaire : champ numéro avec bouton « choisir un contact » (permission `READ_CONTACTS`, optionnelle), champ montant, validation (format de numéro béninois, montant positif), aperçu du code final avant lancement.
- **Sécurité** : ne jamais enregistrer ni journaliser un code PIN ou un mot de passe. Si un code demande un PIN, laisser l'utilisateur le saisir dans le dialogue USSD de l'opérateur, ne pas le collecter dans l'app. Dans l'historique, masquer les paramètres sensibles.

### 3. Codes mis à jour à distance

- Source de vérité : un fichier JSON versionné servi en HTTPS (je peux l'héberger sur mon API Node.js). Prévoir une abstraction `CodesRepository` pour pouvoir passer plus tard à Firebase Remote Config sans toucher à l'interface.
- Au démarrage : charger la copie locale (cache) tout de suite, puis tenter une mise à jour en arrière-plan. Un JSON embarqué dans les assets sert de valeur de secours au premier lancement et hors ligne.
- Valider le JSON avant de l'appliquer (schéma, version) ; en cas d'erreur, garder le cache actuel.
- Ajouter un bouton « Signaler un code qui ne marche plus » sur chaque service, qui ouvre un message WhatsApp pré-rempli (opérateur, service, code, version de l'app) vers le contact existant.

Modèle de données proposé :

```json
{
  "version": 3,
  "updatedAt": "2026-11-05",
  "operators": [
    {
      "id": "mtn",
      "name": "MTN",
      "country": "Bénin",
      "color": "#FFCC00",
      "services": [
        {
          "id": "mtn_solde",
          "label": "Solde principal",
          "icon": "bank",
          "category": "solde",
          "code": "REMPLIR_AVEC_LE_CODE_EXISTANT",
          "params": []
        },
        {
          "id": "mtn_momo_transfert",
          "label": "Transfert MoMo",
          "icon": "wallet",
          "category": "momo",
          "code": "REMPLIR_AVEC_LE_CODE_EXISTANT",
          "params": [
            { "key": "numero", "type": "phone", "label": "Numéro du destinataire" },
            { "key": "montant", "type": "amount", "label": "Montant (FCFA)" }
          ]
        }
      ]
    }
  ]
}
```

Reprends dans ce JSON **tous les codes qui existent déjà dans l'app**, sans en inventer. Si un code te semble douteux, signale-le-moi au lieu de le deviner.

### 4. Améliorations d'expérience

- **Favoris** : appui long ou étoile sur un service pour l'épingler ; section « Favoris » en haut de l'accueil.
- **Récents** : les derniers services utilisés, alimentés par l'écran Historique existant (date, opérateur, service, sans données sensibles).
- **Recherche** : barre de recherche globale (ex. « solde », « forfait ») qui filtre tous les opérateurs.
- **Détection de l'opérateur de la SIM** : si détectable, afficher cet opérateur en premier ou le proposer en raccourci sur l'accueil.
- **Retour haptique et animations légères** au tap, états de chargement, et états vides soignés.

### 5. Nouveaux services (via le JSON, sans republier l'app)

Prévoir la structure pour ajouter facilement des catégories : forfaits internet et appels par opérateur, factures (électricité, eau), TV, banques mobiles. Ajouter une notion de `category` pour regrouper les services dans l'écran opérateur (onglets ou filtres en chips), tout en gardant la grille actuelle comme vue par défaut.

### Phase suivante (optionnelle, à ne faire que si je le demande)

Widget ou raccourci d'écran d'accueil pour le solde en un tap.

## Contraintes

- Interface et textes en français.
- Garder la charte visuelle actuelle (couleurs par opérateur, cartes arrondies, ombres douces).
- Code propre : séparation données / logique / interface, null safety, pas de duplication.
- Mettre à jour `AndroidManifest.xml` (permissions) et `pubspec.yaml` (dépendances), et me lister précisément chaque dépendance ajoutée et pourquoi.
- Mettre à jour la Politique de confidentialité si de nouvelles permissions (contacts, téléphone) sont utilisées, et me le signaler.

## Façon de travailler

1. Fais l'étape 0 et attends mon accord sur ton plan.
2. Implémente dans cet ordre, en proposant un commit par étape : (1) exécution en un tap, (2) codes à paramètres, (3) mise à jour à distance, (4) favoris, récents et recherche, (5) catégories.
3. À chaque étape, dis-moi comment la tester sur un vrai téléphone avec SIM, car l'USSD ne se teste pas sur émulateur.
