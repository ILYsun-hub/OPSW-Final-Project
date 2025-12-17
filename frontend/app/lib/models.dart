class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory AppUser.fromDoc(String uid, Map<String, dynamic>? data) {
    final d = data ?? {};
    return AppUser(
      uid: uid,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
    );
  }
}

class Senior {
  final String id;
  final String name;
  final String birth;
  final String phone;
  final String guardianName;
  final String guardianPhone;

  Senior({
    required this.id,
    required this.name,
    required this.birth,
    required this.phone,
    required this.guardianName,
    required this.guardianPhone,
  });

  factory Senior.fromMap(String id, Map<String, dynamic> data) {
    return Senior(
      id: id,
      name: data['name'] ?? '',
      birth: data['birth'] ?? '',
      phone: data['phone'] ?? '',
      guardianName: data['guardian_name'] ?? '',
      guardianPhone: data['guardian_phone'] ?? '',
    );
  }
}
