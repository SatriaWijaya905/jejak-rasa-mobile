import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../data/models/resep_model.dart';

class NewestRecipesController extends GetxController {
  final isLoading = true.obs;
  final recipes = <ResepModel>[].obs;
  final errorMessage = ''.obs;

  final _pageSize = 50;

  late final Query<Map<String, dynamic>> _baseQuery;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  final hasLoadedOnce = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('[NewestRecipesController] created');

    _baseQuery = FirebaseFirestore.instance
        .collection('resep')
        .where('status', isEqualTo: 'approved')
        .orderBy('created_at', descending: true)
        .limit(_pageSize);

    _listenRecipes();
  }

  void _listenRecipes() {
    _subscription?.cancel();

    isLoading.value = true;
    errorMessage.value = '';

    _subscription = _baseQuery.snapshots().listen(
      (snapshot) {
        final list = snapshot.docs
            .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
            .toList();

        // fallback sorting aman jika approved_at null / inkonsisten
        list.sort((a, b) {
          final aTs = a.approvedAt ?? a.createdAt ?? DateTime(2000);
          final bTs = b.approvedAt ?? b.createdAt ?? DateTime(2000);
          return bTs.compareTo(aTs);
        });

        recipes.value = list;
        hasLoadedOnce.value = true;
        isLoading.value = false;

        print(
          '[NewestRecipesController] snapshot docs=${snapshot.docs.length} recipes=${recipes.length}',
        );
      },
      onError: (e) {
        errorMessage.value = e.toString();
        isLoading.value = false;
        hasLoadedOnce.value = true;
        print('[NewestRecipesController] stream error: $e');
      },
    );

    print('[NewestRecipesController] listener attached');
  }

  @override
  void onClose() {
    print('[NewestRecipesController] disposed');
    _subscription?.cancel();
    super.onClose();
  }
}
