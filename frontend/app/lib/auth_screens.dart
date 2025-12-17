import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

Future<void> ensureUserDoc(User user) async {
  final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final snap = await ref.get();

  if (!snap.exists) {
    await ref.set({
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'phone': user.phoneNumber ?? '',
      'role': 'caregiver',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

Stream<AppUser?> userProfileStream() {
  final u = FirebaseAuth.instance.currentUser;
  if (u == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(u.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return AppUser.fromDoc(u.uid, doc.data());
  });
}

/* ───────── AuthGate ───────── */

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          if (user.emailVerified) {
            return const ProfileScreen();
          }
          return const EmailVerificationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

/* ───────── Login ───────── */

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if (email.text.isEmpty || password.text.isEmpty) return;

    setState(() => loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      await ensureUserDoc(cred.user!);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: email, decoration: const InputDecoration(labelText: '이메일')),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : login,
              child: const Text('로그인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────── Signup ───────── */

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> signup() async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .set({
      'name': name.text,
      'email': email.text,
      'role': 'caregiver',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await cred.user!.sendEmailVerification();
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: '이름')),
            TextField(controller: email, decoration: const InputDecoration(labelText: '이메일')),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: signup, child: const Text('가입')),
          ],
        ),
      ),
    );
  }
}

/* ───────── Email Verify ───────── */

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('이메일 인증 후 다시 로그인하세요'),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.reload();
              },
              child: const Text('새로고침'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────── Profile ───────── */

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: userProfileStream(),
      builder: (context, snapshot) {
        final me = snapshot.data;
        return Scaffold(
          appBar: AppBar(title: const Text('내 정보')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  title: Text(me?.name ?? '사용자'),
                  subtitle: Text(me?.email ?? ''),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Text('로그아웃'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
