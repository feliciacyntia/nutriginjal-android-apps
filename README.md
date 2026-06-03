# NutriGinjal 🥗

Aplikasi mobile Flutter untuk manajemen nutrisi dan kesehatan ginjal. Menyediakan panduan nutrisi personal, konsultasi AI, dan monitoring data laboratorium untuk pasien CKD (Chronic Kidney Disease). NutriGinjal menghubungkan Pasien dan Dokter dalam satu ekosistem untuk pemantauan kesehatan ginjal yang lebih akurat.

## 📱 Fitur Utama

- **🔐 Autentikasi Multirole** - Google Sign-In terintegrasi untuk Pasien dan Dokter.
- **👨‍⚕️ Dashboard Dokter** - Statistik real-time, manajemen riwayat lab pasien, dan pemilihan pasien terintegrasi.
- **🤖 NutriSnap AI** - Chatbot cerdas bertenaga Google Gemini yang memberikan saran nutrisi dengan nada bicara yang empati dan ramah.
- **🔬 Analisis Prediksi CKD** - Integrasi dengan Model Machine Learning (Gradio API) untuk mendeteksi risiko penyakit ginjal berdasarkan parameter laboratorium.
- **📊 Manajemen Riwayat Lab** - Penyimpanan data laboratorium yang aman di Supabase dengan fitur detail dan penghapusan riwayat (CRUD lengkap).
- **👤 Profil & Sinkronisasi** - Sinkronisasi data profil otomatis menggunakan Trigger Supabase dan PostgreSQL.

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.x** - Framework UI lintas platform.
- **Dart** - Bahasa pemrograman utama.

### Backend & AI
- **Supabase** - Database PostgreSQL, Autentikasi, dan Real-time Stream.
- **Google Gemini Pro** - Engine AI untuk asisten gizi (menggunakan riwayat percakapan penuh).
- **Gradio API** - Hosting model Machine Learning untuk prediksi risiko CKD.
- **Google Sign-In** - OAuth 2.0 provider.

## 📁 Struktur Proyek (Terbaru)

```
lib/
├── core/                  # Utilitas inti & Konfigurasi
│   └── constants/         # Konfigurasi Supabase & API Key
├── data/                  # Layer Data
│   └── models/            # Model data (Lab, Chat, Profile, dll)
├── services/              # Logika Bisnis & Integrasi API
│   ├── api_service.dart   # Integrasi ML Prediksi CKD
│   ├── auth_service.dart  # Manajemen Auth Supabase
│   ├── chat_service.dart  # Manajemen Pesan Chat (Full History)
│   ├── gemini_service.dart# Integrasi Google Gemini
│   ├── lab_service.dart   # Manajemen Data Laboratorium
│   └── profile_service.dart
└── ui/                    # Layer Antarmuka (UI)
    ├── pages/             # Halaman (User & Doctor)
    │   ├── doctor/        # Dashboard & Fitur Dokter
    │   └── user/          # Fitur Pasien & Chat
    └── widgets/           # Komponen Reusable
```

## 🚀 Instalasi & Setup

### Prerequisites
- Flutter SDK (Versi terbaru)
- Akun Supabase (Project URL & Anon Key)
- API Key Google Gemini (dari Google AI Studio)

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

3. **Konfigurasi Environment**
   Buka file `lib/core/constants/supabase_config.dart` dan sesuaikan kredensial Anda (URL Supabase, Anon Key, dan Gemini API Key).

4. **Setup Database**
   Pastikan tabel `profiles`, `lab_results`, `chat_sessions`, dan `messages` sudah terkonfigurasi di Supabase dengan RLS (Row Level Security) yang sesuai agar data tetap aman.

5. **Run Aplikasi**
   ```bash
   flutter run
   ```

## 📝 Catatan Keamanan

⚠️ **PENTING:** Jangan pernah melakukan commit pada file `lib/core/constants/supabase_config.dart` jika berisi kunci API asli ke repositori publik. Selalu pastikan file tersebut masuk dalam daftar `.gitignore` atau gunakan variabel lingkungan.

---
© 2024 NutriGinjal Team - Health Tech Innovation
