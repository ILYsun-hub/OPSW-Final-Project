import 'package:flutter/material.dart';
import '../widgets/report_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 리포트')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ReportCard(title: '주간 복약 달성률', value: '92%', icon: Icons.pie_chart, color: Colors.blue),
          const ReportCard(title: '가장 자주 잊는 시간', value: '저녁 식후', icon: Icons.warning_amber, color: Colors.orange),
          const ReportCard(title: '건강 상태 요약', value: '혈압 안정적', icon: Icons.favorite, color: Colors.red),
          const SizedBox(height: 20),
          const Text("이번 주 조언", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.3)),
            ),
            child: const Text(
              "저녁 약 복용 시간이 불규칙합니다. 알람을 30분 일찍 설정해보는 것을 추천합니다.",
              style: TextStyle(color: Color(0xFF3730A3)),
            ),
          )
        ],
      ),
    );
  }
}
