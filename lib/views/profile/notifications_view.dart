import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _SectionHeader('Orders'),
          const SizedBox(height: 10),
          _NotifCard(
            children: [
              Obx(
                () => _NotifTile(
                  icon: Icons.receipt_long_rounded,
                  title: 'Order updates',
                  subtitle: 'Confirmation, status changes and receipts',
                  value: controller.orderUpdates.value,
                  onChanged: (v) => controller.orderUpdates.value = v,
                ),
              ),
              _Divider(),
              Obx(
                () => _NotifTile(
                  icon: Icons.delivery_dining_rounded,
                  title: 'Delivery status',
                  subtitle: 'When your rider picks up and arrives',
                  value: controller.deliveryStatus.value,
                  onChanged: (v) => controller.deliveryStatus.value = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader('Promotions'),
          const SizedBox(height: 10),
          _NotifCard(
            children: [
              Obx(
                () => _NotifTile(
                  icon: Icons.local_offer_rounded,
                  title: 'Deals & offers',
                  subtitle: 'Coupons, discounts and special deals',
                  value: controller.dealsAndOffers.value,
                  onChanged: (v) => controller.dealsAndOffers.value = v,
                ),
              ),
              _Divider(),
              Obx(
                () => _NotifTile(
                  icon: Icons.store_rounded,
                  title: 'New restaurants',
                  subtitle: 'When new places open in your area',
                  value: controller.newRestaurants.value,
                  onChanged: (v) => controller.newRestaurants.value = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader('General'),
          const SizedBox(height: 10),
          _NotifCard(
            children: [
              Obx(
                () => _NotifTile(
                  icon: Icons.email_outlined,
                  title: 'Email notifications',
                  subtitle: 'Summaries and account notices by email',
                  value: controller.emailNotifications.value,
                  onChanged: (v) => controller.emailNotifications.value = v,
                ),
              ),
              _Divider(),
              Obx(
                () => _NotifTile(
                  icon: Icons.volume_up_rounded,
                  title: 'In-app sounds',
                  subtitle: 'Sound effects for app interactions',
                  value: controller.inAppSounds.value,
                  onChanged: (v) => controller.inAppSounds.value = v,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colorScheme.secondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}
