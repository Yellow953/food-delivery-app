import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/seller_orders_controller.dart';
import '../../models/order_model.dart';

class SellerOrderDetailView extends StatelessWidget {
  const SellerOrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as OrderModel?;
    if (order == null) {
      return const Scaffold(body: Center(child: Text('Order not found')));
    }
    final ctrl = Get.find<SellerOrdersController>();
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = order.createdAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt!)
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 6).toUpperCase()}'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.statusLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Customer',
            children: [
              if (order.customerName != null && order.customerName!.isNotEmpty)
                _InfoRow(label: 'Name', value: order.customerName!),
              _InfoRow(label: 'Address', value: order.deliveryAddress),
              _InfoRow(label: 'Payment', value: order.paymentMethod.toUpperCase()),
              if (dateStr.isNotEmpty) _InfoRow(label: 'Placed', value: dateStr),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Items',
            children: [
              if (order.items != null && order.items!.isNotEmpty)
                ...order.items!.map((item) => _ItemRow(item: item))
              else
                Text(
                  '${order.itemCount} item${order.itemCount != 1 ? 's' : ''}',
                  style: const TextStyle(color: Colors.black54),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Total',
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Action buttons based on status
          _SellerDetailActions(order: order, ctrl: ctrl),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SellerDetailActions extends StatelessWidget {
  const _SellerDetailActions({required this.order, required this.ctrl});
  final OrderModel order;
  final SellerOrdersController ctrl;

  @override
  Widget build(BuildContext context) {
    switch (order.status) {
      case 'pending':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ctrl.updateOrderStatus(order.id, 'accepted');
                  Get.back<void>();
                },
                child: const Text('Accept Order'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  ctrl.updateOrderStatus(order.id, 'rejected');
                  Get.back<void>();
                },
                child: const Text('Reject Order'),
              ),
            ),
          ],
        );
      case 'accepted':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ctrl.updateOrderStatus(order.id, 'preparing');
              Get.back<void>();
            },
            child: const Text('Start Preparing'),
          ),
        );
      case 'preparing':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ctrl.updateOrderStatus(order.id, 'ready_for_pickup');
              Get.back<void>();
            },
            child: const Text('Mark Ready for Pickup'),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(color: Colors.black45, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final title = item['dishTitle'] as String? ?? '';
    final size = item['sizeName'] as String? ?? '';
    final qty = item['quantity'] as int? ?? 1;
    final price = (item['price'] as num?)?.toDouble() ?? 0;
    final addons = (item['addons'] as List?)?.cast<String>() ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$title ($size)',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '×$qty  \$${(price * qty).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (addons.isNotEmpty)
            Text(
              addons.join(', '),
              style: const TextStyle(color: Colors.black45, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
