# Zoli App - Project Instructions

## Project Overview
Flutter application initialized for the "Zoli" project.

## Tech Stack
- **Framework:** Flutter
- **Language:** Dart
- **State Management:** (TBD - Default to Provider or Bloc if needed later)
- **Styling:** Material Design 3

## Conventions
- Follow standard Flutter/Dart linting rules (analysis_options.yaml).
- Use `lib/` for source code.
- Feature-based folder structure is preferred as the app grows.

## Workflow
- Always run `flutter analyze` before committing.
- Ensure `flutter test` passes.

## USSDBot Logic
The assistant handles USSD requests for MTN, MOOV, and Celtiis (Benin).
- **MTN:** Solde (*136#), Transfert (*155*...), Achat crédit (*155*1*...), Forfait (*138#), Service client (*135#)
- **MOOV:** Solde (*111#), Transfert (*555*...), Achat crédit (*555*2*...), Forfait (*118#), Service client (*121#)
- **Celtiis:** Solde (*222#), Transfert (*300*...), Achat crédit (*300*1*...), Service client (*200#)

**Constraints:**
- JSON output only for bot interactions.
- One parameter at a time.
- Never store PIN (require_pin: true).
