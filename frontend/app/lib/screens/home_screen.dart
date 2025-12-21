import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/senior.dart';
import '../models/intake_status.dart';
import '../notifiers/data_notifier.dart';
import '../widgets/add_senior_sheet.dart';
import '../widgets/senior_detail_sheet.dart';
import '../widgets/status_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSeniorDetail(BuildContext context, Senior senior, Map<String, IntakeStatus> initialStatus) {
    showModalBottomSheet<Map<String, IntakeStatus>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SeniorDetailSheet(
        senior: senior,
        medicines: const [], // TODO: Medicine 데이터 연동
        initialStatus: initialStatus,
      ),
    ).then((newStatus) {
      if (newStatus != null) {
        // `listen: false`로 context를 BuildContext 외부에서 사용
        Provider.of<DataNotifier>(context, listen: false).updateIntakeStatus(senior.id, newStatus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 복약', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
          IconButton(
            onPressed: () => Provider.of<DataNotifier>(context, listen: false).fetchData(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      // Consumer 위젯을 사용하여 DataNotifier의 변경 사항을 감시
      body: Consumer<DataNotifier>(
        builder: (context, dataNotifier, child) {
          if (dataNotifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dataNotifier.error != null) {
            return Center(child: Text('오류: ${dataNotifier.error}'));
          }

          final seniors = dataNotifier.seniors;
          final intakeStatusMap = dataNotifier.intakeStatus;
          final doneCount = 0; // TODO: 완료 카운트 로직 구현

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 요약 카드
                 Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF818CF8)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('오늘 관리 현황', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Pretendard'),
                                children: [
                                  const TextSpan(text: '총 '),
                                  TextSpan(text: '${seniors.length}명', style: const TextStyle(fontSize: 28)),
                                  const TextSpan(text: ' 중 '),
                                  TextSpan(text: '$doneCount명', style: const TextStyle(fontSize: 28, color: Color(0xFFFEF08A))),
                                  const TextSpan(text: ' 완료'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.pie_chart, color: Colors.white, size: 32),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('관리 중인 시니어', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const AddSeniorSheet()),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('추가'),
                    )
                  ],
                ),
                
                const SizedBox(height: 10),

                // 시니어 리스트
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: seniors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final senior = seniors[index];
                    final status = intakeStatusMap[senior.id] ?? {'morning': IntakeStatus.none, 'lunch': IntakeStatus.none, 'dinner': IntakeStatus.none};
                    
                    return GestureDetector(
                      onTap: () => _openSeniorDetail(context, senior, status),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Text(senior.emoji, style: const TextStyle(fontSize: 48)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(senior.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text('보호자: ${senior.guardianName}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(children: [const Text('아침 ', style: TextStyle(fontSize: 12)), StatusChip(status['morning']!)]),
                                const SizedBox(height: 4),
                                Row(children: [const Text('점심 ', style: TextStyle(fontSize: 12)), StatusChip(status['lunch']!)]),
                                const SizedBox(height: 4),
                                Row(children: [const Text('저녁 ', style: TextStyle(fontSize: 12)), StatusChip(status['dinner']!)]),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
