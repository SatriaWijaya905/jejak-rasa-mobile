import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../../services/notification_service.dart';

class ReviewService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addReview({
    required String resepId,
    required ReviewModel review,
  }) async {
    final ref = firestore
        .collection('resep')
        .doc(resepId)
        .collection('reviews');

    await ref.add(review.toJson());

    final reviews = await ref.get();

    double total = 0;

    for (var item in reviews.docs) {
      total += (item['rating'] ?? 0).toDouble();
    }

    double avg = reviews.docs.isEmpty ? 0 : total / reviews.docs.length;

    await firestore.collection('resep').doc(resepId).update({
      'rating': avg,
      'jumlah_review': reviews.docs.length,
    });

    // Send notification to recipe owner
    try {
      if (resepId.trim().isEmpty) return;

      final resepDoc = await firestore.collection('resep').doc(resepId).get();
      final resepData = resepDoc.data();

      final authorUid = (resepData?['author_uid'] as String?) ?? '';
      final senderUid = (review.uid as String?) ?? '';

      if (resepData == null) return;
      if (authorUid.trim().isEmpty) return;
      if (senderUid.trim().isEmpty) return;

      await NotificationService.sendReviewNotification(
        recipeOwnerUid: authorUid,
        senderUid: senderUid,
        senderName: review.namaUser ?? 'Pengguna',
        senderPhoto: review.fotoUser ?? '',
        resepId: resepId,
        resepName: resepData['nama_resep'] ?? 'Resep',
      );
    } catch (e) {
      print('Error triggering review notification: $e');
    }
  }
}
