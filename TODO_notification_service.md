# TODO_NOTIFICATION_SERVICE

## Step 1
- Verifikasi masalah utama pada notification_service: konsistensi field `resep_id` untuk tipe `save_recipe` agar bisa navigasi ke detail resep.

## Step 2
- Update `sendSaveRecipeNotification` supaya menulis `resep_id` (dan `resep_name` bila diperlukan) sesuai dengan skema yang dipakai `NotificationController.handleNotificationTap`.

## Step 3
- (Opsional/pendukung) Rapikan redudansi/inkonsistensi field pada `sendCommentRecipeNotification` & `sendRecipeNotification` agar konsisten: `resep_id` dipakai seragam.

## Step 4
- Rapikan validasi input (trim/empty check) untuk `uid`, `senderUid`, `notifId`, dan `resepId`.

## Step 5
- Jalankan `flutter analyze` dan (kalau memungkinkan) `flutter test`.

