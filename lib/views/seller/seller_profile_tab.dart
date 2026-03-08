import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class SellerProfileTab extends StatelessWidget {
  const SellerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final userService = Get.find<UserService>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + name
            Obx(() {
              final user = auth.currentUser.value;
              final name = user?.displayName ?? '';
              final email = user?.email ?? '';
              return Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  Text(email,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Seller · ${userService.restaurantName ?? ''}',
                      style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 28),

            // Personal section
            _SectionLabel('Personal'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              label: 'Edit profile',
              onTap: () => Get.toNamed<void>(AppRoutes.editProfile),
            ),

            const SizedBox(height: 16),

            // Business section
            _SectionLabel('Business'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.storefront_rounded,
              label: 'Business info',
              onTap: () => Get.toNamed<void>(AppRoutes.sellerEditBusiness),
            ),

            const SizedBox(height: 16),

            // Account section
            _SectionLabel('Account'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              isDestructive: true,
              onTap: () async {
                await auth.signOut();
                Get.offAllNamed<void>(AppRoutes.auth);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.onSurface;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: color)),
              ),
              if (!isDestructive)
                Icon(Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
