# Hisaabee

A mobile app that connects **accountants** and **companies** by location.

- Accountants find companies in their city or nearby that need accounting work.
- Companies find accountants and can choose between **full-time** and **part-time**.

> Status: in development.

## Planned features

- Choose a role at the start: Accountant or Company
- Registration for both sides, with city and area
- List of nearby companies for accountants
- List of accountants for companies, filtered by full-time or part-time
- City filter on both lists
- Contact option (call or message)
- Monthly subscription with premium features (later)

## Progress

- [x] Flutter project and app icon
- [x] Role selection screen
- [x] Firm list with sample data
- [ ] Companies list for accountants
- [ ] Accountants list with full-time / part-time filter
- [ ] Registration forms
- [ ] Django REST API and MySQL database
- [ ] Connect the app to the API

## Tech stack

- **App:** Flutter (Dart)
- **Backend:** Django REST Framework
- **Database:** MySQL

## Getting started

Requirements: [Flutter SDK](https://docs.flutter.dev/get-started/install) and Android Studio (for the emulator).

```bash
cd vr_accounting
flutter pub get
flutter run
```

## Project structure

```
vr_accounting/   Flutter app (lib/ holds the Dart code)
backend/         Django API (coming soon)
```
