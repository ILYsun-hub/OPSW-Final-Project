import 'package:flutter/material.dart';
import 'models.dart';
import 'services.dart';

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
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final seniors = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text('시니어 관리')),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: seniors.length,
            itemBuilder: (context, index) {
              final s = seniors[index];
              return Card(
                child: ListTile(
                  title: Text(s.name),
                  subtitle: Text('보호자: ${s.guardianName}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteSenior(s.id),
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
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: '이름')),
          TextField(controller: _birth, decoration: const InputDecoration(labelText: '생년월일')),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: '전화번호')),
          const Divider(),
          TextField(controller: _gName, decoration: const InputDecoration(labelText: '보호자 이름')),
          TextField(controller: _gPhone, decoration: const InputDecoration(labelText: '보호자 전화번호')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await addSenior(
                name: _name.text,
                birth: _birth.text,
                phone: _phone.text,
                guardianName: _gName.text,
                guardianPhone: _gPhone.text,
              );
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
