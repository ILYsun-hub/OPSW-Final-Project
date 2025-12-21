/// 간단한 리포트 데이터 모델
class ReportData {
  final int weeklyAdherence;
  final String mostMissedTime;
  final String healthSummary;
  final String advice;

  ReportData({
    required this.weeklyAdherence,
    required this.mostMissedTime,
    required this.healthSummary,
    required this.advice,
  });
}
