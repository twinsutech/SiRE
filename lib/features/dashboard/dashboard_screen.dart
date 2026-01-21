import 'dart:math';
import 'dart:io'; // 📍 File 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../ledger/add_transaction_sheet.dart';
import '../ledger/ledger_provider.dart';
import '../settings/user_provider.dart';
import 'dashboard_provider.dart';
import '../ledger/unpaid_provider.dart';
import 'alert_provider.dart';
import 'alert_list_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final unpaidAsync = ref.watch(unpaidListProvider);
    final alerts = ref.watch(appAlertProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, alerts),
                _buildUnpaidBanner(context, ref, unpaidAsync),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              "This Month",
                              "${NumberFormat('#,###').format(data.totalIncome)} 만원",
                              Icons.monetization_on,
                              AppColors.incomeGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              "Occupancy",
                              "${(data.occupancyRate * 100).toStringAsFixed(0)}%",
                              Icons.home,
                              data.occupancyRate >= 0.9 ? AppColors.primaryNavy : Colors.orange,
                              subtitle: "${data.vacantUnits} Vacant",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Text("Revenue Trend", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildRevenueChart(data),
                      const SizedBox(height: 24),

                      const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      if (data.recentTransactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text("No recent activities", style: TextStyle(color: Colors.grey))),
                        )
                      else
                        ...data.recentTransactions.map((item) { // 📍 item(TransactionWithImages)으로 순회
                          final tx = item.transaction; // 알맹이 추출
                          final isIncome = tx.type == 'INC';
                          final themeColor = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Card(
                              elevation: 0.5,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                dense: true,
                                // 📍 탭하면 상세 정보 보기 (장부와 동일한 경험)
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => AddTransactionSheet(transaction: tx),
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: themeColor.withOpacity(0.1),
                                  child: Icon(
                                    _getCategoryIcon(tx.category),
                                    color: themeColor,
                                    size: 20,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(tx.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    // 📍 영수증 아이콘 추가 (장부와 일관성)
                                    if (item.hasImages) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.receipt_long, size: 12, color: Colors.blueGrey),
                                    ]
                                  ],
                                ),
                                subtitle: Text("${DateFormat('MM.dd').format(tx.transactionDate)} ${tx.memo ?? ''}", style: const TextStyle(fontSize: 12)),
                                trailing: Text(
                                  "${isIncome ? '+' : '-'}${NumberFormat('#,###').format(tx.amount)} 만",
                                  style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                            ),
                          );
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

  Widget _buildHeader(BuildContext context, WidgetRef ref, List<AppAlert> alerts) {
    // 📍 닉네임과 이미지 정보를 모두 담고 있는 profile 데이터 구독
    final profile = ref.watch(userNicknameProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // 📍 프로필 이미지 적용 (설정된 이미지가 있으면 FileImage, 없으면 기본 아이콘)
          CircleAvatar(
            backgroundColor: Colors.white24,
            backgroundImage: profile.imagePath != null
                ? FileImage(File(profile.imagePath!))
                : null,
            child: profile.imagePath == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome back,", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(
                profile.nickname, // 📍 profile 객체 내부의 nickname 사용
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          ShakingBellIcon(
            alertCount: alerts.length,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AlertListScreen()));
            },
          ),
        ],
      ),
    );
  }

  // ... (이하 _buildUnpaidBanner, _showUnpaidActionSheet, _buildRevenueChart 등 기존 코드 완전 동일하게 유지)

  Widget _buildUnpaidBanner(BuildContext context, WidgetRef ref, AsyncValue<List<UnpaidStatus>> unpaidAsync) {
    return unpaidAsync.when(
      data: (list) {
        final overdueUnits = list.where((u) => u.status == 'OVERDUE').toList();
        if (overdueUnits.isEmpty) return const SizedBox.shrink();

        return InkWell(
          onTap: () => _showUnpaidActionSheet(context, ref, overdueUnits),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 8)],
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Unpaid Rent Detected!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text("Rooms: ${overdueUnits.map((u) => u.unit.roomNumber).join(', ')}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showUnpaidActionSheet(BuildContext context, WidgetRef ref, List<UnpaidStatus> overdueUnits) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("미납 수납 처리", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const Text("입금이 확인된 호실의 버튼을 눌러주세요.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: overdueUnits.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final unpaid = overdueUnits[index];
                      final int rentAmount = unpaid.unit.monthlyRent;
                      final String roomNo = unpaid.unit.roomNumber;
                      final String tenant = unpaid.unit.tenantName ?? '세입자';

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          child: Text(roomNo, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        title: Text("$roomNo호 수납 확인"),
                        subtitle: Text("$tenant / ${NumberFormat('#,###').format(rentAmount)}원"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            await ref.read(ledgerActionProvider.notifier).processPayment(
                              buildingId: unpaid.unit.buildingId,
                              unitId: unpaid.unit.id,
                              tenantName: tenant,
                              amount: rentAmount,
                              buildingName: "건물",
                              unitNumber: roomNo,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$roomNo호 수납 처리가 완료되었습니다.')),
                              );
                            }
                          },
                          child: const Text("확인"),
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

  Widget _buildRevenueChart(dynamic data) {
    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                showingTooltipIndicators: [
                  ...(data.revenueSpots as List<FlSpot>).asMap().entries.map((entry) {
                    if (entry.value.y > 0) {
                      return ShowingTooltipIndicators([
                        LineBarSpot(LineChartBarData(spots: data.revenueSpots), 0, entry.value),
                      ]);
                    }
                    return null;
                  }).whereType<ShowingTooltipIndicators>(),
                  if (data.expenseSpots != null)
                    ...(data.expenseSpots as List<FlSpot>).asMap().entries.map((entry) {
                      if (entry.value.y > 0) {
                        return ShowingTooltipIndicators([
                          LineBarSpot(LineChartBarData(spots: data.expenseSpots), 1, entry.value),
                        ]);
                      }
                      return null;
                    }).whereType<ShowingTooltipIndicators>(),
                ],
                lineTouchData: LineTouchData(
                  enabled: false,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.transparent,
                    tooltipRoundedRadius: 0,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 4,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final bool isRevenue = barSpot.barIndex == 0;
                        return LineTooltipItem(
                          '${NumberFormat('#,###').format(barSpot.y)}',
                          TextStyle(
                            color: isRevenue ? const Color(0xFF1A237E) : Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final now = DateTime.now();
                        final date = DateTime(now.year, now.month - (5 - value.toInt()), 1);
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text('${date.month}월', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.revenueSpots,
                    isCurved: true,
                    color: const Color(0xFF1A237E),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: const Color(0xFF1A237E).withOpacity(0.05)),
                  ),
                  if (data.expenseSpots != null && data.expenseSpots.isNotEmpty)
                    LineChartBarData(
                      spots: data.expenseSpots,
                      isCurved: true,
                      color: Colors.red[300]!.withOpacity(0.6),
                      barWidth: 3,
                      dashArray: [5, 5],
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem("수익", const Color(0xFF1A237E)),
              const SizedBox(width: 16),
              _buildLegendItem("지출", Colors.red[300]!.withOpacity(0.6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Rent': case '월세': case '임대료 수입': return Icons.home_work_rounded;
      case 'Tax': case '세금/공과금': return Icons.request_quote_rounded;
      case 'Repair': case '수리보수비': return Icons.build_circle_rounded;
      case 'Utility': case '전기/수도료': return Icons.lightbulb_circle_rounded;
      case 'Cleaning': case '청소비': return Icons.cleaning_services_rounded;
      case 'Maintenance': case '관리비': return Icons.settings_suggest_rounded;
      case '보험료': return Icons.verified_user_rounded;
      case 'Deposit': case '보증금': return Icons.vpn_key_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500)),
          ]
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 📍 ShakingBellIcon 위젯 로직 (기존 유지)
// -----------------------------------------------------------------------------
class ShakingBellIcon extends StatefulWidget {
  final int alertCount;
  final VoidCallback onTap;

  const ShakingBellIcon({super.key, required this.alertCount, required this.onTap});

  @override
  State<ShakingBellIcon> createState() => _ShakingBellIconState();
}

class _ShakingBellIconState extends State<ShakingBellIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _startAnimationLoop();
  }

  void _startAnimationLoop() async {
    while (mounted) {
      if (widget.alertCount > 0) {
        await _controller.forward();
        await _controller.reverse();
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double rotation = sin(_controller.value * 2 * pi) * 0.15;
          return Transform.rotate(angle: widget.alertCount > 0 ? rotation : 0, child: child);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none, color: Colors.white, size: 28),
            if (widget.alertCount > 0)
              Positioned(
                right: -4,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A237E), width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Center(
                    child: Text(
                      widget.alertCount > 9 ? '9+' : '${widget.alertCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}