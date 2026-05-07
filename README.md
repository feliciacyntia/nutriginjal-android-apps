# NutriGinjal 🥗

Aplikasi mobile Flutter untuk manajemen nutrisi dan kesehatan ginjal. Menyediakan panduan nutrisi personal, konsultasi AI, dan monitoring data laboratorium untuk pasien CKD (Chronic Kidney Disease).

## 📱 Fitur Utama

- **🔐 Autentikasi Aman** - Google Sign-In terintegrasi
- **🤖 AI Konsultasi** - Chatbot powered by Google Gemini untuk saran nutrisi personal
- **📊 CKD Form** - Form tracking kondisi kesehatan ginjal
- **🔬 Lab Monitoring** - Tracking hasil laboratorium dan history
- **🍽️ Nutrisi Kustom** - Rekomendasi menu berdasarkan kondisi kesehatan
- **👤 Profil Pasien** - Manajemen data pribadi dan medis
- **💬 Chat Support** - Fitur komunikasi dengan tim medis

## 🛠️ Tech Stack

### Frontend
- **Flutter** ^3.11.4 - Framework mobile UI
- **Dart** - Bahasa pemrograman

### Backend & Services
- **Supabase** ^2.8.1 - Database & Authentication
- **Firebase** - Cloud services (google-services.json)
- **Google Sign-In** ^6.2.1 - OAuth authentication
- **Google Generative AI** ^0.4.5 - Gemini AI API

### Libraries
- `flutter_markdown` ^0.7.3 - Markdown rendering
- `csv` ^6.0.0 - CSV parsing
- `intl` ^0.19.0 - Internationalization
- `cupertino_icons` ^1.0.8 - iOS icons

## 📁 Struktur Proyek

```
lib/
├── main.dart              # Entry point aplikasi
├── core/                  # Core utilities & constants
│   ├── constants/        # App constants
│   └── utils/            # Helper functions
├── data/                  # Data layer
│   └── models/           # Data models
├── models/                # Domain models
│   └── ckd_form_model.dart
├── services/              # Business logic & API calls
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── chat_service.dart
│   ├── gemini_service.dart
│   ├── lab_service.dart
│   ├── nutrisi_service.dart
│   └── profile_service.dart
└── ui/                    # UI layer
    ├── pages/            # Screen/pages
    └── widgets/          # Reusable widgets
```

## 🚀 Instalasi & Setup

### Prerequisites
- Flutter SDK ^3.11.4
- Dart SDK
- Android Studio / Xcode
- Git

### Langkah Instalasi

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd nutriginjal
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase (Android)**
   - Download `google-services.json` dari Firebase Console
   - Letakkan di `android/app/`
   - File sudah ada di repository (jangan commit ke Git)

4. **Setup Environment Variables**
   pada file lib\core\constants\supabase_config.dart, disana kamu ganti api gemini dan supabasenya, sesuaikan, ouh ya saya pakai local hehe.

5. **Run Aplikasi**
   ```bash
   flutter run
   ```

## 🏗️ Build & Release

### Development Build
```bash
flutter run
```

### Release Build (Android)
```bash
flutter build apk --release
# atau untuk app bundle:
flutter build appbundle --release
```

### Release Build (iOS)
```bash
flutter build ios --release
```

## 📝 Environment Variables

File `.env` diperlukan untuk konfigurasi (jangan commit ke Git):
- `GEMINI_API_KEY` - API key dari Google Gemini
- `SUPABASE_URL` - URL Supabase project
- `SUPABASE_ANON_KEY` - Anonymous key Supabase

## 🔒 Security Notes

⚠️ **File Sensitif (Jangan Commit):**
- `google-services.json` - Firebase credentials
- `.env` - API keys & secrets
- `local.properties` - Android local config
- `.vscode/launch.json` - Debug configuration

Lihat `.gitignore` untuk daftar lengkap file yang di-exclude.

## 📚 API Integration

### Supabase
Database dan authentication backend menggunakan Supabase PostgreSQL.

### Firebase
Push notifications dan Cloud Messaging via Firebase.

### Google Generative AI (Gemini)
Chatbot untuk konsultasi nutrisi dan kesehatan ginjal.

## 🧪 Testing

```bash
flutter test
```