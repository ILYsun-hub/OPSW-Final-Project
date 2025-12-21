import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/intake_status.dart';
import '../models/medicine.dart';
import '../models/senior.dart';
import '../notifiers/data_notifier.dart';

class SeniorDetailSheet extends StatefulWidget {
  final Senior senior;
  final Map<String, IntakeStatus> initialStatus;
  final List<Medicine> medicines;

  const SeniorDetailSheet({
    super.key,
    required this.senior,
    required this.initialStatus,
    required this.medicines,
  });

  @override
  State<SeniorDetailSheet> createState() => _SeniorDetailSheetState();
}

class _SeniorDetailSheetState extends State<SeniorDetailSheet> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  late Map<String, IntakeStatus> currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = Map.from(widget.initialStatus);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _pickedImage = image);
  }

  // 상태 변경 함수
  void _updateStatus(String time, IntakeStatus status) {
    setState(() {
      currentStatus[time] = status;
    });
  }

  // 상태 선택 바텀시트
  void _showStatusSelector(String time) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('복용 완료'), leading: const Icon(Icons.check_circle, color: Colors.green), onTap: () { _updateStatus(time, IntakeStatus.taken); Navigator.pop(context); }),
            ListTile(title: const Text('지각 복용'), leading: const Icon(Icons.watch_later, color: Colors.amber), onTap: () { _updateStatus(time, IntakeStatus.late); Navigator.pop(context); }),
            ListTile(title: const Text('미복용 (건너뜀)'), leading: const Icon(Icons.cancel, color: Colors.red), onTap: () { _updateStatus(time, IntakeStatus.missed); Navigator.pop(context); }),
            ListTile(title: const Text('기록 없음'), leading: const Icon(Icons.circle_outlined), onTap: () { _updateStatus(time, IntakeStatus.none); Navigator.pop(context); }),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildIntakeRow(String timeKey, String label, IconData icon) {
    final status = currentStatus[timeKey]!;
    Color color;
    String text;
    
    // UI 상태값 매핑
    switch (status) {
      case IntakeStatus.taken: color = Colors.green; text = "완료"; break;
      case IntakeStatus.late: color = Colors.amber; text = "지각"; break;
      case IntakeStatus.missed: color = Colors.red; text = "미복용"; break;
      default: color = Colors.grey; text = "기록 없음";
    }

    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
        child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
      onTap: () => _showStatusSelector(timeKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // 핸들바
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // 프로필 섹션
                    Center(child: Text(widget.senior.emoji, style: const TextStyle(fontSize: 60))),
                    const SizedBox(height: 8),
                    Center(child: Text(widget.senior.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                    Center(child: Text('${widget.senior.age}세 • 생일 ${widget.senior.birth}', style: TextStyle(color: Colors.grey[600]))),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // 약 봉투 촬영 섹션
                    const Text("약 봉투 촬영 (자동 인식)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _pickedImage != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover))
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("터치하여 촬영하기", style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 복약 체크리스트
                    const Text("오늘의 복약 체크", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          _buildIntakeRow('morning', '아침 복약', Icons.wb_twilight),
                          const Divider(height: 1),
                          _buildIntakeRow('lunch', '점심 복약', Icons.wb_sunny),
                          const Divider(height: 1),
                          _buildIntakeRow('dinner', '저녁 복약', Icons.nights_stay),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 처방 약 정보
                    const Text("처방 약 정보", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...widget.medicines.map((med) => Card(
                      elevation: 0,
                      color: Colors.blue[50],
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Text(med.emoji, style: const TextStyle(fontSize: 24)),
                        title: Text(med.name),
                        subtitle: Text(med.times.join(', ')),
                        trailing: const Icon(Icons.info_outline, size: 20),
                      ),
                    )),
                  ],
                ),
              ),

              // 하단 버튼
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<DataNotifier>(context, listen: false)
                          .updateIntakeStatus(widget.senior.id, currentStatus);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("저장 및 닫기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
