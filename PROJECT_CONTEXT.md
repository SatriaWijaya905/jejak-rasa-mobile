# PROJECT CONTEXT — JEJAKRASA

## Roadmap Perbaikan JejakRasa

| No | Fitur                                                                                       | Status        | Tingkat Kesulitan | Kenapa                                              | Risiko/Error   | Prioritas     |
|----|----------------------------------------------------------------------------------------------|---------------|-------------------|-----------------------------------------------------|----------------|---------------|
| 1  | Perbaiki flow daftar → setelah daftar kembali ke login, bukan langsung home                 | ✅ Selesai    | Sangat Mudah      | Hanya ubah alur navigation setelah register         | Sangat kecil   | Tinggi        |
| 2  | Hapus fitur tidak berfungsi (target penerima notif admin, perbaiki card notif upload resep) |  ✅ Selesai   | Mudah             | Mayoritas cleanup UI dan logic sederhana            | Kecil          | Tinggi        |
| 3  | Perbaiki halaman edit profil                                                                | ✅ Selesai   | Mudah             | Hanya rapikan tampilan dan field yang tidak penting | Kecil          | Tinggi        |
| 4  | Tambahkan link video di buat resep                                                          | ✅ Selesai     | Mudah–Menengah    | Tambah field Firestore + tampilkan di detail resep  | Kecil          | Tinggi        |
| 5  | Perbaiki tombol “Lihat Semua” di home                                                       | ✅ Selesai      | Menengah          | Biasanya routing/filter/query belum sinkron         | Kecil–Menengah | Menengah      |
| 6  | Fitur cari user selain resep                                                                | ✅ Selesai      | Menengah          | Perlu search multi data (user + resep)              | Menengah       | Tinggi        |
| 7  | Kategori lebih detail per daerah                                                            | ✅ Selesai      | Menengah          | Perlu struktur kategori/filter baru                 | Menengah       | Menengah      |
| 8  | Halaman statistik dashboard admin berfungsi                                                 | ✅ Selesai     | Menengah–Sulit    | Perlu agregasi data Firestore + chart/statistik     | Menengah–Besar | Menengah      |
| 9  | Sistem reject resep + alasan admin + revisi user                                            | ❌ Belum      | Sulit             | Sudah masuk workflow approval/revision system       | Besar          | Sangat Tinggi |
| 10 | Reply komentar + like komentar                                                              | ✅ Selesai      | Sangat Sulit      | Sudah seperti sistem sosial media realtime          | Sangat Besar   | Sangat Tinggi |

# Tahapan Pengerjaan yang Disarankan

## Tahap 1 — Quick Win

Fokus:

* cepat selesai
* risiko kecil
* meningkatkan UX langsung

Isi:

1. [x] Perbaiki flow daftar
2. [x] Hapus fitur tidak berfungsi
3. [x] Perbaiki edit profil
4. [x] Tambahkan link video resep

---

## Tahap 2 — UX Improvement

Fokus:

* meningkatkan pengalaman pengguna
* memperjelas navigasi dan eksplorasi

Isi:

5. [x] Perbaiki tombol “Lihat Semua”
6. [x] Cari user selain resep
7. [x] Kategori lebih detail per daerah

---

## Tahap 3 — Dashboard System

Fokus:

* meningkatkan kualitas admin panel
* monitoring aplikasi

Isi:

8. [x] Statistik dashboard admin berfungsi

---

## Tahap 4 — Advanced Social Feature

Fokus:

* membuat JejakRasa terasa seperti aplikasi komunitas sosial kuliner

Isi:

9. Reject resep + revisi user
10. [x] Reply komentar + like komentar

---

# Fitur dengan Impact Terbesar

| Fitur                 | Impact                                            |
| --------------------- | ------------------------------------------------- |
| Reject + revisi resep | App terasa profesional seperti platform komunitas |
| Reply komentar        | App terasa hidup dan interaktif                   |
| Cari user             | Memperkuat konsep sosial/community                |
| Video resep           | Konten terasa modern dan engaging                 |

---

# Style & Design Context JejakRasa

## Tema UI

* Modern
* Premium
* Social food app
* Orange gradient branding
* Rounded corners
* Soft shadows
* Dark floating navbar
* Elegant spacing

---

## FAB Style

### Home & Favorite

* hanya icon "+"
* bulat kecil modern
* gradient orange
* floating kanan bawah

### Profil/Kreasi

* tombol besar:

```text id="jlwmctx"
+ Buat Resep
```

---

## Navbar Style

* Dark charcoal background
* Rounded floating navbar
* Orange active glow
* Premium soft shadow
* Minimalis modern

---

# Struktur Notifikasi Firebase

```text id="jlwmctx2"
notifications
   └── USER_UID
         └── items
               └── notifId
```

Dashboard admin HARUS broadcast notif ke:

```text id="jlwmctx3"
notifications/{uid}/items
```

JANGAN ke:

```text id="jlwmctx4"
notifications/
```

karena Flutter notif system sudah memakai struktur subcollection.

---

# Search System Rules

Search:

* jangan overwrite hasil search dengan realtime listener
* gunakan:

```text id="jlwmctx5"
searchQuery
searchResults
allResep
```

JANGAN gunakan:

```text id="jlwmctx6"
isSearching
```

untuk source utama mode search.

---

# Known Bugs / Catatan Penting

* Realtime listener Home pernah overwrite hasil search
* Navbar FAB pernah overlap dengan slider
* Dashboard admin notif pernah salah collection
* Creator profile pernah mismatch jumlah resep karena pakai cached arguments

---

# Goal JejakRasa

Target akhir:

* aplikasi komunitas resep modern
* realtime social food app
* premium UI
* creator-based platform
* support Flutter Web & Mobile
* Firebase realtime ecosystem
