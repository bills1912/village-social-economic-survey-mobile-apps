# 🏘️ Aplikasi Android – Pendataan Desa Suka Makmur

Aplikasi Flutter Android untuk sistem pendataan keluarga dan survei lapangan
Desa Suka Makmur. Terintegrasi penuh dengan backend Filament PHP yang sudah
ada, dengan dukungan **offline-first**.

---

## 📱 Fitur Utama

| Fitur | Keterangan |
|---|---|
| **Dashboard** | Statistik real-time dengan filter per dusun |
| **Form Pendataan** | Form 3 langkah: Data KK → Anggota → Konfirmasi |
| **Anggota Keluarga** | Isian lengkap sesuai kuesioner (r_200..r_212) |
| **Laporan 4 Tab** | Ringkasan, Demografi, Pendidikan, Per Dusun |
| **Mode Offline** | Data tersimpan SQLite, auto-sync saat online |
| **Draft** | Simpan draft pendataan yang belum selesai |
| **Network Banner** | Indikator offline di atas layar |

---

## 🗂️ Struktur Proyek

```
lib/
├── main.dart                          # Entry point + MultiProvider
├── models/
│   ├── questionnaire.dart             # Questionnaire, AnggotaKeluarga, dll.
│   └── user.dart                      # User, Survey
├── providers/
│   ├── auth_provider.dart             # Login/Logout state
│   ├── questionnaire_provider.dart    # CRUD + stats
│   └── connectivity_provider.dart    # Online/offline + auto-sync
├── services/
│   ├── api_service.dart               # HTTP client → Filament backend
│   └── storage_service.dart          # SQLite + SharedPreferences
├── utils/
│   └── app_theme.dart                 # Theme, warna, konstanta
├── screens/
│   ├── splash_screen.dart
│   ├── auth/login_screen.dart
│   ├── main/main_screen.dart          # Bottom navigation
│   ├── dashboard/dashboard_screen.dart
│   ├── kuesioner/
│   │   ├── kuesioner_list_screen.dart
│   │   ├── kuesioner_form_screen.dart # Form 3 langkah
│   │   ├── kuesioner_detail_screen.dart
│   │   └── draft_screen.dart
│   ├── laporan/laporan_screen.dart    # 4 tabs
│   └── profil/profil_screen.dart
└── widgets/
    ├── stat_card.dart
    ├── chart_widgets.dart             # Pie, Bar, Officer charts
    ├── age_chart.dart                 # Kelompok usia
    ├── form_widgets.dart              # FormInput, Dropdown, Radio
    └── network_banner.dart            # Offline indicator
```

---

## ⚙️ Setup

### 1. Prasyarat
- Flutter SDK ≥ 3.5.0
- Android Studio / VS Code
- Android device / emulator (API 21+)

### 2. Clone & Install
```bash
cd desa_suka_makmur
flutter pub get
```

### 3. Konfigurasi URL Backend
Edit `lib/utils/app_theme.dart`:
```dart
static const String apiBaseUrl = 'https://URL-SERVER-ANDA.com/api';
```

> **Lokal (emulator Android):** gunakan `http://10.0.2.2:8000/api`
> **Lokal (device fisik):** gunakan IP LAN, mis. `http://192.168.1.x:8000/api`

### 4. Assets
Buat folder dan tambahkan file (opsional, gambar logo dll.):
```bash
mkdir -p assets/images assets/fonts
```

### 5. Build & Run
```bash
# Debug
flutter run

# Release APK
flutter build apk --release
```

---

## 🔌 Integrasi Backend Filament PHP

Aplikasi ini mengkonsumsi endpoint berikut dari backend Anda:

| Endpoint | Method | Keterangan |
|---|---|---|
| `/api/login` | POST | Login, mengembalikan `token` |
| `/api/logout` | POST | Logout |
| `/api/surveys` | GET | Daftar survei |
| `/api/questionnaires` | GET | Daftar kuesioner (support `?dusun=&survey_id=`) |
| `/api/questionnaires` | POST | Buat kuesioner baru |
| `/api/questionnaires/{id}` | PUT | Update kuesioner |
| `/api/questionnaires/{id}` | DELETE | Hapus kuesioner |
| `/api/statistics` | GET | Statistik (support `?dusun=`) |

> Jika backend belum memiliki endpoint API JSON, tambahkan route API di
> `routes/api.php` Laravel dan gunakan Sanctum untuk autentikasi token.

### Contoh response login yang diharapkan:
```json
{
  "token": "1|abc123...",
  "user": {
    "id": 1,
    "name": "Admin",
    "email": "admin@admin.com",
    "roles": [{"name": "super_admin"}]
  }
}
```

---

## 📦 Dependensi Utama

```yaml
provider: ^6.1.1          # State management
http: ^1.1.2              # HTTP client
sqflite: ^2.3.0           # SQLite lokal
shared_preferences: ^2.2.2 # Key-value storage
connectivity_plus: ^5.0.2  # Network monitoring
geolocator: ^10.1.0       # GPS (opsional, untuk lokasi rumah)
fl_chart: ^0.65.0         # Charts (opsional upgrade)
```

---

## 🎨 Tema Visual

Terinspirasi dari **Field-Tracker** dengan warna khas **BPS (Badan Pusat Statistik)**:

- **Primary**: `#0B6BA8` (Biru BPS)
- **Secondary**: `#1976D2`
- **Accent Green**: `#4CAF50`
- **Accent Orange**: `#FF9800` (indikator pending/offline)
- Per-dusun memiliki warna unik untuk visualisasi

---

## 📝 Catatan

- Data yang diisi secara offline disimpan di SQLite lokal dan
  otomatis disinkronisasi ke server setiap 3 menit saat online.
- Untuk melihat draft yang belum selesai, tekan ikon `edit_note`
  di halaman Kuesioner.
- Field form sesuai persis dengan kolom database di migrasi
  `2025_05_25_143607_create_questionnaires_table.php`.
