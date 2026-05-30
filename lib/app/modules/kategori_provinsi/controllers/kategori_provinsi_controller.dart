import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class KategoriProvinsiController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  
  // Region/kategori name passed via arguments
  late String regionName;

  var isLoading = true.obs;
  var provinces = <String>[].obs;
  var searchQuery = ''.obs;
  
  // This will store the original unique provinces for search filtering
  List<String> _allProvinces = [];

  @override
  void onInit() {
    super.onInit();
    regionName = Get.arguments ?? '';
    fetchProvinces();
  }

  void fetchProvinces() async {
    try {
      isLoading(true);
      
      // Query to get recipes in this specific region/kategori_provinsi
      final querySnapshot = await _firestore
          .collection('resep')
          .where('kategori_provinsi', isEqualTo: regionName)
          .where('status', isEqualTo: 'approved') // Only count approved recipes
          .get();

      // Extract unique province names
      final Set<String> uniqueProvinces = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('provinsi')) {
          final prov = data['provinsi'] as String?;
          if (prov != null && prov.trim().isNotEmpty) {
            uniqueProvinces.add(prov.trim());
          }
        }
      }

      _allProvinces = uniqueProvinces.toList()..sort();
      provinces.assignAll(_allProvinces);
    } catch (e) {
      print('Error fetching provinces: $e');
    } finally {
      isLoading(false);
    }
  }

  void searchProvinces(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      provinces.assignAll(_allProvinces);
    } else {
      provinces.assignAll(_allProvinces
          .where((prov) => prov.toLowerCase().contains(query.toLowerCase()))
          .toList());
    }
  }
}