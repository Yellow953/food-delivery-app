import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_controller.dart';
import 'home_tab.dart';
import 'search_tab.dart';
import 'restaurants_tab.dart';
import 'orders_tab.dart';
import 'profile_tab.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (controller.currentIndex.value) {
          case 0:
            return const HomeTab();
          case 1:
            return const SearchTab();
          case 2:
            return const RestaurantsTab();
          case 3:
            return const OrdersTab();
          case 4:
            return const ProfileTab();
          default:
            return const HomeTab();
        }
      }),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavIcon(
                    icon: Icons.home_rounded,
                    selected: controller.currentIndex.value == 0,
                    onTap: () => controller.setIndex(0),
                  ),
                  _NavIcon(
                    icon: Icons.search_rounded,
                    selected: controller.currentIndex.value == 1,
                    onTap: () => controller.setIndex(1),
                  ),
                  _NavIcon(
                    icon: Icons.restaurant_rounded,
                    selected: controller.currentIndex.value == 2,
                    onTap: () => controller.setIndex(2),
                  ),
                  _NavIcon(
                    icon: Icons.receipt_long_rounded,
                    selected: controller.currentIndex.value == 3,
                    onTap: () => controller.setIndex(3),
                  ),
                  _NavIcon(
                    icon: Icons.person_rounded,
                    selected: controller.currentIndex.value == 4,
                    onTap: () => controller.setIndex(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Icon(
            icon,
            size: 26,
            color: selected
                ? colorScheme.secondary
                : colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
