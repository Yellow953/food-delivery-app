import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_controller.dart';
import '../../core/routes/app_routes.dart';

class ProfileTab extends GetView<MainController> {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final email = controller.userEmail ?? '';
    final displayName =
        email.isNotEmpty ? email.split('@').first : 'Guest';
    final nameCapitalized = displayName.length > 1
        ? displayName[0].toUpperCase() + displayName.substring(1)
        : displayName;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 36),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.secondary,
                      colorScheme.secondary.withOpacity(0.85),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: colorScheme.onSecondary.withOpacity(0.25),
                        child: Icon(
                          Icons.person_rounded,
                          size: 52,
                          color: colorScheme.onSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      nameCapitalized,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondary.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(top: 20, right: 16, child: _ProfileBubble(radius: 48, opacity: 0.2)),
              Positioned(top: 64, right: 40, child: _ProfileBubble(radius: 28, opacity: 0.18)),
              Positioned(top: 100, right: 8, child: _ProfileBubble(radius: 20, opacity: 0.15)),
              Positioned(bottom: -16, left: -20, child: _ProfileBubble(radius: 64, opacity: 0.18)),
              Positioned(bottom: 12, left: 48, child: _ProfileBubble(radius: 32, opacity: 0.15)),
              Positioned(bottom: 32, right: 64, child: _ProfileBubble(radius: 24, opacity: 0.2)),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'Account',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              elevation: 2,
              shadowColor: Colors.black12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    _ProfileTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit profile',
                      onTap: () => Get.toNamed<void>(AppRoutes.editProfile),
                    ),
                    Divider(height: 1, color: colorScheme.outline.withOpacity(0.5)),
                    _ProfileTile(
                      icon: Icons.location_on_outlined,
                      title: 'Addresses',
                      onTap: () => Get.toNamed<void>(AppRoutes.addresses),
                    ),
                    Divider(height: 1, color: colorScheme.outline.withOpacity(0.5)),
                    _ProfileTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () => Get.toNamed<void>(AppRoutes.notifications),
                    ),
                    Divider(height: 1, color: colorScheme.outline.withOpacity(0.5)),
                    _ProfileTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () => Get.toNamed<void>(AppRoutes.settings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => controller.signOut(),
                icon: const Icon(Icons.logout_rounded, size: 22),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(
                    color: colorScheme.error.withOpacity(0.6),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

class _ProfileBubble extends StatelessWidget {
  const _ProfileBubble({required this.radius, required this.opacity});

  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: colorScheme.secondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
