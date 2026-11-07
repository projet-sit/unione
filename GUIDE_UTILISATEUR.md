# UNIONE — Guide utilisateur

UNIONE est l'assistant USSD intelligent pour le Bénin. Il regroupe les codes USSD des opérateurs MTN, Moov Africa et Celtiis dans une seule application, en français, avec un design clair et sobre.

## 1. Premiers pas

### Première ouverture
À la toute première ouverture, un écran d'introduction (onboarding) s'affiche en trois étapes :
1. Tous vos services USSD, au même endroit.
2. Vous gardez le contrôle (aucun appel n'est enregistré, Android gère la SIM).
3. Rapide, hors ligne et privé (aucun numéro, montant ou code PIN n'est stocké).

Appuyez sur « Suivant » pour avancer, puis « Commencer » pour accéder à l'application. Vous pouvez aussi appuyer sur « Passer » pour ignorer l'introduction.

## 2. Écran d'accueil — choisir un réseau

L'accueil affiche le titre « Veuillez sélectionner un réseau : » et trois grandes cartes :
- **MTN** (jaune)
- **Moov Africa** (bleu)
- **Celtiis** (bleu nuit)

Chaque carte porte un badge « Bénin » et un chevron. Appuyez sur une carte pour ouvrir les services de cet opérateur.

### Barre de recherche
En haut de l'accueil se trouve un champ « Rechercher… ». Tapez un mot-clé (ex. « solde », « forfait », « internet », « transfert ») pour filtrer tous les services et forfaits de tous les opérateurs à la fois.

### Raccourcis rapides (chips)
Sous la recherche, quatre raccourcis rapides vous permettent de filtrer d'un seul geste :
- Solde
- Internet
- Transfert
- Forfaits

### Récents
La section « Récents » affiche les derniers services utilisés (service, opérateur). Appuyez sur une carte récente pour le relancer directement.

### Favoris
Dans la liste des services d'un opérateur, appuyez sur l'étoile (ou effectuez un appui long) pour ajouter un service aux favoris. La section « Favoris » s'affiche alors en haut de l'accueil pour un accès immédiat.

### Paramètres
L'icône engrenage en haut à droite ouvre l'écran Paramètres.

## 3. Services d'un opérateur

Après avoir choisi un opérateur, vous voyez la liste de ses services disponibles, présentée sous forme de cartes (icône dans un cercle teinté aux couleurs de l'opérateur + libellé).

Exemples de services :
- Solde principal
- MTN MoMo / Moov Money / Celtiis Cash
- Mon numéro
- Menu Services / Menu Pass
- Forfaits internet et appels
- Transferts d'argent
- Et plus selon l'opérateur

### Lancer un service (exécution en un tap)
Appuyez sur un service pour lancer directement son code USSD :
1. L'application demande (si nécessaire) l'autorisation Téléphone (`CALL_PHONE`) avec un message en français.
2. Sur un téléphone double SIM, une feuille s'affiche pour choisir la SIM ; le dernier choix est mémorisé par opérateur.
3. Le code USSD est envoyé au composeur natif d'Android, qui ouvre le dialogue USSD de l'opérateur.
4. La réponse USSD s'affiche dans une feuille ou boîte de dialogue propre lorsque l'opérateur la fournit.

### Repli composeur
Si l'autorisation est refusée ou si le lancement direct est indisponible (notamment sur iOS), l'application ouvre le composeur de téléphone avec le code USSD déjà pré-rempli. Il vous reste à appuyer sur « Appeler ».

### Codes à paramètres
Certains services demandent une saisie (ex. numéro de destinataire, montant). Un petit formulaire s'affiche alors :
- Champ numéro (avec option « choisir un contact »).
- Champ montant.
- Aperçu du code final avant lancement.
Validez pour lancer le code USSD avec vos paramètres insérés.

> **Sécurité** : l'application ne collecte jamais de code PIN ni de mot de passe. Si un code exige un PIN, saisissez-le directement dans le dialogue USSD de l'opérateur, jamais dans l'application. Dans l'historique, les paramètres sensibles sont masqués.

## 4. Signaler un problème

Sur chaque service, un bouton « Signaler un code qui ne marche plus » ouvre un message WhatsApp pré-rempli (opérateur, service, code, version de l'application) vers le contact de support UNIONE.

## 5. Paramètres

L'écran Paramètres contient :
- **Historique** : consulter vos actions récentes.
- **Sécurité**, **Politique de confidentialité**, **Conditions d'utilisation**.
- **À propos de UNIONE**, **À propos du développeur**.
- **Noter l'application**, **Partager UNIONE**.
- **Nous contacter sur WhatsApp**.

## 6. Raccourcis d'écran d'accueil et widget (Android)

### Widget « UNIONE »
Vous pouvez ajouter le widget UNIONE à votre écran d'accueil Android. Il propose quatre boutons rapides :
- Solde
- Internet
- Transfert
- Forfait

Appuyer sur un bouton ouvre l'application avec la recherche préremplie correspondante ; le choix de la SIM reste géré par Android.

### Raccourcis d'icône
Un appui long sur l'icône de l'application UNIONE affiche des raccourcis : Voir mon solde, Forfaits internet, Transfert, Forfaits.

## 7. Confidentialité et sécurité

- L'application fonctionne hors ligne : le catalogue des codes est embarqué.
- Aucun numéro de téléphone, montant ou code PIN n'est stocké ni journalisé.
- L'historique enregistre uniquement le nom du service et de l'opérateur (sans données sensibles).
- Une verrouillage biométrique peut protéger l'application après une période d'inactivité (paramétrable).

## 8. Mises à jour des codes

Les codes USSD peuvent être mis à jour à distance depuis un fichier JSON sécurisé (sans republier l'application). Au démarrage, l'application charge d'abord sa copie locale, puis tente une mise à jour en arrière-plan. En cas de problème réseau, la version embarquée est utilisée.

---

**Besoin d'aide ?** Utilisez « Nous contacter sur WhatsApp » depuis les Paramètres.
