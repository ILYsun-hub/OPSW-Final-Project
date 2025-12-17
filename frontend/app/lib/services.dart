import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models.dart';
import 'enums.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

/* ────────────────────────────
   User
   ──────────────────────────── */

Future<void> ensureUserDoc() async {
  final user = _auth.currentUser;
  if (user == null) return;

  final ref = _db.collection('users').doc(user.uid);
  final snap = await ref.get();

  if (!snap.exists) {
    await ref.set({
      'email': user.email ?? '',
      'role': 'caregiver',
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}

/* ────────────────────────────
   Elders (CRUD)
   ──────────────────────────── */

Stream<List<Senior>> eldersStream() {
  final uid = _auth.currentUser!.uid;

  return _db
      .collection('elders')
      .where('user_id', isEqualTo: uid)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((d) => Senior.fromMap(d.id, d.data())).toList(),
      );
}

Future<void> addSenior({
  required String name,
  required String birth,
  required String phone,
  required String guardianName,
  required String guardianPhone,
}) async {
  final uid = _auth.currentUser!.uid;

  await _db.collection('elders').add({
    'user_id': uid,
    'name': name,
    'birth': birth,
    'phone': phone,
    'guardian_name': guardianName,
    'guardian_phone': guardianPhone,
    'created_at': FieldValue.serverTimestamp(),
  });
}

Future<void> deleteSenior(String elderId) async {
  await _db.collection('elders').doc(elderId).delete();
}

/* ────────────────────────────
   Intake Logs
   ──────────────────────────── */

Future<void> saveIntake({
  required String elderId,
  required DateTime date,
  required IntakeSlot slot,
  required IntakeStatus status,
}) async {
  final uid = _auth.currentUser!.uid;

  final dayKey =
      '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

  final docId = '${elderId}_${dayKey}_${slot.name}';

  await _db.collection('intake_logs').doc(docId).set({
    'user_id': uid,
    'elder_id': elderId,
    'date': Timestamp.fromDate(date),
    'slot': slot.name,
    'status': status.name,
    'updated_at': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Stream<Map<IntakeSlot, IntakeStatus>> todayIntakeStream(String elderId) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));

  final startTs = Timestamp.fromDate(start);
  final endTs = Timestamp.fromDate(end);

  return _db
      .collection('intake_logs')
      .where('elder_id', isEqualTo: elderId)
      .where('date', isGreaterThanOrEqualTo: startTs)
      .where('date', isLessThan: endTs)
      .snapshots()
      .map((snap) {
        final result = <IntakeSlot, IntakeStatus>{
          IntakeSlot.morning: IntakeStatus.none,
          IntakeSlot.lunch: IntakeStatus.none,
          IntakeSlot.dinner: IntakeStatus.none,
        };

        for (final doc in snap.docs) {
          final data = doc.data();

          final slotStr = data['slot'] as String?;
          final statusStr = data['status'] as String?;

          if (slotStr == null || statusStr == null) continue;

          final slot = IntakeSlot.values.firstWhere(
            (e) => e.name == slotStr,
            orElse: () => IntakeSlot.morning,
          );

          final status = IntakeStatus.values.firstWhere(
            (e) => e.name == statusStr,
            orElse: () => IntakeStatus.none,
          );

          result[slot] = status;
        }

        return result;
      });
}
