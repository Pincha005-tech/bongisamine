# Guide — lancer et builder l’app mobile (Bongisamine)

L’URL du backend FastAPI (`mine_back`) est passée au build via la variable **`API_BASE_URL`** (`--dart-define`). Sans cette option, l’app utilise par défaut `http://10.0.2.2:8000` (émulateur Android → PC local).

---

## Prérequis

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) installé (`flutter doctor` sans erreur bloquante).
2. Téléphone en mode développeur **ou** émulateur Android / simulateur iOS.
3. API disponible :
   - **Production (Render)** : `https://bongisa-mine-api.onrender.com`
   - **Local** : `uvicorn` sur le PC, port `8000` (voir `mine_back/`).

```powershell
cd c:\Users\USER\Documents\BongisaMine\bongisamine
flutter pub get
```

---

## Choisir l’adresse du serveur

| Contexte | `API_BASE_URL` à utiliser |
|----------|---------------------------|
| **Render (prod)** | `https://bongisa-mine-api.onrender.com` |
| **Émulateur Android** (API sur le même PC) | `http://10.0.2.2:8000` |
| **Simulateur iOS** (API sur le Mac/PC) | `http://127.0.0.1:8000` |
| **Téléphone physique** (API sur le Wi‑Fi du PC) | `http://<IP_LAN_DU_PC>:8000` (ex. `http://192.168.1.42:8000`) |

> **Téléphone + API locale** : le PC et le téléphone doivent être sur le même réseau ; autoriser le port 8000 dans le pare-feu Windows. Trouver l’IP : `ipconfig` → adresse IPv4 de la carte Wi‑Fi.

> **HTTP en local sur Android** : si les requêtes échouent en `http://`, vérifier que le manifeste autorise le trafic clair en debug, ou tester d’abord avec l’URL **HTTPS** Render.

---

## Lancer l’app en développement (`flutter run`)

### Serveur Render (recommandé pour tests réels)

```powershell
cd c:\Users\USER\Documents\BongisaMine\bongisamine

flutter run --dart-define=API_BASE_URL=https://bongisa-mine-api.onrender.com
```

### API locale — émulateur Android

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

(Démarrer l’API avant : `cd ..\mine_back` puis `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`.)

### API locale — téléphone branché en USB

Remplacez l’IP par celle de votre PC :

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.42:8000
```

### Options utiles

| Commande | Effet |
|----------|--------|
| `flutter devices` | Liste les appareils connectés |
| `flutter run -d <id>` | Cible un appareil précis |
| **Hot restart** `R` (majuscule) | Recharge complète après changement de `--dart-define` ou gros refactors |
| Hot reload `r` | Petit changement UI uniquement |

Après modification de `API_BASE_URL`, faites toujours un **hot restart** ou relancez `flutter run` avec le bon `--dart-define`.

---

## Builder pour installation / store

La variable `--dart-define` doit être **répétée à chaque commande `build`**.

### Android — APK (test / partage direct)

```powershell
cd c:\Users\USER\Documents\BongisaMine\bongisamine

flutter build apk --release `
  --dart-define=API_BASE_URL=https://bongisa-mine-api.onrender.com
```

Fichier généré :

`build\app\outputs\flutter-apk\app-release.apk`

### Android — App Bundle (Google Play)

```powershell
flutter build appbundle --release `
  --dart-define=API_BASE_URL=https://bongisa-mine-api.onrender.com
```

Fichier : `build\app\outputs\bundle\release\app-release.aab`

### iOS (Mac uniquement)

```bash
flutter build ios --release \
  --dart-define=API_BASE_URL=https://bongisa-mine-api.onrender.com
```

Puis archive / distribution via Xcode (`ios/Runner.xcworkspace`).

---

## Vérifier que l’app pointe sur le bon serveur

1. L’API Render doit répondre : ouvrir dans un navigateur  
   `https://bongisa-mine-api.onrender.com/docs`
2. Se connecter dans l’app (ex. agent contrôle seed : `agent.controle` / `1234` si base seedée).
3. Si « Connexion impossible » :
   - URL exacte dans `--dart-define` (pas d’espace, pas de `/` final).
   - Render éveillé (première requête peut être lente ~30 s).
   - Compte / mot de passe valides sur cette instance.

---

## Récapitulatif une ligne

| Action | Commande |
|--------|----------|
| Dev + Render | `flutter run --dart-define=API_BASE_URL=https://bongisa-mine-api.onrender.com` |
| Dev + API locale (émulateur) | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000` |
| APK release Render | `flutter build apk --release --dart-define=API_BASE_URL=https://bongisa-mine-api.onrender.com` |

La valeur est lue dans le code ici : `lib/services/api_config.dart` → `ApiConfig.baseUrl`.
