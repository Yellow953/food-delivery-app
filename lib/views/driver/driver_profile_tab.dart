import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../services/auth_service.dart';

class DriverProfileTab extends StatelessWidget {
  const DriverProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.delivery_dining_rounded, size: 40),
          ),
          const SizedBox(height: 16),
          Obx(() => Center(
            child: Text(
              auth.currentUser.value?.displayName ?? auth.currentUser.value?.email ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )),
          const SizedBox(height: 8),
          const Center(
            child: Chip(label: Text('Driver')),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign out'),
            onTap: () async {
              await auth.signOut();
              Get.offAllNamed<void>(AppRoutes.auth);
            },
          ),
        ],
      ),
    );
  }
}
