import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/resep_model.dart';
import 'package:jejakrasa_mobile_database/app/data/models/user_model.dart';
import 'package:jejakrasa_mobile_database/app/data/services/resep_service.dart';

class HomeController extends GetxController {
  final ResepService _resepService = ResepService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =============================================
  // UI TAB / STATE
  // =============================================
  var currentIndex = 0.obs;
  var isLoading = false.obs;
  var feedTabIndex = 0.obs;

  // =============================================
  // FEED — Personalized / Following
  // =============================================
  var resepPopuler = <ResepModel>[].obs;
  var resepTerbaru = <ResepModel>[].obs;
  var resepFeatured = <ResepModel>[].obs; // most favorite
  var resepSaya = <ResepModel>[].obs;

  var followingRecipes = <ResepModel>[].obs;
  var latestRecipes = <ResepModel>[].obs;
  var recommendedRecipes = <ResepModel>[].obs;
  var isLoadingFeed = false.obs;

  var followingIds = <String>[].obs;
  var creatorProfiles = <String, Map<String, dynamic>>{}.obs;

  // Stream subscriptions for cleanup
  StreamSubscription? _followingListSub;
  StreamSubscription? _followingFeedSub;
  StreamSubscription? _latestFeedSub;
  StreamSubscription? _recommendedFeedSub;
  StreamSubscription? _resepSayaSub;
  StreamSubscription? _terbaruStreamSub;

  // =============================================
  // Search state
  // =============================================
  var searchQuery = ''.obs;

  /// Full realtime dataset for resep.
  /// Listener resep hanya mengisi cache ini.
  /// UI search wajib hanya menurunkan derived list dari cache.
  var allResep = <ResepModel>[].obs;

  /// Full realtime dataset for users/creator.
  /// Listener user hanya mengisi cache ini.
  var allUsers = <UserModel>[].obs;

  /// Results resep yang ditampilkan UI.
  var searchResults = <ResepModel>[].obs;

  /// Results user yang ditampilkan UI.
  var searchUsers = <UserModel>[].obs;

  /// Cache jumlah resep realtime untuk tiap creatorUid.
  /// Dipakai agar badge jumlah resep di card search user sinkron seperti CreatorProfile.
  var resepCountByCreator = <String, int>{}.obs;

  Timer? _searchDebounce;
  StreamSubscription? _allResepSub;
  StreamSubscription? _allUsersSub;

  /// Keep the last query so derived lists always represent last typing.
  String _lastQuery = '';

  // =============================================
  // Banner auto-scroll
  // =============================================
  var bannerIndex = 0.obs;
  Timer? _bannerTimer;
  PageController? bannerPageController;

  @override
  void onInit() {
    super.onInit();

    fetchData();

    // Avoid creating feed listeners when not logged in.
    if (_auth.currentUser?.uid != null) {
      fetchResepSaya();
      _initFeedStreams();
    }

    // Single realtime listeners for search caches.
    _listenAllResepCache();
    _listenAllUsersCache();

    // Ensure derived search lists are computed initially
    // (e.g. if searchQuery restored by UI).
    _applySearchFromCache();
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();

    _followingListSub?.cancel();
    _followingFeedSub?.cancel();
    _latestFeedSub?.cancel();
    _recommendedFeedSub?.cancel();
    _resepSayaSub?.cancel();
    _terbaruStreamSub?.cancel();

    _allResepSub?.cancel();
    _allUsersSub?.cancel();

    _searchDebounce?.cancel();
    super.onClose();
  }

  // =============================================
  // FEED — Initialization
  // =============================================
  void _initFeedStreams() {
    _listenFollowingChanges();
    fetchLatestFeed();
    fetchRecommendedFeed();
  }

  // Listen following list changes (realtime)
  void _listenFollowingChanges() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _followingListSub?.cancel();
    _followingListSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('following')
        .snapshots()
        .listen((snapshot) {
          followingIds.value = snapshot.docs.map((doc) => doc.id).toList();
          fetchFollowingFeed();
        });
  }

  /// Fetch recipes from followed creators.
  /// (Existing behavior retained)
  void fetchFollowingFeed() {
    _followingFeedSub?.cancel();

    if (followingIds.isEmpty) {
      followingRecipes.clear();
      isLoadingFeed.value = false;
      return;
    }

    final safeFollowingIds = followingIds
        .where((id) => id.trim().isNotEmpty)
        .toList();

    if (safeFollowingIds.isEmpty) {
      followingRecipes.clear();
      isLoadingFeed.value = false;
      return;
    }

    isLoadingFeed.value = true;

    final chunks = <List<String>>[];
    for (var i = 0; i < safeFollowingIds.length; i += 30) {
      chunks.add(
        safeFollowingIds.sublist(
          i,
          i + 30 > safeFollowingIds.length ? safeFollowingIds.length : i + 30,
        ),
      );
    }

    if (chunks.length == 1) {
      _followingFeedSub = _firestore
          .collection('resep')
          .where('author_uid', whereIn: chunks[0])
          .where('status', isEqualTo: 'approved')
          .orderBy('approved_at', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              final list = snapshot.docs
                  .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
                  .toList();

              list.sort(
                (a, b) => (b.approvedAt ?? b.createdAt ?? DateTime(2000))
                    .compareTo(a.approvedAt ?? a.createdAt ?? DateTime(2000)),
              );

              followingRecipes.value = list;
              _fetchCreatorProfilesForRecipes(followingRecipes);
              isLoadingFeed.value = false;
            },
            onError: (_) {
              _followingFeedSub?.cancel();
              _followingFeedSub = _firestore
                  .collection('resep')
                  .where('author_uid', whereIn: chunks[0])
                  .where('status', isEqualTo: 'approved')
                  .snapshots()
                  .listen((snapshot) {
                    final list = snapshot.docs
                        .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
                        .toList();

                    list.sort(
                      (a, b) => (b.approvedAt ?? b.createdAt ?? DateTime(2000))
                          .compareTo(
                            a.approvedAt ?? a.createdAt ?? DateTime(2000),
                          ),
                    );

                    followingRecipes.value = list;
                    _fetchCreatorProfilesForRecipes(followingRecipes);
                    isLoadingFeed.value = false;
                  });
            },
          );
    } else {
      _fetchMultiChunkFollowing(chunks);
    }
  }

  Future<void> _fetchMultiChunkFollowing(List<List<String>> chunks) async {
    try {
      List<ResepModel> allRecipes = [];
      for (final chunk in chunks) {
        final snapshot = await _firestore
            .collection('resep')
            .where('author_uid', whereIn: chunk)
            .where('status', isEqualTo: 'approved')
            .get();

        allRecipes.addAll(
          snapshot.docs
              .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
      }

      allRecipes.sort(
        (a, b) => (b.approvedAt ?? b.createdAt ?? DateTime(2000)).compareTo(
          a.approvedAt ?? a.createdAt ?? DateTime(2000),
        ),
      );

      followingRecipes.value = allRecipes;
      _fetchCreatorProfilesForRecipes(followingRecipes);
    } catch (_) {
      // silent fail
    } finally {
      isLoadingFeed.value = false;
    }
  }

  // Latest feed (realtime)
  void fetchLatestFeed() {
    _latestFeedSub?.cancel();

    _latestFeedSub = _firestore
        .collection('resep')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .listen((snapshot) {
          latestRecipes.value = snapshot.docs
              .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
              .toList();

          latestRecipes.sort(
            (a, b) => (b.approvedAt ?? b.createdAt ?? DateTime(2000)).compareTo(
              a.approvedAt ?? a.createdAt ?? DateTime(2000),
            ),
          );

          _fetchCreatorProfilesForRecipes(latestRecipes);
        });
  }

  // Recommended feed (realtime)
  void fetchRecommendedFeed() {
    _recommendedFeedSub?.cancel();

    _recommendedFeedSub = _firestore
        .collection('resep')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .listen((snapshot) {
          recommendedRecipes.value = snapshot.docs
              .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
              .toList();

          _fetchCreatorProfilesForRecipes(recommendedRecipes);
        });
  }

  // Creator profile cache for feed
  Future<void> _fetchCreatorProfilesForRecipes(List<ResepModel> recipes) async {
    final uids = recipes
        .map((r) => r.authorUid)
        .where((uid) => uid != null && uid.isNotEmpty)
        .toSet();

    for (final uid in uids) {
      if (uid == null) continue;
      if (creatorProfiles.containsKey(uid)) continue;

      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          creatorProfiles[uid] = {
            'nama': doc.data()?['nama'] ?? 'Creator',
            'foto_profil': doc.data()?['foto_profil'] ?? '',
          };
        } else {
          creatorProfiles[uid] = {'nama': 'Creator', 'foto_profil': ''};
        }
      } catch (_) {
        creatorProfiles[uid] = {'nama': 'Creator', 'foto_profil': ''};
      }
    }

    creatorProfiles.refresh();
  }

  String getCreatorName(String? uid) {
    if (uid == null) return 'Creator';
    return (creatorProfiles[uid]?['nama'] as String?) ?? 'Creator';
  }

  String getCreatorPhoto(String? uid) {
    if (uid == null) return '';
    return (creatorProfiles[uid]?['foto_profil'] as String?) ?? '';
  }

  // =============================================
  // Banner
  // =============================================
  void bindBannerPageController(PageController controller) {
    bannerPageController = controller;
    if (bannerPageController!.hasClients) {
      bannerPageController!.jumpToPage(bannerIndex.value);
    }
  }

  void startBannerTimer(int count) {
    _bannerTimer?.cancel();
    if (count <= 1) return;

    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final total = count;
      final nextIndex = (bannerIndex.value + 1) % total;
      bannerIndex.value = nextIndex;

      if (bannerPageController == null) return;
      if (!bannerPageController!.hasClients) return;

      await bannerPageController!.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  Future<void> hapusResep(String id) async {
    try {
      await _firestore.collection('resep').doc(id).delete();
      fetchData();
      fetchResepSaya();
      Get.snackbar('Berhasil', 'Resep berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // =============================================
  // Data: Popular/Featured/ResepTerbaru
  // =============================================
  Future<void> fetchData() async {
    isLoading.value = true;

    resepPopuler.value = await _resepService.getResepPopuler();

    _terbaruStreamSub?.cancel();
    _terbaruStreamSub = _resepService
        .streamResepTerbaru(limit: 5)
        .listen(
          (list) {
            resepTerbaru.assignAll(list);
          },
          onError: (e) {
            resepTerbaru.clear();
          },
        );

    try {
      final snapshot = await _firestore
          .collection('resep')
          .where('status', isEqualTo: 'approved')
          .get();

      if (snapshot.docs.isNotEmpty) {
        resepFeatured.value = snapshot.docs
            .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
            .toList();
      } else {
        resepFeatured.value = await _resepService.getResepFeatured();
      }
    } catch (_) {
      resepFeatured.value = await _resepService.getResepFeatured();
    }

    startBannerTimer(resepFeatured.take(3).length);
    isLoading.value = false;
  }

  void fetchResepSaya() {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        resepSaya.clear();
        return;
      }

      _resepSayaSub?.cancel();

      _resepSayaSub = _firestore
          .collection('resep')
          .where('author_uid', isEqualTo: uid)
          .snapshots()
          .listen((snapshot) {
            resepSaya.value = snapshot.docs
                .map(
                  (doc) => ResepModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ),
                )
                .toList();
          });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat kreasi: ${e.toString()}');
    }
  }

  // =============================================
  // Search: cache listeners
  // =============================================
  void _listenAllResepCache() {
    _allResepSub?.cancel();

    _allResepSub = _firestore
        .collection('resep')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .listen(
          (snapshot) {
            final list = snapshot.docs
                .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
                .toList();

            allResep.assignAll(list);

            // Re-derive results from cache (anti flicker)
            _applySearchFromCache();
          },
          onError: (_) {
            // do not clear aggressively; keep last derived results
          },
        );
  }

  void _listenAllUsersCache() {
    _allUsersSub?.cancel();

    _allUsersSub = _firestore
        .collection('users')
        .snapshots()
        .listen(
          (snapshot) {
            final list = snapshot.docs
                .map(
                  (doc) =>
                      UserModel.fromJson(doc.data() as Map<String, dynamic>),
                )
                .toList();

            // Ensure uid exists (some models might not store it in doc field)
            for (final u in list) {
              u.uid ??= '';
            }

            allUsers.assignAll(list);

            // Re-derive results from cache (anti flicker)
            _applySearchFromCache();
          },
          onError: (_) {
            // do not clear aggressively
          },
        );
  }

  // =============================================
  // Search: input handler (typing)
  // =============================================
  void searchResep(String query) {
    final q = query.trim();
    searchQuery.value = q;
    _lastQuery = q;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _applySearchFromCache();
    });
  }

  String _normalize(String? v) => (v ?? '').toLowerCase().trim();

  /// Derived results from local caches.
  /// Tidak membuat Firestore query baru saat typing.
  void _warmupResepCountForCreators(Set<String> creatorUids) async {
    if (creatorUids.isEmpty) return;

    // Minimalistik: hitung jumlah resep approved per creator
    // sekali per refresh derived results (cache). Tidak dipanggil per-keystroke
    // karena searchResep sudah debounce.
    final Map<String, int> counts = {};

    for (final uid in creatorUids) {
      if (uid.isEmpty) continue;
      try {
        final snap = await _firestore
            .collection('resep')
            .where('author_uid', isEqualTo: uid)
            .where('status', isEqualTo: 'approved')
            .get();
        counts[uid] = snap.docs.length;
      } catch (_) {
        counts[uid] = 0;
      }
    }

    // Merge into observable cache
    resepCountByCreator.assignAll(counts);
  }

  void _applySearchFromCache() {
    final q = _lastQuery.trim();

    if (q.isEmpty) {
      // keep empty results, but don't clear caches.
      searchResults.clear();
      searchUsers.clear();
      return;
    }

    final lowerQ = q.toLowerCase();

    // Filter resep from allResep
    final resepResults = <ResepModel>[];
    for (final resep in allResep) {
      final nama = _normalize(resep.namaResep);
      final kategori = _normalize(resep.kategoriProvinsi);
      final provinsi = _normalize(resep.provinsi);

      final match =
          nama.contains(lowerQ) ||
          kategori.contains(lowerQ) ||
          provinsi.contains(lowerQ);

      if (match) resepResults.add(resep);
    }

    // Filter users from allUsers
    final userResults = <UserModel>[];
    for (final user in allUsers) {
      final nama = _normalize(user.nama);
      final bio = _normalize(user.bio);

      // fallback search
      final emailLocal = _normalize(user.email?.split('@').first);
      final usernameOrEmail = emailLocal.isNotEmpty ? emailLocal : '';

      final match =
          nama.contains(lowerQ) ||
          bio.contains(lowerQ) ||
          (usernameOrEmail.isNotEmpty && usernameOrEmail.contains(lowerQ));

      if (match) userResults.add(user);
    }

    // Assign derived lists
    searchResults.assignAll(resepResults);

    // Refresh resep count cache for users shown in UI.
    // Agar badge jumlahResep di search user sinkron seperti CreatorProfile,
    // kita hitung jumlah resep approved per creatorUid.
    // (Ini hanya mengisi cache angka, tidak mengubah listener realtime typing.)
    _warmupResepCountForCreators(
      userResults.map((u) => u.uid ?? '').where((id) => id.isNotEmpty).toSet(),
    );

    searchUsers.assignAll(userResults);
  }
}
