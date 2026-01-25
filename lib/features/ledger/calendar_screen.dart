import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/theme/app_colors.dart';
import 'ledger_provider.dart';
import '../../core/database/app_database.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider);
    // 📍 현재 설정된 언어 코드 가져오기
    final currentLocale = ref.watch(localizationProvider.notifier).currentLang;

    return Scaffold(
      backgroundColor: Colors.grey[100], // 배경색 통일
      appBar: AppBar(
        // [디자인 통일]
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false, // 왼쪽 정렬
        title: Text(
          "NAV_CALENDAR".tr(ref), // 📍 다국어 적용: "Calendar View"
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (events) {
          final selectedEvents = events[DateTime.utc(
              _selectedDay.year, _selectedDay.month, _selectedDay.day)] ?? [];

          return Column(
            children: [
              // 달력 부분도 흰색 박스에 넣어 깔끔하게
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TableCalendar<Transaction>(
                  // 📍 로케일 적용: 요일 및 월 이름이 자동 번역됩니다.
                  locale: currentLocale,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: (day) {
                    return events[DateTime.utc(day.year, day.month, day.day)] ?? [];
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    HapticFeedback.lightImpact(); // 📍 터치 피드백 추가
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF1A237E),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.expenseRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "DASHBOARD_RECENT_ACTIVITY".tr(ref), // 📍 다국어: "Transactions" 또는 "Recent Activity"
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                ),
              ),

              // 하단 리스트
              Expanded(
                child: selectedEvents.isEmpty
                    ? Center(child: Text("LEDGER_NO_TRANSACTIONS".tr(ref), style: const TextStyle(color: Colors.grey)))
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: selectedEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = selectedEvents[index];
                    final isIncome = tx.type == 'INC'; // 📍 DB 타입 'INC'로 정정

                    // 📍 [화폐 다국어 처리] 로케일별 통화 포매터 정의
                    final currencyFmt = NumberFormat.simpleCurrency(
                      locale: currentLocale,
                      decimalDigits: 0, // 소수점 제외 (국가별 필요 시 조절 가능)
                    );

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isIncome ? AppColors.incomeGreen : AppColors.expenseRed,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              // 📍 카테고리 다국어 처리 (CAT_ 키워드 대응)
                              tx.category.startsWith('CAT_') ? tx.category.tr(ref) : tx.category,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          // 📍 [수정] 하드코딩된 포맷 대신 글로벌 표준 통화 포맷 적용
                          Text(
                            currencyFmt.format(tx.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isIncome ? AppColors.incomeGreen : AppColors.expenseRed,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}