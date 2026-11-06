# UNIONE

[![CI](https://github.com/<ORG>/unione/actions/workflows/ci.yml/badge.svg)](https://github.com/<ORG>/unione/actions/workflows/ci.yml)

Assistant USSD intelligent pour le Bénin.

UNIONE regroupe les actions USSD courantes pour MTN, MOOV et Celtiis : solde,
transfert, achat de crédit, internet, assistance et forfaits disponibles dans
les données locales de l'application.

## Vérification

```bash
flutter analyze
flutter test
```

## CI/CD

Le workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) s'exécute automatiquement
sur chaque push et Pull Request vers `main` / `develop` :

1. **`dart format`** — vérifie que le code est formaté.
2. **`flutter analyze --fatal-infos`** — aucune erreur ou avertissement tolérée.
3. **`flutter test --reporter=expanded`** — tous les tests unitaires et widget doivent passer.

> Les artefacts de test sont conservés 7 jours en cas d'échec.

## Catalogue USSD distant

Le catalogue embarqué est [`assets/data/ussd_tree.json`](assets/data/ussd_tree.json).
Il est chargé immédiatement, mis en cache localement, puis actualisé en arrière-plan
si une URL HTTPS est fournie au build :

```bash
flutter run --dart-define=UNIONE_CODES_URL=https://votre-api.example/ussd-codes.json
```

Le document distant doit respecter le schéma du catalogue embarqué et porter une
version entière supérieure ou égale à celle déjà en cache. Une réponse invalide ne
remplace jamais le cache utilisable.

## Dépendance ajoutée

- `shared_preferences` : conserve localement le catalogue validé, les favoris et le
  dernier choix de SIM par opérateur. Aucune donnée de saisie ni code PIN n’y est stocké.

Les paquets déjà présents `permission_handler`, `flutter_contacts` et `url_launcher`
servent respectivement aux autorisations Android, au choix facultatif d’un contact et
au repli vers le composeur/WhatsApp.

## Test sur téléphone réel

L’USSD ne se teste pas sur émulateur. Installez l’APK sur un téléphone Android avec
SIM, lancez un service de consultation, acceptez l’autorisation Téléphone puis
vérifiez la réponse USSD. Avec deux SIM, vérifiez le choix et sa mémorisation. Refusez
l’autorisation pour confirmer l’ouverture du composeur prérempli. Testez enfin un
service à paramètres ajouté au JSON distant : validation du numéro béninois, montant
positif, aperçu et choix de contact facultatif.
