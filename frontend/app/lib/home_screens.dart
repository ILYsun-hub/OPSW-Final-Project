import 'package:flutter/material.dart';

import 'models.dart';
import 'services.dart';
import 'enums.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddSeniorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Senior>>(
      stream: eldersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('에러: ${snapshot.error}')),
          );
        }

        final seniors = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(title: const Text('시니어 관리')),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: seniors.length,
            itemBuilder: (context, index) {
              final s = seniors[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(s.name),
                        subtitle: Text('보호자: ${s.guardianName}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteSenior(s.id),
                        ),
                      ),
                      const SizedBox(height: 8),
                      intakeButtons(context, s),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAdd(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class AddSeniorSheet extends StatefulWidget {
  const AddSeniorSheet({super.key});

  @override
  State<AddSeniorSheet> createState() => _AddSeniorSheetState();
}

class _AddSeniorSheetState extends State<AddSeniorSheet> {
  final _name = TextEditingController();
  final _birth = TextEditingController();
  final _phone = TextEditingController();
  final _gName = TextEditingController();
  final _gPhone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _birth.dispose();
    _phone.dispose();
    _gName.dispose();
    _gPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _birth,
              decoration: const InputDecoration(labelText: '생년월일'),
            ),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: '전화번호'),
            ),
            const Divider(),
            TextField(
              controller: _gName,
              decoration: const InputDecoration(labelText: '보호자 이름'),
            ),
            TextField(
              controller: _gPhone,
              decoration: const InputDecoration(labelText: '보호자 전화번호'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await addSenior(
                    name: _name.text,
                    birth: _birth.text,
                    phone: _phone.text,
                    guardianName: _gName.text,
                    guardianPhone: _gPhone.text,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget intakeButtons(BuildContext context, Senior s) {
  return StreamBuilder<Map<IntakeSlot, IntakeStatus>>(
    stream: todayIntakeStream(s.id),
    builder: (context, snapshot) {
      final data = snapshot.data ??
          {
            IntakeSlot.morning: IntakeStatus.none,
            IntakeSlot.lunch: IntakeStatus.none,
            IntakeSlot.dinner: IntakeStatus.none,
          };

      ElevatedButton btn(String label, IntakeSlot slot) {
        final current = data[slot] ?? IntakeStatus.none;

        return ElevatedButton(
          onPressed: () async {
            await saveIntake(
              elderId: s.id,
              date: DateTime.now(),
              slot: slot,
              status: IntakeStatus.taken,
            );
          },
          child: Text('$label (${current.name})'),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          btn('아침', IntakeSlot.morning),
          btn('점심', IntakeSlot.lunch),
          btn('저녁', IntakeSlot.dinner),
        ],
      );
    },
  );
}
