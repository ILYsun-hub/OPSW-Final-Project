import 'package:flutter/material.dart';

class AddSeniorSheet extends StatelessWidget {
  const AddSeniorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Text("새 시니어 추가", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextFormField(decoration: const InputDecoration(labelText: '이름', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextFormField(decoration: const InputDecoration(labelText: '생년월일 (예: 1940.01.01)', border: OutlineInputBorder())),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('시니어 추가 기능은 백엔드 연동 후 활성화됩니다.')));
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text("등록하기"),
            ),
          )
        ],
      ),
    );
  }
}
