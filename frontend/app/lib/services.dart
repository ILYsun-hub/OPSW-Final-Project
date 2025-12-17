import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';

final _db = FirebaseFirestore.instance;

Stream<List<Senior>> eldersStream() {
  final uid = FirebaseAuth.instance.currentUser!.uid;

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
  final uid = FirebaseAuth.instance.currentUser!.uid;

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

Future<void> deleteSenior(String id) async {
  await _db.collection('elders').doc(id).delete();
}
