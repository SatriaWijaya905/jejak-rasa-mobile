import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../data/models/resep_model.dart';

class ProvinsiRecipesController extends GetxController {
  final isLoading = true.obs;
  final recipes = <ResepModel>[].obs;
  final errorMessage = ''.obs;

  late final String provinsi;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  final hasLoadedOnce = false.obs;

  final usersCache = <String, Map<String, dynamic>>{}.obs;
  final Set<String> _fetchingUsers = {};

  @override
  void onInit() {
    super.onInit();
    provinsi = Get.arguments?['provinsi'] ?? '';
    _listenRecipes();
  }

  void _listenRecipes() {
    _subscription?.cancel();

    isLoading.value = true;
    errorMessage.value = '';

    final query = FirebaseFirestore.instance
        .collection('resep')
        .where('provinsi', isEqualTo: provinsi)
        .where('status', isEqualTo: 'approved');

    _subscription = query.snapshots().listen(
      (snapshot) {
        final list = snapshot.docs
            .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
            .toList();

        // Local sort (newest first)
        list.sort((a, b) {
          final aTs = a.approvedAt ?? a.createdAt ?? DateTime(2000);
          final bTs = b.approvedAt ?? b.createdAt ?? DateTime(2000);
          return bTs.compareTo(aTs);
        });

        recipes.value = list;
        hasLoadedOnce.value = true;
        isLoading.value = false;
      },
      onError: (e) {
        errorMessage.value = e.toString();
        isLoading.value = false;
        hasLoadedOnce.value = true;
      },
    );
  }

  void _fetchUserIfNeeded(String? uid) {
    if (uid == null || uid.isEmpty) return;
    if (usersCache.containsKey(uid) || _fetchingUsers.contains(uid)) return;

    _fetchingUsers.add(uid);
    FirebaseFirestore.instance.collection('users').doc(uid).get().then((doc) {
      if (doc.exists && doc.data() != null) {
        usersCache[uid] = doc.data()!;
      }
    });
  }

  String? getCreatorName(String? uid) {
    if (uid == null || uid.isEmpty) return null;
    _fetchUserIfNeeded(uid);
    return usersCache[uid]?['nama'] as String?;
  }

  String? getCreatorPhoto(String? uid) {
    if (uid == null || uid.isEmpty) return null;
    _fetchUserIfNeeded(uid);
    return usersCache[uid]?['foto_profil'] as String?;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
