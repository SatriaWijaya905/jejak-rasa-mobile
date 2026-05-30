import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../data/models/resep_model.dart';

class PopularRecipesController extends GetxController {
  final isLoading = true.obs;
  final recipes = <ResepModel>[].obs;
  final errorMessage = ''.obs;

  final _pageSize = 50;

  late final Query<Map<String, dynamic>> _baseQuery;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  /// untuk menghindari empty state tampil sebelum snapshot pertama masuk
  final hasLoadedOnce = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('[PopularRecipesController] created');

    _baseQuery = FirebaseFirestore.instance
        .collection('resep')
        .where('status', isEqualTo: 'approved')
        .where('is_popular', isEqualTo: true)
        .orderBy('jumlah_favorit', descending: true)
        .limit(_pageSize);

    _listenRecipes();
  }

  void _listenRecipes() {
    _subscription?.cancel();

    // Jangan reset list di sini agar tidak ada flicker saat controller recreate
    isLoading.value = true;
    errorMessage.value = '';

    _subscription = _baseQuery.snapshots().listen(
      (snapshot) {
        final list = snapshot.docs
            .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
            .toList();

        // fallback sorting aman jika jumlah_favorit null/inkonsisten
        list.sort((a, b) {
          final aCount = a.jumlahFavorit ?? 0;
          final bCount = b.jumlahFavorit ?? 0;
          return bCount.compareTo(aCount);
        });

        recipes.value = list;
        hasLoadedOnce.value = true;
        isLoading.value = false;

        print(
          '[PopularRecipesController] snapshot docs=${snapshot.docs.length} recipes=${recipes.length}',
        );
      },
      onError: (e) {
        errorMessage.value = e.toString();
        isLoading.value = false;
        hasLoadedOnce.value = true;
        // jangan clear agresif; biar tidak hilang saat reconnect/error transient
        print('[PopularRecipesController] stream error: $e');
      },
    );

    print('[PopularRecipesController] listener attached');
  }

  @override
  void onClose() {
    print('[PopularRecipesController] disposed');
    _subscription?.cancel();
    super.onClose();
  }
}
