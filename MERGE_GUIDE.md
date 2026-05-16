# Guide : branche `update`, pull request et merge

Ce document décrit le flux Git pour pousser le travail Flutter sur la branche **`update`**, ouvrir une **pull request (PR)** vers `main`, et fusionner en toute sécurité.

**Dépôt :** [https://github.com/Pincha005-tech/bongisamine](https://github.com/Pincha005-tech/bongisamine)

---

## Prérequis

- [Git](https://git-scm.com/) installé
- Accès en écriture au dépôt GitHub (`Pincha005-tech/bongisamine`)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version compatible avec `pubspec.yaml`)
- Compte GitHub connecté (`git config user.name` / `user.email` renseignés)

Optionnel : [GitHub CLI](https://cli.github.com/) (`gh`) pour créer la PR depuis le terminal.

---

## Partie 1 — Développeur : pousser sur `update`

Toutes les commandes ci-dessous s’exécutent depuis le dossier du projet Flutter :

```powershell
cd c:\Users\USER\Documents\BongisaMine\bongisamine
```

### 1. Vérifier l’état

```powershell
git status
git remote -v
```

Le remote `origin` doit pointer vers `https://github.com/Pincha005-tech/bongisamine`.

### 2. Récupérer les dernières modifications de `main`

```powershell
git fetch origin
git checkout main
git pull origin main
```

### 3. Créer ou basculer sur la branche `update`

**Première fois** (la branche n’existe pas encore en local) :

```powershell
git checkout -b update
```

**La branche existe déjà en local** :

```powershell
git checkout update
git pull origin update
```

**La branche existe seulement sur GitHub** :

```powershell
git fetch origin
git checkout -b update origin/update
```

### 4. Ajouter et committer les changements

```powershell
git add .
git status
```

Avant de committer, vérifier qu’aucun secret n’est inclus (`.env`, clés API, mots de passe). Les fichiers générés ou locaux doivent rester dans `.gitignore`.

```powershell
git commit -m "feat: migration Flutter — auth, thème, scan, dashboard et workers"
```

Adaptez le message au contenu réel du commit.

### 5. Pousser vers GitHub

```powershell
git push -u origin update
```

`-u` enregistre le suivi : les prochains `git push` / `git pull` sur `update` n’ont plus besoin de préciser la branche.

En cas d’erreur « rejected » (historique divergent) :

```powershell
git pull --rebase origin update
git push origin update
```

---

## Partie 2 — Ouvrir la pull request

### Option A — Interface GitHub (recommandée si `gh` n’est pas installé)

1. Ouvrir [https://github.com/Pincha005-tech/bongisamine](https://github.com/Pincha005-tech/bongisamine)
2. Un bandeau **« Compare & pull request »** apparaît souvent après le push de `update` — cliquer dessus.
3. Sinon : **Pull requests** → **New pull request**
4. Configurer :
   - **base** : `main` (branche qui recevra les changements)
   - **compare** : `update` (votre branche)
5. Renseigner **titre** et **description** (voir modèle ci-dessous)
6. **Create pull request**

### Option B — GitHub CLI

```powershell
gh auth login
gh pr create --base main --head update --title "Migration Flutter Bongisamine" --body-file PR_BODY.md
```

### Modèle de description de PR

```markdown
## Résumé
- Migration progressive Expo → Flutter
- Auth locale, thème clair/sombre, pages scan (QR / visage), dashboard, workers

## Fichiers / zones touchées
- `lib/` (écrans, pages, `coree/auth`, thème)
- `android/` / `ios/` (splash, identifiants bundle)
- `pubspec.yaml` (dépendances)

## Comment tester
1. `flutter pub get`
2. `flutter analyze`
3. `flutter run` sur un appareil ou émulateur
4. Parcours : login → onglets Accueil / Workers / Scan / Paramètres

## Notes pour le merge
- Pas de breaking change API documentée côté backend (mock / fallback si API indisponible)
- Vérifier les permissions caméra sur appareil réel pour le scan
```

---

## Partie 3 — Développeur qui merge (reviewer)

### 1. Revue sur GitHub

- Lire la description et l’onglet **Files changed**
- Laisser des commentaires ou demander des modifications si besoin
- Vérifier que la CI passe (si des workflows GitHub Actions sont configurés)

### 2. Récupérer la branche en local et tester

```powershell
git fetch origin
git checkout update
git pull origin update
flutter pub get
flutter analyze
flutter test
flutter run
```

Tester au minimum : connexion, navigation par onglets, filtres workers, scan (si matériel disponible), bascule thème clair/sombre.

### 3. Mettre `update` à jour avec `main` (si `main` a avancé)

Avant le merge, éviter les conflits sur `main` :

```powershell
git checkout update
git fetch origin
git merge origin/main
# Résoudre les conflits éventuels, puis :
git add .
git commit -m "chore: merge main into update"
git push origin update
```

Alternative (historique linéaire) :

```powershell
git rebase origin/main
git push --force-with-lease origin update
```

À n’utiliser en force push que si l’équipe l’accepte et que personne d’autre ne pousse sur `update`.

### 4. Fusionner la PR

Sur GitHub, page de la PR :

| Stratégie | Quand l’utiliser |
|-----------|------------------|
| **Merge commit** | Conserver l’historique complet de `update` |
| **Squash and merge** | Un seul commit propre sur `main` (souvent préféré) |
| **Rebase and merge** | Historique linéaire sans commit de merge |

Recommandation équipe : **Squash and merge** avec un titre de commit clair, sauf consigne contraire.

### 5. Après le merge

```powershell
git checkout main
git pull origin main
git branch -d update
git push origin --delete update
```

Sur la machine du contributeur initial :

```powershell
git checkout main
git pull origin main
git branch -d update
```

---

## Dépannage

| Problème | Action |
|----------|--------|
| `fatal: not a git repository` | Se placer dans `bongisamine`, pas dans le dossier parent `BongisaMine` |
| `Permission denied (push)` | Vérifier droits GitHub ou utiliser SSH / token avec scope `repo` |
| Conflits au merge | Ouvrir les fichiers marqués `<<<<<<<`, corriger, `git add`, `git commit` |
| PR : « Nothing to compare » | Vérifier que `update` a bien été poussée : `git push -u origin update` |
| Fichiers trop volumineux | Ne pas committer `build/`, `.dart_tool/` ; vérifier `.gitignore` |

---

## Récapitulatif des commandes (contributeur)

```powershell
cd c:\Users\USER\Documents\BongisaMine\bongisamine
git fetch origin
git checkout main
git pull origin main
git checkout -b update
git add .
git commit -m "feat: votre message"
git push -u origin update
```

Puis créer la PR : **`update` → `main`** sur GitHub.

---

## Contact / conventions

- Branche d’intégration feature : **`update`**
- Branche stable : **`main`**
- Ne pas pousser directement sur `main` sans accord d’équipe si le flux passe par PR.
