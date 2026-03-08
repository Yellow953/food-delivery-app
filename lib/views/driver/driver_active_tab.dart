import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/driver_orders_controller.dart';
import '../../models/order_model.dart';

class DriverActiveTab extends StatelessWidget {
  const DriverActiveTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DriverOrdersController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Delivery'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Obx(() {
        if (ctrl.myActiveOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_bike_rounded, size: 64, color: Colors.black26),
                SizedBox(height: 12),
                Text('No active delivery', style: TextStyle(color: Colors.black45)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.myActiveOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final order = ctrl.myActiveOrders[i];
            return _ActiveDeliveryCard(order: order, ctrl: ctrl);
          },
        );
      }),
    );
  }
}

class _ActiveDeliveryCard extends StatelessWidget {
  const _ActiveDeliveryCard({required this.order, required this.ctrl});
  final OrderModel order;
  final DriverOrdersController ctrl;

  Future<void> _openMaps(String address) async {
    final query = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'On the way',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (order.restaurantName != null)
              _InfoTile(
                icon: Icons.store_rounded,
                label: 'From',
                value: order.restaurantName!,
              ),
            _InfoTile(
              icon: Icons.location_on_rounded,
              label: 'Deliver to',
              value: order.deliveryAddress,
            ),
            if (order.customerName != null && order.customerName!.isNotEmpty)
              _InfoTile(
                icon: Icons.person_rounded,
                label: 'Customer',
                value: order.customerName!,
              ),
            _InfoTile(
              icon: Icons.receipt_outlined,
              label: 'Total',
              value: '\$${order.total.toStringAsFixed(2)} (${order.paymentMethod.toUpperCase()})',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.map_rounded, size: 18),
                    label: const Text('Navigate'),
                    onPressed: () => _openMaps(order.deliveryAddress),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Delivered'),
                    onPressed: () => ctrl.markDelivered(order.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.black45),
          const SizedBox(width: 6),
          SizedBox(
            width: 68,
            child: Text(label, style: const TextStyle(color: Colors.black45, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
