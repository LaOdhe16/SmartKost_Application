<div align="center">

# 🔑 SmartKost

### Sistem Informasi Manajemen Pengelolaan Kost dan Otomatisasi Penagihan Berbasis Android

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://www.android.com)

**Kelas 23-TK · Program Studi Teknik Komputer · Fakultas Ilmu Komputer**
**Universitas AMIKOM Yogyakarta · 2026**

[Fitur](#-fitur-utama) •
[Tech Stack](#-tech-stack) •
[Instalasi](#-instalasi--menjalankan-project) •
[Unduh APK](#-unduh-aplikasi) •
[Tim](#-tim-pengembang)

</div>

---

## 📖 Tentang Proyek

**SmartKost** adalah aplikasi mobile berbasis Android yang dirancang untuk mendigitalisasi seluruh ekosistem operasional rumah kost — mulai dari pemetaan visual kamar, manajemen data penghuni, otomatisasi penagihan sewa, pelaporan keluhan/kerusakan, hingga laporan keuangan bulanan — dalam satu platform terpadu (*all-in-one platform*).

Aplikasi ini menggantikan pencatatan manual berbasis buku besar atau spreadsheet yang rentan *human error* dan tidak terintegrasi, dengan sistem digital real-time yang dapat diakses oleh **Pemilik (Admin)**, **Staf/Penjaga (Moderator)**, dan **Penghuni**, masing-masing dengan tampilan dan wewenang yang berbeda sesuai peran (*Role-Based Access Control*).

## 🎯 Latar Belakang Masalah

| Masalah | Dampak |
|---|---|
| Pemantauan status kamar tidak real-time | Menghambat pemasaran kamar kosong ke calon penyewa |
| Data penghuni tersebar & tidak terpusat | Sulit diakses saat kondisi darurat |
| Tidak ada pengingat jatuh tempo otomatis | Arus kas terganggu, penagihan manual canggung |
| Keluhan kerusakan dilaporkan via chat pribadi | Mudah hilang, tanpa jejak status/biaya perbaikan |
| Tidak ada laporan laba/rugi otomatis | Pemilik kesulitan mengetahui profitabilitas bulanan |

## ✨ Fitur Utama

### 👤 Autentikasi & Role-Based Access Control (RBAC)
- Login & Register dengan Email/Password
- Login dengan Akun Google
- Lupa Password (reset via email)
- Tiga peran pengguna dengan hak akses berbeda:

  | Peran | Hak Akses |
  |---|---|
  | **Admin** (Pemilik) | Akses penuh: kamar, keuangan, tagihan, tiket, kelola staf |
  | **Moderator** (Staf/Penjaga) | Denah kamar, daftarkan penghuni baru, respons keluhan — tanpa akses keuangan |
  | **Penghuni** | Kamar & tagihan pribadi, ajukan laporan keluhan |

- Mekanisme *access revocation* — akun penghuni yang di-*checkout* otomatis kehilangan akses (bukan lagi dianggap admin)

### 🏠 Manajemen Kamar (Visual Room Mapping)
- Denah kamar berbentuk grid dengan indikator warna: 🟢 Kosong · 🔴 Terisi · 🔵 Booking · 🟡 Perbaikan
- CRUD kamar lengkap (tambah, edit, hapus)
- Kartu statistik real-time (total, kosong, terisi, booking)

### 🧑‍🤝‍🧑 Manajemen Penghuni & Kontrak Sewa
- Admin dapat mendaftarkan akun penghuni langsung dari aplikasi (tanpa mengganggu sesi admin)
- Pencatatan kontak (nomor HP & kontak darurat)
- *Contract lifecycle* — hitung mundur masa sewa, berubah merah otomatis saat ≤ 7 hari
- Checkout penghuni yang telah selesai masa sewa

### 🎫 Modul Ticketing (Keluhan/Kerusakan)
- Pelaporan keluhan oleh penghuni (kategori: Listrik, Air, AC, Furnitur, Kebersihan, Lainnya)
- Tingkat urgensi: Rendah, Sedang, Tinggi
- Alur status: **Menunggu → Diproses → Selesai**
- Pencatatan biaya perbaikan saat tiket diselesaikan

### 💳 Modul Keuangan (Automated Invoicing)
- Admin membuat tagihan sewa bulanan (nominal otomatis sesuai tarif kamar)
- Penghuni mengunggah foto bukti transfer dari kamera/galeri
- Verifikasi admin: **Setujui** / **Tolak**
- Status tagihan: **Belum Bayar → Menunggu Verifikasi → Lunas**

### 📊 Income & Expense Tracker
- Input pengeluaran operasional (listrik, air, WiFi, gaji staf, perbaikan, lainnya)
- Kalkulasi otomatis **Laba/Rugi Bersih** per bulan (Pemasukan dari tagihan lunas − Pengeluaran)
- Navigasi laporan antar bulan
- **Ekspor laporan ke CSV**, siap dibagikan via WhatsApp/Google Drive

---

## 🛠️ Tech Stack

| Komponen | Teknologi |
|---|---|
| **Framework** | Flutter (Dart SDK) — Material Design 3 |
| **Autentikasi** | Firebase Authentication (Email/Password & Google Sign-In) |
| **Database** | Cloud Firestore (NoSQL, real-time) |
| **Tipografi** | Google Fonts (Poppins & Inter) |
| **Media** | image_picker (ambil foto bukti transfer) |
| **Ekspor Data** | path_provider + share_plus (ekspor CSV) |
| **Build & Rilis** | Gradle Signing Config + Keystore (.jks) |

### Arsitektur Proyek

Kode program disusun menggunakan pendekatan **feature-based architecture** — setiap modul fungsional memiliki foldernya sendiri berisi model data, service, dan halaman antarmuka.

```
lib/
├── core/                    # Tema, warna, spacing, service dasar
│   ├── constants/
│   ├── theme/
│   └── services/
├── features/
│   ├── auth/                # Login, Register, RBAC, AuthGate
│   ├── rooms/                # Manajemen kamar & data penghuni
│   ├── tickets/              # Modul keluhan/ticketing
│   ├── invoices/             # Tagihan & verifikasi pembayaran
│   ├── finance/               # Pengeluaran & laporan laba/rugi
│   ├── home/                  # Dasbor Admin/Moderator
│   └── resident/              # Dasbor Penghuni
└── shared/
    └── widgets/               # Komponen UI yang dipakai ulang
```

---

## 📸 Tangkapan Layar

<div align="center">

| Login | Dasbor Admin | Detail Kamar |
|---|---|---|
| *(tempel screenshot di sini)* | *(tempel screenshot di sini)* | *(tempel screenshot di sini)* |

| Dasbor Penghuni | Papan Tagihan | Laporan Keuangan |
|---|---|---|
| *(tempel screenshot di sini)* | *(tempel screenshot di sini)* | *(tempel screenshot di sini)* |

</div>

> 💡 Ganti baris di atas dengan gambar sungguhan. Upload screenshot ke folder `screenshots/` pada repo, lalu ganti teks *(tempel screenshot di sini)* dengan `![nama](screenshots/nama-file.png)`.

---

## 📲 Unduh Aplikasi

Aplikasi sudah tersedia dalam bentuk APK release yang siap diinstal di perangkat Android:

**[⬇️ Download app-release.zip](../../releases)** — ekstrak berkas zip untuk mendapatkan `app-release.apk`, lalu instal di HP Android Anda.

> ⚠️ Karena APK ini tidak diunduh dari Google Play Store, Android akan meminta izin **"Izinkan instalasi dari sumber tidak dikenal"** saat pertama kali membuka berkasnya — aktifkan izin tersebut untuk melanjutkan instalasi.

---

## 🚀 Instalasi & Menjalankan Project

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi stabil terbaru)
- [Android Studio](https://developer.android.com/studio) (untuk emulator & SDK Android)
- Editor kode (disarankan [VS Code](https://code.visualstudio.com/) dengan ekstensi Flutter & Dart)
- Akun [Firebase](https://firebase.google.com/) untuk konfigurasi backend

### Langkah Instalasi

1. **Clone repository ini**
   ```bash
   git clone https://github.com/LaOdhe16/SmartKost_Application.git
   cd SmartKost_Application
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Firebase**

   Repo ini **tidak menyertakan** berkas konfigurasi Firebase (`google-services.json` dan `firebase_options.dart`) demi keamanan. Untuk menjalankan project secara lokal:
   - Buat project baru di [Firebase Console](https://console.firebase.google.com/)
   - Aktifkan **Authentication** (Email/Password & Google), **Cloud Firestore**
   - Jalankan `flutterfire configure` untuk membuat ulang `firebase_options.dart`, atau minta berkas konfigurasi dari pengembang project ini

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

### Build APK Release

```bash
flutter build apk --release
```
Berkas hasil build akan tersedia di `build/app/outputs/flutter-apk/app-release.apk`.

> Membutuhkan konfigurasi *signing key* (`android/key.properties`) yang **tidak disertakan** dalam repo ini demi keamanan kredensial.

---

## 🔐 Keamanan & Firestore Rules

Akses baca/tulis basis data dibatasi hanya untuk pengguna yang telah terautentikasi:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🗺️ Roadmap Pengembangan Selanjutnya

- [ ] Integrasi WhatsApp Gateway untuk pengingat tagihan otomatis (H-3 & Hari-H)
- [ ] Migrasi penyimpanan foto ke Cloud Storage seiring skala pengguna bertambah
- [ ] Notifikasi push berbasis server (Cloud Functions)
- [ ] Upload foto KTP (E-KYC) untuk verifikasi identitas penghuni

---

## 👥 Tim Pengembang

| Nama | NIM |
|---|---|
| Salvado Agus Firmansyah Ode | 23.83.0994 |
| Samuel Daya Anugerah | 23.83.0955 |
| Yohanes Yusuf Christolic | 23.83.0989 |

**Kelas 23-TK** — Program Studi Teknik Komputer, Fakultas Ilmu Komputer, Universitas AMIKOM Yogyakarta

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan tugas akademik (Praktikum Pemrograman Selular) dan tidak dimaksudkan untuk penggunaan komersial.

---

<div align="center">

Dibuat dengan 💚 menggunakan Flutter & Firebase

</div>
