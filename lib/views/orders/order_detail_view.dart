import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/order_model.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as OrderModel?;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Detail')),
        body: const Center(child: Text('Order not found')),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            title: const Text('Order Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Get.back<void>(),
            ),
          ),

          // ── Status card ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _StatusCard(order: order),
            ),
          ),

          // ── Order info ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _InfoCard(order: order),
            ),
          ),

          // ── Items ────────────────────────────────────────────────────────
          if (order.items != null && order.items!.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _OrderItemTile(item: order.items![i]),
                  ),
                  childCount: order.items!.length,
                ),
              ),
            ),
          ],

          // ── Price summary ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: _PriceSummary(order: order),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});
  final OrderModel order;

  Color _statusColor(ColorScheme cs) {
    switch (order.status) {
      case 'pending':
        return cs.secondary;
      case 'accepted':
      case 'preparing':
        return Colors.orange;
      case 'ready_for_pickup':
      case 'on_the_way':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'rejected':
        return cs.error;
      default:
        return cs.onSurfaceVariant;
    }
  }

  IconData _statusIcon() {
    switch (order.status) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'accepted':
        return Icons.thumb_up_rounded;
      case 'preparing':
        return Icons.restaurant_rounded;
      case 'ready_for_pickup':
        return Icons.storefront_rounded;
      case 'on_the_way':
        return Icons.delivery_dining_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
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
      elevation: 1,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_statusIcon(), size: 28, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.statusLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  if (order.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order.createdAt!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Order #${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${order.total.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            if (order.restaurantName != null &&
                order.restaurantName!.isNotEmpty) ...[
              _Row(
                icon: Icons.storefront_rounded,
                label: 'Restaurant',
                value: order.restaurantName!,
              ),
              const SizedBox(height: 10),
            ],
            _Row(
              icon: Icons.location_on_outlined,
              label: 'Delivery to',
              value: order.deliveryAddress,
            ),
            const SizedBox(height: 10),
            _Row(
              icon: order.paymentMethod == 'cash'
                  ? Icons.money_rounded
                  : Icons.credit_card_rounded,
              label: 'Payment',
              value: order.paymentMethod == 'cash'
                  ? 'Cash on delivery'
                  : 'Card',
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final title = item['dishTitle'] as String? ?? item['title'] as String? ?? '';
    final imageUrl = item['dishImageUrl'] as String? ?? item['imageUrl'] as String? ?? '';
    final variantSummary = item['sizeName'] as String? ?? '';
    final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
    final price = (item['price'] as num?)?.toDouble() ?? 0.0;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.restaurant_rounded,
                              size: 24,
                              color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.restaurant_rounded,
                            size: 24, color: colorScheme.onSurfaceVariant),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (variantSummary.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      variantSummary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'x$quantity',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = order.items ?? [];
    final subtotal = items.fold<double>(
      0,
      (s, i) =>
          s +
          ((i['price'] as num?)?.toDouble() ?? 0) *
              ((i['quantity'] as num?)?.toInt() ?? 1),
    );
    final deliveryFee = order.total - subtotal;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Summary',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _PriceRow(label: 'Subtotal', amount: subtotal),
            if (deliveryFee > 0) ...[
              const SizedBox(height: 8),
              _PriceRow(label: 'Delivery fee', amount: deliveryFee),
            ],
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: colorScheme.outline.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.amount});
  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
