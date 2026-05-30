# TODO TERBARU APPROVAL

## Flutter (Resep Terbaru)
- [x] Ubah query realtime “Terbaru” di:
  - [x] `NewestRecipesController` -> `where status=approved` + `orderBy approved_at desc`
  - [x] `ExploreController` -> `where status=approved` + `orderBy approved_at desc`
  - [x] `HomeController` (following feed) -> `where status=approved` + `orderBy approved_at desc`
  - [x] `ResepService.getResepTerbaru()` -> `where status=approved` + `orderBy approved_at desc`
- [ ] Tambahkan field `approvedAt` di `ResepModel` (approved_at -> DateTime) + null-safety
- [ ] Perbaiki compile error akibat penggunaan `approvedAt` di controller
- [ ] Implement fallback sorting client-side: `(approvedAt ?? createdAt)`
- [ ] Audit semua query “Terbaru”/newest yang masih `orderBy created_at` (jika ada)

## Dashboard Admin (Approval)
- [ ] Update `dashboard.html` tombol approve:
  - set `status='approved'`
  - set `approved_at=FieldValue.serverTimestamp()`
  - jangan sentuh `created_at`

