# TODO: Fix dart:html in Flutter app

## Step 1 — Audit
- [x] Cari seluruh `import 'dart:html'` di folder `lib/`
  - Ditemukan: 1 file
    - lib/app/modules/detail_resep/views/detail_resep_view.dart
- [x] Cari seluruh penggunaan `html.window`
  - Ditemukan: 1 file
    - lib/app/modules/detail_resep/views/detail_resep_view.dart

## Step 2 — Refactor Web-only code
- [x] Update `lib/app/modules/detail_resep/views/detail_resep_view.dart`:
  - [x] Hapus import `dart:html`
  - [x] Ganti pembukaan YouTube/video link agar cross-platform via `url_launcher`
  - [x] Pastikan tidak ada lagi referensi `html.window`
- [x] Tambahkan helper `lib/app/utils/launch_url_utils.dart`

## Step 3 — Verify compile safety
- [x] Tidak ada lagi referensi ke `dart:html` di project
- [ ] Jalankan:
  - `flutter clean`
  - `flutter pub get`
  - `flutter analyze`
- [ ] Pastikan build Android dan iOS tidak gagal

