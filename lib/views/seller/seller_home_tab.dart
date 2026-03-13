import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/seller_dashboard_controller.dart';
import '../../models/order_model.dart';
import '../../services/user_service.dart';

class SellerHomeTab extends StatelessWidget {
  const SellerHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SellerDashboardController>();
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.secondary,
                      colorScheme.secondary.withValues(alpha: 0.82),
                    ],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 20,
                    20,
                    28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                          color: colorScheme.onSecondary.withValues(alpha: 0.8),
                          fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          Get.find<UserService>().restaurantName ?? 'Your Store',
                          style: TextStyle(
                              color: colorScheme.onSecondary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy').format(now),
                      style: TextStyle(
                          color:
                              colorScheme.onSecondary.withValues(alpha: 0.75),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            // ── Stats grid ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.7,
                    children: [
                      _StatCard(
                        icon: Icons.receipt_long_rounded,
                        label: "Today's orders",
                        value: '${ctrl.todayOrderCount}',
                        color: colorScheme.primary,
                      ),
                      _StatCard(
                        icon: Icons.attach_money_rounded,
                        label: "Today's revenue",
                        value: '\$${ctrl.todayRevenue.toStringAsFixed(2)}',
                        color: Colors.green.shade600,
                      ),
                      _StatCard(
                        icon: Icons.pending_actions_rounded,
                        label: 'Active orders',
                        value: '${ctrl.activeOrderCount}',
                        color: Colors.orange.shade600,
                      ),
                      _StatCard(
                        icon: Icons.bar_chart_rounded,
                        label: 'Total orders',
                        value: '${ctrl.totalOrderCount}',
                        color: colorScheme.tertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Weekly orders chart ────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Orders — last 7 days',
                child: SizedBox(
                  height: 180,
                  child: _WeeklyBarChart(ctrl: ctrl),
                ),
              ),
            ),

            // ── Status distribution ────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Order status breakdown',
                child: _StatusBreakdown(ctrl: ctrl),
              ),
            ),

            // ── Revenue trend ─────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Revenue — last 7 days',
                child: SizedBox(
                  height: 160,
                  child: _RevenueLineChart(ctrl: ctrl),
                ),
              ),
            ),

            // ── Recent orders ─────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Recent orders',
                child: ctrl.recentOrders.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text('No orders yet',
                              style: TextStyle(color: Colors.black38)),
                        ),
                      )
                    : Column(
                        children:
                            ctrl.recentOrders.map(_RecentOrderRow.new).toList(),
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      }),
    );
  }
}

// ─── Weekly bar chart ─────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.ctrl});
  final SellerDashboardController ctrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stats = ctrl.weeklyStats;
    final maxY = ctrl.weeklyMaxCount;

    return BarChart(
      BarChartData(
        maxY: maxY + 1,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} orders',
                const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 24,
              getTitlesWidget: (value, _) {
                if (value != value.roundToDouble()) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                      fontSize: 10, color: Colors.black38),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= stats.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('EEE').format(stats[i].day),
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.black.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: stats.asMap().entries.map((e) {
          final isToday = e.key == 6;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.count.toDouble(),
                width: 20,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6)),
                color: isToday
                    ? colorScheme.secondary
                    : colorScheme.secondary.withValues(alpha: 0.35),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Revenue line chart ───────────────────────────────────────────────────────

class _RevenueLineChart extends StatelessWidget {
  const _RevenueLineChart({required this.ctrl});
  final SellerDashboardController ctrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stats = ctrl.weeklyStats;
    final maxRevenue =
        stats.fold(0.0, (m, s) => s.revenue > m ? s.revenue : m);
    final maxY = maxRevenue == 0 ? 10.0 : (maxRevenue * 1.2).ceilToDouble();

    final spots = stats.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
        .toList();

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        clipData: const FlClipData.all(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '\$${s.y.toStringAsFixed(2)}',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ))
                .toList(),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                '\$${value.toInt()}',
                style:
                    const TextStyle(fontSize: 9, color: Colors.black38),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= stats.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('EEE').format(stats[i].day),
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.black.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.green.shade500,
            barWidth: 2.5,
            dotData: FlDotData(
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: index == 6 ? 5 : 3,
                color: Colors.green.shade500,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.shade400.withValues(alpha: 0.28),
                  Colors.green.shade400.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status breakdown ─────────────────────────────────────────────────────────

class _StatusBreakdown extends StatelessWidget {
  const _StatusBreakdown({required this.ctrl});
  final SellerDashboardController ctrl;

  static const _colors = {
    'pending': Colors.orange,
    'accepted': Colors.blue,
    'preparing': Colors.purple,
    'ready_for_pickup': Colors.teal,
    'on_the_way': Colors.indigo,
    'delivered': Colors.green,
    'rejected': Colors.red,
  };

  static const _labels = {
    'pending': 'Pending',
    'accepted': 'Accepted',
    'preparing': 'Preparing',
    'ready_for_pickup': 'Ready for pickup',
    'on_the_way': 'On the way',
    'delivered': 'Delivered',
    'rejected': 'Rejected',
  };

  @override
  Widget build(BuildContext context) {
    final counts = ctrl.statusCounts;
    final total = ctrl.totalOrderCount;
    if (total == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text('No orders yet',
              style: TextStyle(color: Colors.black38)),
        ),
      );
    }

    final entries = SellerDashboardController.statusOrder
        .where((s) => (counts[s] ?? 0) > 0)
        .map((s) => MapEntry(s, counts[s]!))
        .toList();

    return Column(
      children: entries.map((e) {
        final fraction = e.value / total;
        final color = _colors[e.key] ?? Colors.grey;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 110,
                child: Text(
                  _labels[e.key] ?? e.key,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 7,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  '${e.value}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Recent order row ─────────────────────────────────────────────────────────

class _RecentOrderRow extends StatelessWidget {
  const _RecentOrderRow(this.order);
  final OrderModel order;

  Color _statusColor(String s) {
    switch (s) {
      case 'delivered':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'on_the_way':
        return Colors.blue;
      case 'ready_for_pickup':
        return Colors.teal;
      case 'preparing':
        return Colors.purple;
      case 'accepted':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeStr = order.createdAt != null
        ? DateFormat('HH:mm').format(order.createdAt!)
        : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#${order.id.substring(0, 3).toUpperCase()}',
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName?.isNotEmpty == true
                      ? order.customerName!
                      : 'Order #${order.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${order.itemCount} item${order.itemCount != 1 ? 's' : ''}  ·  $timeStr',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(order.status)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
