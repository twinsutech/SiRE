import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/localization/localization_provider.dart';
import '../../core/theme/app_colors.dart';
import '../ledger/add_transaction_sheet.dart';
import '../ledger/ledger_provider.dart';
import '../settings/user_provider.dart';
import 'dashboard_provider.dart';
import '../ledger/unpaid_provider.dart';
import 'alert_provider.dart';
import 'alert_list_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() {
    return _DashboardScreenState();
  }
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _chartScrollController = ScrollController();

  bool _canScrollLeft = true;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _chartScrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollListener();
      }
    });
  }

  void _scrollListener() {
    if (!_chartScrollController.hasClients) { return; }

    final maxScroll = _chartScrollController.position.maxScrollExtent;
    final currentScroll = _chartScrollController.offset;

    final newCanScrollLeft = currentScroll < maxScroll - 5;
    final newCanScrollRight = currentScroll > 5;

    if (_canScrollLeft != newCanScrollLeft || _canScrollRight != newCanScrollRight) {
      setState(() {
        _canScrollLeft = newCanScrollLeft;
        _canScrollRight = newCanScrollRight;
      });
    }
  }

  @override
  void dispose() {
    _chartScrollController.removeListener(_scrollListener);
    _chartScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 📍 타입을 dynamic으로 처리하여 'Type not found' 에러를 방지합니다.
    final l10n = ref.watch(localizationProvider.notifier);

    final dashboardAsync = ref.watch(dashboardDataProvider);
    final unpaidAsync = ref.watch(unpaidListProvider);
    final alerts = ref.watch(appAlertProvider);

    // l10n 객체의 currentLang 속성이 있는지 확인하고 사용
    final String currentLang = (l10n as dynamic).currentLang ?? 'ko';
    final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: dashboardAsync.when(
        loading: () { return const Center(child: CircularProgressIndicator()); },
        error: (err, stack) { return Center(child: Text('Error: $err')); },
        data: (data) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, l10n, alerts),
                _buildUnpaidBanner(context, ref, l10n, unpaidAsync),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              l10n, "DASHBOARD_THIS_MONTH",
                              currencyFmt.format(data.totalIncome),
                              Icons.monetization_on, AppColors.incomeGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              l10n, "DASHBOARD_OCCUPANCY",
                              "${(data.occupancyRate * 100).toStringAsFixed(0)}%",
                              Icons.home,
                              data.occupancyRate >= 0.9 ? AppColors.primaryNavy : Colors.orange,
                              subtitle: "${data.vacantUnits} ${(l10n as dynamic).translate("DASHBOARD_VACANT_UNITS")}",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text((l10n as dynamic).translate("DASHBOARD_REVENUE_TREND"),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildRevenueChart(data, l10n),
                      const SizedBox(height: 24),
                      Text((l10n as dynamic).translate("DASHBOARD_RECENT_ACTIVITY"),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (data.recentTransactions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text((l10n as dynamic).translate("DASHBOARD_NO_RECENT_ACTIVITY"), style: const TextStyle(color: Colors.grey))),
                        )
                      else
                        ...data.recentTransactions.map((item) {
                          return _buildTransactionItem(context, ref, l10n, item, currencyFmt);
                        }),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ 타입을 dynamic으로 수정하여 컴파일 에러 해결
  Widget _buildTransactionItem(BuildContext context, WidgetRef ref, dynamic l10n, dynamic item, NumberFormat fmt) {
    final tx = item.transaction;
    final bool isIncome = tx.type == 'INC';
    final Color color = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;

    final String categoryDisplayName = tx.category.startsWith('CAT_')
        ? l10n.translate(tx.category)
        : tx.category;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Card(
        elevation: 0.5, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          dense: true,
          onTap: () { showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) { return AddTransactionSheet(transaction: tx); }); },
          leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(_getCategoryIcon(tx.category), color: color, size: 20)),
          title: Text(categoryDisplayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text("${DateFormat('MM.dd').format(tx.transactionDate)} ${tx.memo ?? ''}", style: const TextStyle(fontSize: 12)),
          trailing: Text("${isIncome ? '+' : '-'}${fmt.format(tx.amount)}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ),
    );
  }

  Widget _buildRevenueChart(dynamic data, dynamic l10n) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableWidth = screenWidth - 32;
    final double singlePointWidth = availableWidth / 5.5;
    final double chartTotalWidth = max(availableWidth, (data.revenueSpots as List).length * singlePointWidth);

    return Container(
      height: 280,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 40, 10, 12),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _chartScrollController,
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: SizedBox(
                      width: chartTotalWidth,
                      child: LineChart(
                        LineChartData(
                          lineTouchData: const LineTouchData(enabled: false),
                          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) { return FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1); }),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final now = DateTime.now();
                                  final int spotCount = (data.revenueSpots as List).length;
                                  final int monthOffset = (spotCount - 1 - value.toInt()).toInt();
                                  final date = DateTime(now.year, now.month - monthOffset, 1);
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 8,
                                    fitInside: SideTitleFitInsideData(
                                      enabled: true,
                                      axisPosition: meta.axisPosition,
                                      parentAxisSize: meta.parentAxisSize,
                                      distanceFromEdge: 0,
                                    ),
                                    child: Text('${date.month}${l10n.translate("COMMON_MONTH_UNIT")}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                                spots: data.revenueSpots, isCurved: true, color: const Color(0xFF1A237E), barWidth: 4, dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(show: true, color: const Color(0xFF1A237E).withOpacity(0.05))
                            ),
                            if (data.expenseSpots != null && (data.expenseSpots as List).isNotEmpty)
                              LineChartBarData(spots: data.expenseSpots, isCurved: true, color: Colors.red[300]!.withOpacity(0.6), barWidth: 3, dashArray: [5, 5], dotData: const FlDotData(show: false)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _buildLegendItem(l10n, "COMMON_INCOME", const Color(0xFF1A237E)),
                  const SizedBox(width: 16),
                  _buildLegendItem(l10n, "COMMON_EXPENSE", Colors.red[300]!.withOpacity(0.6)),
                ]),
              ],
            ),
          ),
          if (_canScrollLeft)
            Positioned(
              left: 8, top: 0, bottom: 40,
              child: Center(child: _buildScrollButton(Icons.chevron_left, () {
                _chartScrollController.animateTo(_chartScrollController.offset + 150, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              })),
            ),
          if (_canScrollRight)
            Positioned(
              right: 8, top: 0, bottom: 40,
              child: Center(child: _buildScrollButton(Icons.chevron_right, () {
                _chartScrollController.animateTo(_chartScrollController.offset - 150, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              })),
            ),
        ],
      ),
    );
  }

  Widget _buildScrollButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: IconButton(icon: Icon(icon, color: const Color(0xFF1A237E), size: 24), onPressed: onTap),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, dynamic l10n, List<AppAlert> alerts) {
    final profile = ref.watch(userNicknameProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(color: Color(0xFF1A237E), borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
      child: Row(children: [
        CircleAvatar(backgroundColor: Colors.white24, backgroundImage: profile.imagePath != null ? FileImage(File(profile.imagePath!)) : null, child: profile.imagePath == null ? const Icon(Icons.person, color: Colors.white) : null),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.translate("DASHBOARD_WELCOME"), style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(profile.nickname.startsWith('SETTINGS_') ? l10n.translate(profile.nickname) : profile.nickname, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
        ])),
        ShakingBellIcon(alertCount: alerts.length, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) { return const AlertListScreen(); })); }),
      ]),
    );
  }

  Widget _buildUnpaidBanner(BuildContext context, WidgetRef ref, dynamic l10n, AsyncValue<List<UnpaidStatus>> unpaidAsync) {
    return unpaidAsync.when(
      data: (list) {
        final overdueUnits = list.where((u) { return u.status == 'OVERDUE'; }).toList();
        if (overdueUnits.isEmpty) { return const SizedBox.shrink(); }
        final roomsText = overdueUnits.map((u) { return u.unit.roomNumber; }).join(', ');
        return InkWell(
          onTap: () { HapticFeedback.mediumImpact(); _showUnpaidActionSheet(context, ref, l10n, overdueUnits); },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.9), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 8)]),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.translate("DASHBOARD_UNPAID_DETECTED"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text("${l10n.translate("COMMON_ROOMS")}: $roomsText", style: const TextStyle(color: Colors.white, fontSize: 13)),
              ])),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ]),
          ),
        );
      },
      loading: () { return const SizedBox.shrink(); },
      error: (_, __) { return const SizedBox.shrink(); },
    );
  }

  void _showUnpaidActionSheet(BuildContext context, WidgetRef ref, dynamic l10n, List<UnpaidStatus> overdueUnits) {
    final currencyFmt = NumberFormat.simpleCurrency(locale: (l10n as dynamic).currentLang, decimalDigits: 0);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(l10n.translate("DASHBOARD_UNPAID_TITLE"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  IconButton(onPressed: () { Navigator.pop(context); }, icon: const Icon(Icons.close)),
                ]),
                Text(l10n.translate("DASHBOARD_UNPAID_SUBTITLE"), style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: overdueUnits.length,
                    separatorBuilder: (context, index) { return const Divider(height: 1); },
                    itemBuilder: (context, index) {
                      final unpaid = overdueUnits[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(backgroundColor: Colors.redAccent.withOpacity(0.1), child: FittedBox(fit: BoxFit.scaleDown, child: Text(unpaid.unit.roomNumber, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)))),
                        title: Text("${unpaid.unit.roomNumber}${l10n.translate("COMMON_ROOM_UNIT")} ${l10n.translate("DASHBOARD_PAYMENT_CONFIRM")}", maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text("${unpaid.unit.tenantName ?? '세입자'} / ${currencyFmt.format(unpaid.unit.monthlyRent)}", maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            onPressed: () async {
                              await ref.read(ledgerActionProvider.notifier).processPayment(buildingId: unpaid.unit.buildingId, unitId: unpaid.unit.id, tenantName: unpaid.unit.tenantName ?? '세입자', amount: unpaid.unit.monthlyRent, buildingName: "건물", unitNumber: unpaid.unit.roomNumber);
                              if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${unpaid.unit.roomNumber}${l10n.translate("DASHBOARD_PAYMENT_COMPLETE")}'))); }
                            },
                            child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.translate("COMMON_CONFIRM"), maxLines: 1)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(dynamic l10n, String labelKey, Color color) {
    return Row(children: [Container(width: 12, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 4), Text(l10n.translate(labelKey), style: const TextStyle(fontSize: 11, color: Colors.grey))]);
  }

  Widget _buildSummaryCard(dynamic l10n, String titleKey, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 28), const SizedBox(height: 12),
        Text(l10n.translate(titleKey), style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 4),
        FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.redAccent, fontSize: 11))]
      ]),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'CAT_RENT': return Icons.home_work_rounded;
      case 'CAT_TAX': return Icons.request_quote_rounded;
      case 'CAT_REPAIR': return Icons.build_circle_rounded;
      case 'CAT_UTILITY': return Icons.lightbulb_circle_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }
}

class ShakingBellIcon extends StatefulWidget {
  final int alertCount;
  final VoidCallback onTap;
  const ShakingBellIcon({super.key, required this.alertCount, required this.onTap});
  @override
  State<ShakingBellIcon> createState() { return _ShakingBellIconState(); }
}

class _ShakingBellIconState extends State<ShakingBellIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() { super.initState(); _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this); _startAnimationLoop(); }
  void _startAnimationLoop() async { while (mounted) { if (widget.alertCount > 0) { await _controller.forward(); await _controller.reverse(); } await Future.delayed(const Duration(seconds: 3)); } }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) { return Transform.rotate(angle: widget.alertCount > 0 ? sin(_controller.value * 2 * pi) * 0.15 : 0, child: child); },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none, color: Colors.white, size: 28),
            if (widget.alertCount > 0)
              Positioned(right: -4, top: -2, child: Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1A237E), width: 1.5)), constraints: const BoxConstraints(minWidth: 18, minHeight: 18), child: Center(child: Text(widget.alertCount > 9 ? '9+' : '${widget.alertCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))),
          ],
        ),
      ),
    );
  }
}