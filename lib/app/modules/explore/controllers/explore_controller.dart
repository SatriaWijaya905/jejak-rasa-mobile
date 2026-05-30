import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../data/models/resep_model.dart';
import '../../../data/models/user_model.dart';

class ExploreController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── State ──────────────────────────────────────────────
  final isLoadingTrending = true.obs;
  final isLoadingCreators = true.obs;
  final isLoadingTerbaru = true.obs;

  final trendingResep = <ResepModel>[].obs;
  final featuredCreators = <UserModel>[].obs;
  final terbaru = <ResepModel>[].obs;

  // Realtime followers count per creator uid
  final followersCount = <String, int>{}.obs;

  // Search
  final searchQuery = ''.obs;

  // Stream subscriptions
  StreamSubscription? _trendingSub;
  StreamSubscription? _terburuSub;

  // Listeners for followers sub-collections (one per creator)
  final _followersListeners = <String, StreamSubscription>{};

  // ── Lifecycle ──────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _listenTrending();
    _listenTerbaru();
    fetchFeaturedCreators();
  }

  @override
  void onClose() {
    _trendingSub?.cancel();
    _terburuSub?.cancel();
    for (final sub in _followersListeners.values) {
      sub.cancel();
    }
    super.onClose();
  }

  // ── Trending Resep (realtime stream) ───────────────────
  void _listenTrending() {
    isLoadingTrending.value = true;
    _trendingSub = _firestore
        .collection('resep')
        .where('status', isEqualTo: 'approved')
        .orderBy('jumlah_favorit', descending: true)
        .limit(10)
        .snapshots()
        .listen((snap) {
          trendingResep.value = snap.docs
              .map((d) => ResepModel.fromFirestore(d))
              .toList();
          isLoadingTrending.value = false;
        }, onError: (_) => isLoadingTrending.value = false);
  }

  // ── Terbaru Resep (realtime stream) ────────────────────
  void _listenTerbaru() {
    isLoadingTerbaru.value = true;
    _terburuSub = _firestore
        .collection('resep')
        .where('status', isEqualTo: 'approved')
        .orderBy('approved_at', descending: true)
        .limit(10)
        .snapshots()
        .listen((snap) {
          terbaru.value = snap.docs
              .map((d) => ResepModel.fromFirestore(d))
              .toList();
          isLoadingTerbaru.value = false;
        }, onError: (_) => isLoadingTerbaru.value = false);
  }

  // ── Featured Creators ──────────────────────────────────
  // Ambil top 10 users lalu sort by followers subcollection count realtime
  Future<void> fetchFeaturedCreators() async {
    isLoadingCreators.value = true;
    try {
      final snap = await _firestore.collection('users').limit(20).get();

      final users = snap.docs.map((d) => UserModel.fromJson(d.data())).toList();

      // Start realtime followers count for each creator
      for (final user in users) {
        final uid = user.uid ?? '';
        if (uid.isEmpty) continue;
        _listenFollowersCount(uid);
      }

      featuredCreators.value = users;
    } catch (_) {
      // fail silently, empty state will show
    } finally {
      isLoadingCreators.value = false;
    }
  }

  // Realtime followers count via subcollection
  void _listenFollowersCount(String uid) {
    if (_followersListeners.containsKey(uid)) return;
    final sub = _firestore
        .collection('users')
        .doc(uid)
        .collection('followers')
        .snapshots()
        .listen((snap) {
          followersCount[uid] = snap.size;
          followersCount.refresh();
        });
    _followersListeners[uid] = sub;
  }

  // ── Helpers ────────────────────────────────────────────
  int getFollowers(String uid) => followersCount[uid] ?? 0;

  /// Sorted creators by current realtime followers count
  List<UserModel> get sortedCreators {
    final list = List<UserModel>.from(featuredCreators);
    list.sort(
      (a, b) => getFollowers(b.uid ?? '').compareTo(getFollowers(a.uid ?? '')),
    );
    return list.take(10).toList();
  }

  // ── Navigation helpers ─────────────────────────────────
  void toDetailResep(ResepModel resep) {
    Get.toNamed('/detail-resep', arguments: resep);
  }

  void toCreatorProfile(UserModel user) {
    Get.toNamed('/creator-profile', arguments: {'creator': user});
  }

  void toKategoriProvinsi(String kategori) {
    Get.toNamed('/kategori-provinsi', arguments: kategori);
  }
}
