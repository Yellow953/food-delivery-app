import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/seller_orders_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../models/order_model.dart';

class SellerOrdersTab extends StatelessWidget {
  const SellerOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SellerOrdersController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Orders'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.activeOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_rounded, size: 64, color: Colors.black26),
                SizedBox(height: 12),
                Text('No active orders', style: TextStyle(color: Colors.black45)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.activeOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final order = ctrl.activeOrders[i];
            return _SellerOrderCard(order: order, ctrl: ctrl);
          },
        );
      }),
    );
  }
}

class _SellerOrderCard extends StatelessWidget {
  const _SellerOrderCard({required this.order, required this.ctrl});
  final OrderModel order;
  final SellerOrdersController ctrl;

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready_for_pickup':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.toNamed<void>(AppRoutes.sellerOrderDetail, arguments: order),
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
                      color: _statusColor(order.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: TextStyle(
                        color: _statusColor(order.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (order.customerName != null && order.customerName!.isNotEmpty)
                Text(order.customerName!, style: const TextStyle(color: Colors.black54)),
              Text(
                order.deliveryAddress,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 12),
              _ActionButtons(order: order, ctrl: ctrl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.order, required this.ctrl});
  final OrderModel order;
  final SellerOrdersController ctrl;

  @override
  Widget build(BuildContext context) {
    switch (order.status) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => ctrl.updateOrderStatus(order.id, 'rejected'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => ctrl.updateOrderStatus(order.id, 'accepted'),
                child: const Text('Accept'),
              ),
            ),
          ],
        );
      case 'accepted':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => ctrl.updateOrderStatus(order.id, 'preparing'),
            child: const Text('Start Preparing'),
          ),
        );
      case 'preparing':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => ctrl.updateOrderStatus(order.id, 'ready_for_pickup'),
            child: const Text('Mark Ready for Pickup'),
          ),
        );
      case 'ready_for_pickup':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Waiting for driver...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
