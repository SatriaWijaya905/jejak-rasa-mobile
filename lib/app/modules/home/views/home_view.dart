import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jejakrasa_mobile_database/app/modules/favorit/bindings/favorit_binding.dart';
import 'package:jejakrasa_mobile_database/app/modules/favorit/views/favorit_view.dart';
import 'package:jejakrasa_mobile_database/app/modules/home/views/homepage_view.dart';
import 'package:jejakrasa_mobile_database/app/modules/profil/bindings/profil_binding.dart';
import 'package:jejakrasa_mobile_database/app/modules/profil/views/profil_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    ProfilBinding().dependencies();
    FavoritBinding().dependencies();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => _buildBody(controller.currentIndex.value)),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFFF5A623),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const HomepageView();
      case 1:
        return _buildResep();
      case 2:
        return const FavoritView();
      case 3:
        return const ProfilView();
      default:
        return const HomepageView();
    }
  }

  Widget _buildResep() {
    return SafeArea(
      child: Center(
        child: Text(
          'Resep Page\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}