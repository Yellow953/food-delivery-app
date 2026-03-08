import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/driver_orders_controller.dart';
import '../../models/order_model.dart';

class DriverAvailableTab extends StatelessWidget {
  const DriverAvailableTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DriverOrdersController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Pickups'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.availableOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_shipping_rounded, size: 64, color: Colors.black26),
                SizedBox(height: 12),
                Text('No pickups available', style: TextStyle(color: Colors.black45)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.availableOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final order = ctrl.availableOrders[i];
            return _AvailableOrderCard(order: order, ctrl: ctrl);
          },
        );
      }),
    );
  }
}

class _AvailableOrderCard extends StatelessWidget {
  const _AvailableOrderCard({required this.order, required this.ctrl});
  final OrderModel order;
  final DriverOrdersController ctrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = order.createdAt != null
        ? DateFormat('dd MMM, HH:mm').format(order.createdAt!)
        : '';

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantName ?? 'Restaurant',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (dateStr.isNotEmpty)
                        Text(dateStr,
                            style: const TextStyle(color: Colors.black38, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Ready',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 16, color: Colors.black45),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.deliveryAddress,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.receipt_outlined, size: 16, color: Colors.black45),
                const SizedBox(width: 4),
                Text(
                  '${order.itemCount} item${order.itemCount != 1 ? 's' : ''} · \$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions_bike_rounded, size: 18),
                label: const Text('Pick Up Order'),
                onPressed: () => ctrl.pickUpOrder(order.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
