import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/seller_orders_controller.dart';
import '../../models/order_model.dart';

class SellerHistoryTab extends StatelessWidget {
  const SellerHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SellerOrdersController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Obx(() {
        if (ctrl.historyOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_rounded, size: 64, color: Colors.black26),
                SizedBox(height: 12),
                Text('No history yet', style: TextStyle(color: Colors.black45)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.historyOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final order = ctrl.historyOrders[i];
            return _HistoryCard(order: order);
          },
        );
      }),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDelivered = order.status == 'delivered';
    final dateStr = order.createdAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt!)
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
                  child: Text(
                    'Order #${order.id.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDelivered ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      color: isDelivered ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (order.customerName != null && order.customerName!.isNotEmpty)
              Text(order.customerName!, style: const TextStyle(color: Colors.black54)),
            Row(
              children: [
                Text(
                  '${order.itemCount} item${order.itemCount != 1 ? 's' : ''} · \$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(dateStr, style: const TextStyle(color: Colors.black38, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
