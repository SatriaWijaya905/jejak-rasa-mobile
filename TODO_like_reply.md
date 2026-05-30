# TODO - Like Komentar + Reply Komentar (JejakRasa)

## Current status
- review_section.dart sudah dibersihkan dari duplikasi field/constructor pada _ReviewActions.
- Fitur inti LIKE + REPLY masih belum diimplementasikan.

## Next steps
- Rebuild review_section.dart dengan:
  - Like komentar (realtime + optimistic UI) memakai subcollection:
    - resep/{resepId}/reviews/{reviewId}/likes/{uid}
  - Reply komentar nested 1 level (realtime) memakai:
    - resep/{resepId}/reviews/{reviewId}/replies/{replyId}
  - UI: tombol like ❤️ + jumlah realtime, tombol Reply + input inline.
- Run flutter analyze (catat error bila ada) menggunakan command yang sesuai shell Windows.

