# Bongisamine

Application Flutter de gestion de présence et d’activités (migration depuis Expo/React Native).

**Dépôt GitHub :** [Pincha005-tech/bongisamine](https://github.com/Pincha005-tech/bongisamine)

## Démarrage rapide

```powershell
cd bongisamine
flutter pub get
flutter run
```

## Contribution et merge

Le flux Git (branche `update`, pull request vers `main`, procédure pour le reviewer) est documenté dans **[MERGE_GUIDE.md](./MERGE_GUIDE.md)**.

En bref pour pousser votre travail :

1. `git checkout -b update` (ou `git checkout update`)
2. `git add .` puis `git commit -m "..."`
3. `git push -u origin update`
4. Ouvrir une PR **update → main** sur GitHub

## Structure utile

| Dossier / fichier | Rôle |
|-------------------|------|
| `lib/Screens/` | Écrans auth, accueil, navigation |
| `lib/pages/` | Pages métier (dashboard, workers, scan, paramètres) |
| `lib/coree/auth/` | Session utilisateur locale |
| `lib/coree/theme/` | Thème clair / sombre |
| `MERGE_GUIDE.md` | Guide détaillé push, PR et merge |

## Documentation Flutter

- [Documentation Flutter](https://docs.flutter.dev/)
- [Cookbook](https://docs.flutter.dev/cookbook)
