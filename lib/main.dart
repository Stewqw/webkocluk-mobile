import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/teacher_note_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WebKoclukMobileApp());
}

class WebKoclukMobileApp extends StatelessWidget {
  const WebKoclukMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Web Koçluk Mobil',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF102040)),
        useMaterial3: true,
      ),
      home: const FirebaseStarterPage(),
    );
  }
}

class FirebaseStarterPage extends StatefulWidget {
  const FirebaseStarterPage({super.key});

  @override
  State<FirebaseStarterPage> createState() => _FirebaseStarterPageState();
}

class _FirebaseStarterPageState extends State<FirebaseStarterPage> {
  final AuthService _authService = AuthService();
  final TeacherNoteService _noteService = TeacherNoteService();
  bool _loading = false;
  String _status = 'Hazır';

  Future<void> _anonymousSignIn() async {
    setState(() {
      _loading = true;
      _status = 'Anonim giriş yapılıyor...';
    });

    try {
      await _authService.signInAnonymously();
      setState(() => _status = 'Anonim giriş başarılı.');
    } catch (e) {
      setState(() => _status = 'Giriş hatası: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveSampleNote() async {
    setState(() {
      _loading = true;
      _status = 'Firestore test notu kaydediliyor...';
    });

    try {
      await _noteService.saveTeacherNote(
        studentId: 'demo-student',
        dayKey: 'pzt',
        note: 'Mobil uygulamadan test notu',
      );
      setState(() => _status = 'Not Firestore\'a kaydedildi.');
    } catch (e) {
      setState(() => _status = 'Kayıt hatası: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Koçluk Mobil Firebase Başlangıç')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _anonymousSignIn,
              child: const Text('Anonim Giriş Yap'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _saveSampleNote,
              child: const Text('Öğretmen Notu Test Kaydı'),
            ),
            const SizedBox(height: 20),
            Text(
              'Durum: $_status',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Not: Gerçek Firebase proje ayarları için lib/firebase_options.dart dosyasını flutterfire configure ile üretin.',
            ),
          ],
        ),
      ),
    );
  }
}
