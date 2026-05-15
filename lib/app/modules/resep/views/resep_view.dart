import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/resep_controller.dart';

class ResepView extends GetView<ResepController> {
  const ResepView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResepView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ResepView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
