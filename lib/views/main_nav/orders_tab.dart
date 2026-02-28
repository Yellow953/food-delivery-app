import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/orders_controller.dart';
import '../../models/order_model.dart';

class OrdersTab extends GetView<OrdersController> {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            child: Text(
              'Orders',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Obx(() {
          if (controller.isLoading.value) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.orders.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 80,
                      color:
                          colorScheme.onSurfaceVariant.withOpacity(0.4),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No orders yet',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'Your order history will appear here',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) {
                    // Pull-to-refresh hint
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _OrderCard(order: controller.orders[index]),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OrderCard(order: controller.orders[index]),
                  );
                },
                childCount: controller.orders.length,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final OrderModel order;

  Color _statusColor(ColorScheme cs) {
    switch (order.status) {
      case 'pending':
        return cs.secondary;
      case 'preparing':
        return Colors.orange;
      case 'on_the_way':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return cs.onSurfaceVariant;
    }
  }

  IconData _statusIcon() {
    switch (order.status) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'preparing':
        return Icons.restaurant_rounded;
      case 'on_the_way':
        return Icons.delivery_dining_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _statusColor(colorScheme);

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_statusIcon(), size: 20, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.statusLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      if (order.createdAt != null)
                        Text(
                          _formatDate(order.createdAt!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: colorScheme.outline.withOpacity(0.4),
            ),
            const SizedBox(height: 14),
            // Details
            _DetailRow(
              icon: Icons.shopping_bag_outlined,
              text: '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
            ),
            const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.location_on_outlined,
              text: order.deliveryAddress,
            ),
            const SizedBox(height: 6),
            _DetailRow(
              icon: order.paymentMethod == 'cash'
                  ? Icons.money_rounded
                  : Icons.credit_card_rounded,
              text: order.paymentMethod == 'cash'
                  ? 'Cash on delivery'
                  : 'Card',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:$m $ampm';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}
