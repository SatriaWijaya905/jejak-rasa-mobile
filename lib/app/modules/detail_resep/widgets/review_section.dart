import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/notification_service.dart';

class _ReplyComposer extends StatefulWidget {
  final String resepId;
  final String reviewId;
  final VoidCallback? onClose;

  const _ReplyComposer({
    required this.resepId,
    required this.reviewId,
    this.onClose,
  });

  @override
  State<_ReplyComposer> createState() => _ReplyComposerState();
}

class _ReplyComposerState extends State<_ReplyComposer> {
  final _controller = TextEditingController();
  final _replyFocusNode = FocusNode();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'Perlu login',
        'Silakan login untuk membalas komentar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 16,
      );
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Reply kosong',
        'Balasan tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 16,
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? {};

      await FirebaseFirestore.instance
          .collection('resep')
          .doc(widget.resepId)
          .collection('reviews')
          .doc(widget.reviewId)
          .collection('replies')
          .add({
            'uid': user.uid,
            'nama_user': userData['nama'] ?? 'User',
            'foto_user': userData['foto_profil'] ?? '',
            'komentar': text,
            'created_at': DateTime.now(),
          });

      _controller.clear();
      _replyFocusNode.unfocus();
      Get.snackbar(
        'Berhasil',
        'Reply berhasil dikirim',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 16,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 16,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              focusNode: _replyFocusNode,
              controller: _controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Tulis balasan...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.onClose != null)
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          _busy
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Color(0xFFF5A623),
                      strokeWidth: 2,
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: _busy ? null : _sendReply,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5A623),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _ReplyList extends StatelessWidget {
  final String resepId;
  final String reviewId;

  const _ReplyList({required this.resepId, required this.reviewId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('resep')
          .doc(resepId)
          .collection('reviews')
          .doc(reviewId)
          .collection('replies')
          .orderBy('created_at', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const SizedBox.shrink();

        return Column(
          children: docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            final createdAt = data['created_at'];
            String timeText = '';
            if (createdAt is Timestamp) {
              timeText = _timeAgo(createdAt.toDate());
            }

            return Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFFFFF8EE),
                    backgroundImage:
                        (data['foto_user'] != null &&
                            (data['foto_user'] as String).isNotEmpty)
                        ? NetworkImage(data['foto_user'] as String)
                        : null,
                    child:
                        (data['foto_user'] == null ||
                            (data['foto_user'] as String).isEmpty)
                        ? const Icon(
                            Icons.person_rounded,
                            size: 12,
                            color: Color(0xFFF5A623),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data['nama_user'] ?? 'User',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (timeText.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                timeText,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data['komentar'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ReplySection extends StatefulWidget {
  final String resepId;
  final String reviewId;
  final String? currentUid;

  const _ReplySection({
    required this.resepId,
    required this.reviewId,
    this.currentUid,
  });

  @override
  State<_ReplySection> createState() => _ReplySectionState();
}

class _ReplySectionState extends State<_ReplySection> {
  bool _showComposer = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              if (widget.currentUid != null)
                _LikeButton(
                  resepId: widget.resepId,
                  reviewId: widget.reviewId,
                  userUid: widget.currentUid!,
                ),
              if (widget.currentUid != null)
                const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  setState(() => _showComposer = !_showComposer);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Reply',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showComposer)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _ReplyComposer(
              resepId: widget.resepId,
              reviewId: widget.reviewId,
              onClose: () => setState(() => _showComposer = false),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: _ReplyList(resepId: widget.resepId, reviewId: widget.reviewId),
        ),
      ],
    );
  }
}

String _timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inDays > 365)
    return '${(diff.inDays / 365).floor()} tahun yang lalu';
  if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} bulan yang lalu';
  if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} minggu yang lalu';
  if (diff.inDays > 0) return '${diff.inDays} hari yang lalu';
  if (diff.inHours > 0) return '${diff.inHours} jam yang lalu';
  if (diff.inMinutes > 0) return '${diff.inMinutes} menit yang lalu';
  return 'Baru saja';
}

class _RatingPicker extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const _RatingPicker({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => onChanged(starValue.toDouble()),
          icon: Icon(
            starValue <= rating
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            color: const Color(0xFFF5A623),
            size: 28,
          ),
        );
      }),
    );
  }
}

class _LikeButton extends StatefulWidget {
  final String resepId;
  final String reviewId;
  final String userUid;

  const _LikeButton({
    required this.resepId,
    required this.reviewId,
    required this.userUid,
  });

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  bool _optimisticLiked = false;
  bool _busy = false;

  DocumentReference<Map<String, dynamic>> get _likeDoc {
    return FirebaseFirestore.instance
        .collection('resep')
        .doc(widget.resepId)
        .collection('reviews')
        .doc(widget.reviewId)
        .collection('likes')
        .doc(widget.userUid);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _optimisticLiked;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('resep')
          .doc(widget.resepId)
          .collection('reviews')
          .doc(widget.reviewId)
          .collection('likes')
          .snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;

        return GestureDetector(
          onTap: _busy
              ? null
              : () async {
                  if (!mounted) return;

                  setState(() {
                    _busy = true;
                    _optimisticLiked = !_optimisticLiked;
                  });

                  try {
                    if (_optimisticLiked) {
                      await _likeDoc.set({'created_at': DateTime.now()});
                    } else {
                      await _likeDoc.delete();
                    }
                  } catch (_) {
                    if (!mounted) return;
                    // revert optimistic state
                    setState(() {
                      _optimisticLiked = !_optimisticLiked;
                    });
                  } finally {
                    if (!mounted) return;
                    setState(() => _busy = false);
                  }
                },
          child: Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  accent ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  size: 16,
                  color: accent ? const Color(0xFFFF4B4B) : Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent
                        ? const Color(0xFFFF4B4B)
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReviewActions extends StatelessWidget {
  final bool isOwner;
  final String resepId;
  final String reviewId;
  final String initialKomentar;
  final double initialRating;

  const _ReviewActions({
    required this.isOwner,
    required this.resepId,
    required this.reviewId,
    required this.initialKomentar,
    required this.initialRating,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOwner) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
            onSelected: (value) async {
              if (value == 'edit') {
                final komentarController = TextEditingController(
                  text: initialKomentar,
                );
                double ratingTmp = initialRating;

                await Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      'Edit Review',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RatingPicker(
                            rating: ratingTmp,
                            onChanged: (v) {
                              ratingTmp = v;
                              (context as Element).markNeedsBuild();
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: komentarController,
                            maxLines: 3,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Tulis komentar...',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFF5A623),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5A623),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final newKomentar = komentarController.text.trim();
                          if (newKomentar.isEmpty) {
                            Get.snackbar(
                              'Komentar kosong',
                              'Komentar tidak boleh kosong',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(12),
                              borderRadius: 16,
                            );
                            return;
                          }

                          await FirebaseFirestore.instance
                              .collection('resep')
                              .doc(resepId)
                              .collection('reviews')
                              .doc(reviewId)
                              .update({
                                'komentar': newKomentar,
                                'rating': ratingTmp,
                              });

                          final snap = await FirebaseFirestore.instance
                              .collection('resep')
                              .doc(resepId)
                              .collection('reviews')
                              .get();

                          double total = 0;
                          for (var d in snap.docs) {
                            total += (d.data()['rating'] ?? 0).toDouble();
                          }
                          final avg = snap.docs.isEmpty
                              ? 0
                              : total / snap.docs.length;

                          await FirebaseFirestore.instance
                              .collection('resep')
                              .doc(resepId)
                              .update({
                                'rating': avg,
                                'jumlah_review': snap.docs.length,
                              });

                          Get.back();
                        },
                        child: Text(
                          'Simpan',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (value == 'delete') {
                final ok = await Get.dialog<bool>(
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      'Hapus Review',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Yakin ingin menghapus review ini?',
                      style: GoogleFonts.poppins(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Get.back(result: true),
                        child: Text(
                          'Hapus',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );

                if (ok != true) return;

                await FirebaseFirestore.instance
                    .collection('resep')
                    .doc(resepId)
                    .collection('reviews')
                    .doc(reviewId)
                    .delete();

                final snap = await FirebaseFirestore.instance
                    .collection('resep')
                    .doc(resepId)
                    .collection('reviews')
                    .get();

                double total = 0;
                for (var d in snap.docs) {
                  total += (d.data()['rating'] ?? 0).toDouble();
                }
                final avg = snap.docs.isEmpty ? 0 : total / snap.docs.length;

                await FirebaseFirestore.instance
                    .collection('resep')
                    .doc(resepId)
                    .update({'rating': avg, 'jumlah_review': snap.docs.length});
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text('Edit', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_rounded,
                      size: 18,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hapus',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

class ReviewSection extends StatefulWidget {
  final String resepId;

  const ReviewSection({super.key, required this.resepId});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final komentarC = TextEditingController();
  double rating = 5;
  bool isLoadingSubmit = false;

  static const Color _accent = Color(0xFFF5A623);
  static const Color _cream = Color(0xFFFFF8EE);

  Future<void> submitReview() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'Perlu login',
          'Silakan login untuk memberi review',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 16,
        );
        return;
      }

      final komentar = komentarC.text.trim();
      if (komentar.isEmpty) {
        Get.snackbar(
          'Komentar kosong',
          'Komentar tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 16,
        );
        return;
      }

      setState(() => isLoadingSubmit = true);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? {};

      final reviewDocRef = await FirebaseFirestore.instance
          .collection('resep')
          .doc(widget.resepId)
          .collection('reviews')
          .add({
            'uid': user.uid,
            'nama_user': userData['nama'] ?? 'User',
            'foto_user': userData['foto_profil'] ?? '',
            'komentar': komentar,
            'rating': rating,
            'created_at': DateTime.now(),
          });

      final resepDoc = await FirebaseFirestore.instance
          .collection('resep')
          .doc(widget.resepId)
          .get();
      final resepData = resepDoc.data() as Map<String, dynamic>?;
      final ownerUid = (resepData?['author_uid'] as String?) ?? '';
      final recipeName = (resepData?['nama_resep'] as String?) ?? 'Resep';

      final reviewSnapshot = await FirebaseFirestore.instance
          .collection('resep')
          .doc(widget.resepId)
          .collection('reviews')
          .get();

      double total = 0;
      for (var doc in reviewSnapshot.docs) {
        total += (doc.data()['rating'] ?? 0).toDouble();
      }
      final average = reviewSnapshot.docs.isEmpty
          ? 0
          : total / reviewSnapshot.docs.length;

      await FirebaseFirestore.instance
          .collection('resep')
          .doc(widget.resepId)
          .update({
            'rating': average,
            'jumlah_review': reviewSnapshot.docs.length,
          });

      if (ownerUid.trim().isNotEmpty && user.uid.trim().isNotEmpty) {
        await NotificationService.sendCommentRecipeNotification(
          recipeOwnerUid: ownerUid,
          senderUid: user.uid,
          senderName: userData['nama'] ?? 'Pengguna',
          senderPhoto: userData['foto_profil'] ?? '',
          recipeId: widget.resepId,
          recipeName: recipeName,
          notifId: reviewDocRef.id,
        );
      }

      komentarC.clear();
      setState(() => rating = 5);
      FocusScope.of(context).unfocus();

      Get.snackbar(
        'Berhasil',
        'Review berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 16,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 16,
      );
    } finally {
      setState(() => isLoadingSubmit = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('resep')
                .doc(widget.resepId)
                .snapshots(),
            builder: (context, snapshot) {
              double avg = 0;
              int totalReview = 0;
              if (snapshot.hasData && snapshot.data!.data() != null) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                avg = (data['rating'] ?? 0).toDouble();
                totalReview = data['jumlah_review'] ?? 0;
              }
              return Row(
                children: [
                  const Icon(Icons.star_rounded, color: _accent, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '${avg.toStringAsFixed(1)} ',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '($totalReview ulasan)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Form Review
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beri Penilaian',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(5, (index) {
                    return IconButton(
                      padding: const EdgeInsets.only(right: 4),
                      constraints: const BoxConstraints(),
                      onPressed: () =>
                          setState(() => rating = (index + 1).toDouble()),
                      icon: Icon(
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: _accent,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: komentarC,
                  maxLines: 3,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Bagaimana hasil resep ini menurutmu?',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _accent, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_accent, Color(0xFFFF8C00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: isLoadingSubmit ? null : submitReview,
                      child: isLoadingSubmit
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Kirim Review',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Ulasan Pengguna',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('resep')
                .doc(widget.resepId)
                .collection('reviews')
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: _accent),
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Jadilah yang pertama mengulas resep ini!',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final currentUid = FirebaseAuth.instance.currentUser?.uid;

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final isOwner =
                      currentUid != null && data['uid'] == currentUid;

                  // Format time
                  String timeText = '';
                  if (data['created_at'] != null) {
                    final timestamp = data['created_at'] as Timestamp;
                    timeText = _timeAgo(timestamp.toDate());
                  }

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: _cream,
                                backgroundImage:
                                    (data['foto_user'] != null &&
                                        data['foto_user'] != '')
                                    ? NetworkImage(data['foto_user'])
                                    : null,
                                child:
                                    (data['foto_user'] == null ||
                                        data['foto_user'] == '')
                                    ? const Icon(
                                        Icons.person_rounded,
                                        color: _accent,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['nama_user'] ?? 'Pengguna',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(
                                          (data['rating'] ?? 0).toInt(),
                                          (i) => const Icon(
                                            Icons.star_rounded,
                                            size: 14,
                                            color: Color(0xFFF5A623),
                                          ),
                                        ),
                                      ),
                                      if (timeText.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade400,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          timeText,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _ReviewActions(
                              isOwner: isOwner,
                              resepId: widget.resepId,
                              reviewId: doc.id,
                              initialKomentar: data['komentar'] ?? '',
                              initialRating: (data['rating'] ?? 0).toDouble(),
                            ),
                          ],
                        ),
                        if (data['komentar'] != null &&
                            data['komentar'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 46),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['komentar'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                                _ReplySection(
                                  resepId: widget.resepId,
                                  reviewId: doc.id,
                                  currentUid: currentUid,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
