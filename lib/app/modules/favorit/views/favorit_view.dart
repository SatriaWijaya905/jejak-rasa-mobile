import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/favorit_controller.dart';

class FavoritView extends GetView<FavoritController> {
  const FavoritView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FavoritView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'FavoritView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
