  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:jejakrasa_mobile_database/app/services/notification_service.dart';

class FollowService {
  final FirebaseFirestore firestore;

  FollowService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _followingRef({
    required String currentUid,
  }) {
    return firestore
        .collection('users')
        .doc(currentUid)
        .collection('following');
  }

  CollectionReference<Map<String, dynamic>> _followersRef({
    required String creatorUid,
  }) {
    return firestore
        .collection('users')
        .doc(creatorUid)
        .collection('followers');
  }

  Map<String, dynamic> _buildFollowerDoc({
    required String currentUid,
    required String nama,
    required String fotoProfil,
  }) {
    return {
      'uid': currentUid,
      'nama': nama,
      'foto_profil': fotoProfil,
      'created_at': DateTime.now(),
    };
  }

  String? _sanitizeUid(String? uid) {
    final v = uid?.trim();
    if (v == null || v.isEmpty) return null;
    if (v.contains('/')) return null;
    return v;
  }

  Future<void> followUser({
    required String currentUid,
    required String creatorUid,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final authUid = _sanitizeUid(currentUser?.uid);

    final safeCreatorUid = _sanitizeUid(creatorUid);

    // Jika user tidak login atau creator kosong => skip (tidak crash)
    if (authUid == null || safeCreatorUid == null) return;

    // Hindari self-follow
    if (authUid == safeCreatorUid) {
      throw ArgumentError('User tidak bisa follow dirinya sendiri');
    }

    // Pakai UID dari auth sebagai sumber kebenaran path.
    // Parameter currentUid tidak dijadikan sumber untuk path Firestore.
    final followingDoc = _followingRef(currentUid: authUid).doc(safeCreatorUid);
    final followersDoc = _followersRef(creatorUid: safeCreatorUid).doc(authUid);

    final currentUserSnapshot = await firestore
        .collection('users')
        .doc(authUid)
        .get();
    final currentUserData = currentUserSnapshot.data() ?? <String, dynamic>{};

    final nama = currentUserData['nama'] as String? ?? '';
    final fotoProfil = currentUserData['foto_profil'] as String? ?? '';

    await firestore.runTransaction((tx) async {
      final followingSnap = await tx.get(followingDoc);
      if (followingSnap.exists) return;

      final followerData = _buildFollowerDoc(
        currentUid: authUid,
        nama: nama,
        fotoProfil: fotoProfil,
      );

      tx.set(followingDoc, followerData, SetOptions(merge: true));
      tx.set(followersDoc, followerData, SetOptions(merge: true));
    });

    await NotificationService.sendFollowNotification(
      targetUid: safeCreatorUid,
      senderUid: authUid,
      senderName: nama,
      senderPhoto: fotoProfil,
    );
  }

  Future<void> unfollowUser({
    required String currentUid,
    required String creatorUid,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final authUid = _sanitizeUid(currentUser?.uid);
    final safeCreatorUid = _sanitizeUid(creatorUid);

    if (authUid == null || safeCreatorUid == null) return;

    if (authUid == safeCreatorUid) {
      throw ArgumentError('User tidak bisa follow dirinya sendiri');
    }

    final followingDoc = _followingRef(currentUid: authUid).doc(safeCreatorUid);
    final followersDoc = _followersRef(creatorUid: safeCreatorUid).doc(authUid);

    await firestore.runTransaction((tx) async {
      tx.delete(followingDoc);
      tx.delete(followersDoc);
    });
  }

  Future<bool> isFollowing({
    required String currentUid,
    required String creatorUid,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final authUid = _sanitizeUid(currentUser?.uid);
    final safeCreatorUid = _sanitizeUid(creatorUid);

    if (authUid == null || safeCreatorUid == null) return false;

    final snap = await _followingRef(
      currentUid: authUid,
    ).doc(safeCreatorUid).get();
    return snap.exists;
  }

  Stream<int> getFollowersCountStream({required String creatorUid}) {
    final safeCreatorUid = _sanitizeUid(creatorUid);
    if (safeCreatorUid == null) return Stream.value(0);

    return _followersRef(
      creatorUid: safeCreatorUid,
    ).snapshots().map((snap) => snap.size);
  }

  Stream<int> getFollowingCountStream({required String currentUid}) {
    final safeCurrentUid = _sanitizeUid(currentUid);
    if (safeCurrentUid == null) return Stream.value(0);

    return _followingRef(
      currentUid: safeCurrentUid,
    ).snapshots().map((snap) => snap.size);
  }

  Future<Map<String, dynamic>> getCurrentFollowerData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = _sanitizeUid(currentUser?.uid);

    if (uid == null) {
      throw StateError('User belum login');
    }

    final userDoc = await firestore.collection('users').doc(uid).get();
    final data = userDoc.data() ?? <String, dynamic>{};

    return {
      'uid': uid,
      'nama': data['nama'] ?? '',
      'foto_profil': data['foto_profil'] ?? '',
      'created_at': data['created_at'] ?? DateTime.now(),
    };
  }
}
