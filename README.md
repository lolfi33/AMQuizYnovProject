# 🎮 AMQuiz - Jeu de Quiz Mobile

> Application de quiz mobile développée avec Flutter et backend Node.js

## 📋 Table des matières
- [🚀 Installation et lancement](#-installation-et-lancement)
- [📱 Frontend (Flutter)](#-frontend-flutter)
- [🖥️ Backend (Node.js)](#️-backend-nodejs)
- [🧪 Tests unitaires](#-tests-unitaires)
- [📦 Fichiers de configuration](#-fichiers-de-configuration)
- [📚 Documentation](#-documentation)

---

## ⚠️ **IMPORTANT - Source recommandée**

**Il est fortement recommandé d'utiliser le fichier ZIP plutôt que ce repository Git.**

### Pourquoi utiliser le ZIP ?
- ✅ **Fichiers de configuration complets** : Le ZIP contient tous les fichiers de configuration Firebase avec les clés API nécessaires
- ✅ **Documentation complète** : Le ZIP inclut tous les documents rédigés pour le Bloc 2
- ✅ **Prêt à l'emploi** : Aucune configuration supplémentaire n'est nécessaire

### Contenu du ZIP
```
AMQuiz-Project.zip
├── fluttertest/              # Application Flutter
├── AMQuizBackEnd/            # Backend Node.js
├── Documentation-Bloc2/      # Documents écrits pour le Bloc 2
│   ├── Rapport-Technique.pdf
│   ├── Documentation-API.pdf
│   └── Guide-Utilisation.pdf
└── README.md                 # Ce fichier
```

---

## 🚀 Installation et lancement

### Prérequis
- **Flutter SDK** (3.0+) : [Installation Flutter](https://flutter.dev/docs/get-started/install)
- **Node.js** (18+) : [Installation Node.js](https://nodejs.org/)
- **Android Studio** ou **Xcode** (pour les émulateurs)
- **VS Code** avec extensions Flutter/Dart

---

## 📱 Frontend (Flutter)

### 🔧 Installation
```bash
# Naviguez vers le dossier Flutter
cd fluttertest

# Installez les dépendances
flutter pub get

# Vérifiez que Flutter est correctement configuré
flutter doctor
```

### 📱 Lancement sur émulateur Android

#### Via VS Code :
1. **Ouvrez VS Code** dans le dossier `fluttertest/`
2. **Démarrez un émulateur Android** :
   - `Ctrl+Shift+P` → "Flutter: Launch Emulator"
   - Ou lancez Android Studio → AVD Manager → Start
3. **Lancez l'application** :
   - `F5` ou `Ctrl+F5`
   - Ou `Ctrl+Shift+P` → "Flutter: Run Flutter App"

#### Via Terminal :
```bash
# Vérifiez les appareils disponibles
flutter devices

# Lancez sur émulateur Android
flutter run

# Pour un build de production
flutter build apk
```

### 🍎 Lancement sur émulateur iOS (macOS uniquement)

#### Via VS Code :
1. **Ouvrez le simulateur iOS** :
   - `Ctrl+Shift+P` → "Flutter: Launch Emulator"
   - Ou `open -a Simulator`
2. **Lancez l'application** : `F5`

#### Via Terminal :
```bash
# Lancez sur simulateur iOS
flutter run

# Pour un build iOS
flutter build ios
```

### 🌐 Lancement Web
```bash
# Lancez sur navigateur
flutter run -d chrome

# Build web
flutter build web
```

---

## 🖥️ Backend (Node.js)

### 🔧 Installation
```bash
# Naviguez vers le dossier backend
cd AMQuizBackEnd

# Installez les dépendances
npm install
```

### 🚀 Lancement du serveur
```bash
# Démarrage en mode développement
npm start

# Ou directement avec Node
node src/app.js
```

Le serveur sera accessible sur : `http://localhost:3000`

### 🔧 Variables d'environnement
Assurez-vous que le fichier `config/serviceAccountKey.json` (Firebase) est présent dans le ZIP.

### 📡 Endpoints disponibles
- `GET /` - Page d'accueil
- `POST /create-user` - Création d'utilisateur
- `POST /update-data` - Mise à jour des données
- `GET /get-prices` - Récupération des prix
- Plus d'endpoints dans la documentation API (ZIP)

---

## 🧪 Tests unitaires

### 🧪 Tests Frontend (Flutter)
```bash
# Naviguez vers le dossier Flutter
cd fluttertest

# Lancez tous les tests
flutter test

# Tests spécifiques à l'accessibilité
flutter test test/accessibility_test.dart

# Tests avec coverage
flutter test --coverage
```

### 🧪 Tests Backend (Node.js)
```bash
# Naviguez vers le dossier backend
cd AMQuizBackEnd

# Installez les dépendances de test (si nécessaire)
npm install --save-dev jest supertest

# Lancez les tests
npm test

# Tests avec coverage
npm run test:coverage
```

### 📊 Rapports de tests
Les rapports de couverture sont générés dans :
- Flutter : `coverage/lcov.info`
- Node.js : `coverage/`

---

## 📦 Fichiers de configuration

### 🔑 Fichiers sensibles (présents dans le ZIP uniquement)
```
# Flutter
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# Backend
config/serviceAccountKey.json
.env (si présent)
```

### ⚙️ Configuration Firebase
Les fichiers de configuration Firebase sont déjà inclus dans le ZIP et configurés pour l'environnement de développement.

---

## 📚 Documentation

### 📖 Documentation complète (dans le ZIP)
- **Rapport Technique** : Architecture et choix techniques
- **Documentation API** : Endpoints et utilisation
- **Guide d'utilisation** : Manuel utilisateur
- **Documentation d'accessibilité** : Tests et conformité

### 🎯 Fonctionnalités principales
- ✅ **Authentification** Firebase Auth
- ✅ **Quiz multijoueur** en temps réel
- ✅ **Système de points** et progression
- ✅ **Boutique virtuelle** avec achats in-app
- ✅ **Accessibilité** conforme WCAG 2.1
- ✅ **Support multiplateforme** (Android, iOS, Web)

### 🛡️ Sécurité
- Authentification JWT
- Validation des données
- Protection CORS
- Rate limiting

---

## 🚀 Démarrage rapide

### 1️⃣ Lancez le backend
```bash
cd AMQuizBackEnd
npm install
npm start
```

### 2️⃣ Lancez le frontend
```bash
cd fluttertest
flutter pub get
flutter run
```

### 3️⃣ Testez l'application
- Créez un compte ou connectez-vous
- Explorez les différents modes de jeu
- Testez les fonctionnalités multijoueur

---

## 🤝 Développement

### 🔧 Outils recommandés
- **VS Code** avec extensions Flutter/Dart
- **Android Studio** pour l'émulation Android
- **Postman** pour tester l'API backend
- **Firebase Console** pour la gestion des données

### 🐛 Debugging
```bash
# Flutter debug
flutter run --verbose

# Backend debug
npm run dev  # Si script configuré
```

---

## 📞 Support

Pour toute question concernant l'installation ou l'utilisation :
1. Consultez la documentation complète dans le ZIP
2. Vérifiez les logs d'erreur
3. Assurez-vous que tous les prérequis sont installés

---

## 📄 Licence

Ce projet est développé dans le cadre du **Bloc 2** - Formation Développement Mobile.

**Auteur** : [Votre nom]  
**Date** : [Date actuelle]  
**Version** : 1.0.0

---

> 💡 **Conseil** : Utilisez toujours le fichier ZIP pour une installation complète et fonctionnelle du projet.
