import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/driver_dashboard_controller.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';

class DriverDashboardTab extends StatelessWidget {
  const DriverDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DriverDashboardController>();
    final auth = Get.find<AuthService>();
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
        final driverName = auth.currentUser.value?.displayName ??
            auth.currentUser.value?.email?.split('@').first ??
            'Driver';
        final nameCapitalized = driverName.isNotEmpty
            ? driverName[0].toUpperCase() + driverName.substring(1)
            : driverName;

        return CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
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
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        color: colorScheme.onSecondary.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nameCapitalized,
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy').format(now),
                      style: TextStyle(
                        color:
                            colorScheme.onSecondary.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Stat cards ──────────────────────────────────────────────────
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
                        icon: Icons.directions_bike_rounded,
                        label: "Today's deliveries",
                        value: '${ctrl.todayDeliveryCount}',
                        color: colorScheme.primary,
                      ),
                      _StatCard(
                        icon: Icons.payments_rounded,
                        label: "Today's earnings",
                        value:
                            '\$${ctrl.todayEarnings.toStringAsFixed(2)}',
                        color: Colors.green.shade600,
                      ),
                      _StatCard(
                        icon: Icons.local_shipping_rounded,
                        label: 'Total deliveries',
                        value: '${ctrl.totalDeliveryCount}',
                        color: Colors.orange.shade600,
                      ),
                      _StatCard(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Total earned',
                        value:
                            '\$${ctrl.totalEarnings.toStringAsFixed(2)}',
                        color: colorScheme.tertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Weekly deliveries chart ──────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Deliveries — last 7 days',
                child: SizedBox(
                  height: 180,
                  child: _WeeklyBarChart(ctrl: ctrl),
                ),
              ),
            ),

            // ── Earnings trend ───────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Earnings — last 7 days',
                child: SizedBox(
                  height: 160,
                  child: _EarningsLineChart(ctrl: ctrl),
                ),
              ),
            ),

            // ── Settlement summary ───────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Settlement summary',
                child: _SettlementSummary(ctrl: ctrl),
              ),
            ),

            // ── Recent deliveries ────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Recent deliveries',
                child: ctrl.recentDeliveries.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'No deliveries yet',
                            style: TextStyle(color: Colors.black38),
                          ),
                        ),
                      )
                    : Column(
                        children: ctrl.recentDeliveries
                            .map(_RecentDeliveryRow.new)
                            .toList(),
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
  final DriverDashboardController ctrl;

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
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
              '${rod.toY.toInt()} deliveries',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
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
                  style: const TextStyle(fontSize: 10, color: Colors.black38),
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
                      fontWeight: FontWeight.w500,
                    ),
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
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

// ─── Earnings line chart ─────────────────────────────────────────────────────

class _EarningsLineChart extends StatelessWidget {
  const _EarningsLineChart({required this.ctrl});
  final DriverDashboardController ctrl;

  @override
  Widget build(BuildContext context) {
    final stats = ctrl.weeklyStats;
    final maxEarnings =
        stats.fold(0.0, (m, s) => s.earnings > m ? s.earnings : m);
    final maxY =
        maxEarnings == 0 ? 10.0 : (maxEarnings * 1.2).ceilToDouble();

    final spots = stats
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.earnings))
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
                        fontSize: 12,
                      ),
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
                style: const TextStyle(fontSize: 9, color: Colors.black38),
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
                      fontWeight: FontWeight.w500,
                    ),
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
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
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

// ─── Settlement summary ───────────────────────────────────────────────────────

class _SettlementSummary extends StatelessWidget {
  const _SettlementSummary({required this.ctrl});
  final DriverDashboardController ctrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentWeek = ctrl.currentWeekEarnings;
    final lastWeek = ctrl.lastWeekEarnings;
    final diff = currentWeek - lastWeek;
    final diffPositive = diff >= 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SettlementPeriodTile(
                label: 'This week',
                amount: currentWeek,
                color: colorScheme.primary,
                icon: Icons.pending_rounded,
                note: 'Pending payout',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SettlementPeriodTile(
                label: 'Last week',
                amount: lastWeek,
                color: Colors.green.shade600,
                icon: Icons.check_circle_rounded,
                note: 'Paid out',
              ),
            ),
          ],
        ),
        if (lastWeek > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: (diffPositive
                      ? Colors.green.shade600
                      : Colors.orange.shade600)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  diffPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 18,
                  color: diffPositive
                      ? Colors.green.shade600
                      : Colors.orange.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  diffPositive
                      ? '+\$${diff.abs().toStringAsFixed(2)} vs last week'
                      : '-\$${diff.abs().toStringAsFixed(2)} vs last week',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: diffPositive
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Earnings = 15% of each delivered order total.',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettlementPeriodTile extends StatelessWidget {
  const _SettlementPeriodTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.note,
  });
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            note,
            style: const TextStyle(fontSize: 10, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}

// ─── Recent delivery row ──────────────────────────────────────────────────────

class _RecentDeliveryRow extends StatelessWidget {
  const _RecentDeliveryRow(this.order);
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeStr = order.createdAt != null
        ? DateFormat('HH:mm').format(order.createdAt!)
        : '';
    final earned = order.total * 0.15;

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
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.restaurantName?.isNotEmpty == true
                      ? order.restaurantName!
                      : 'Order #${order.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${order.itemCount} item${order.itemCount != 1 ? 's' : ''}  ·  $timeStr',
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+\$${earned.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                ),
              ),
              Text(
                'order \$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 10, color: Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

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
                    fontWeight: FontWeight.w500,
                  ),
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
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
