import 'package:flutter/material.dart';
import '../models/intake_status.dart';

class StatusChip extends StatelessWidget {
  final IntakeStatus status;

  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case IntakeStatus.taken:
        color = const Color(0xFF10B981); // Green
        text = '완료';
        break;
      case IntakeStatus.missed:
        color = const Color(0xFFEF4444); // Red
        text = '미복용';
        break;
      case IntakeStatus.late:
        color = const Color(0xFFF59E0B); // Amber
        text = '지각';
        break;
      case IntakeStatus.none:
        color = const Color(0xFF9CA3AF); // Grey
        text = '대기';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
