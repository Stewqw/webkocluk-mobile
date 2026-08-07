import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/app_user.dart';
import 'services/auth_service.dart';
import 'services/teacher_note_service.dart';
import 'services/user_profile_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? initError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    initError = e.toString();
  }
  runApp(WebKoclukMobileApp(initError: initError));
}

class WebKoclukMobileApp extends StatelessWidget {
  const WebKoclukMobileApp({super.key, this.initError});

  final String? initError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Web Koçluk Mobil',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF102040)),
        useMaterial3: true,
      ),
      home: AuthGate(initError: initError),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.initError});

  final String? initError;

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return InitErrorPage(message: initError!);
    }

    final authService = AuthService();
    final profileService = UserProfileService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return SignInPage(authService: authService, profileService: profileService);
        }

        return StreamBuilder<AppUserProfile?>(
          stream: profileService.watchProfile(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final profile = profileSnapshot.data;
            if (profile == null) {
              return ProfileSetupPage(
                email: user.email ?? '',
                uid: user.uid,
                profileService: profileService,
              );
            }

            return RoleHomePage(
              profile: profile,
              authService: authService,
            );
          },
        );
      },
    );
  }
}

class InitErrorPage extends StatelessWidget {
  const InitErrorPage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Ayar Hatasi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase baslatilamadi. Once flutterfire configure ile ayar dosyasini uretin.',
            ),
            const SizedBox(height: 12),
            SelectableText(message),
          ],
        ),
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
    required this.authService,
    required this.profileService,
  });

  final AuthService authService;
  final UserProfileService profileService;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  AppUserRole _selectedRole = AppUserRole.student;
  bool _isRegister = false;
  bool _loading = false;
  String _message = 'Giris yapin veya kayit olusturun.';

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _message = 'Islem yapiliyor...';
    });

    try {
      if (_isRegister) {
        final userCred = await widget.authService.registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        final profile = AppUserProfile(
          uid: userCred.user!.uid,
          email: _emailController.text.trim(),
          displayName: _nameController.text.trim(),
          role: _selectedRole,
          linkedStudentIds: const [],
        );

        await widget.profileService.upsertProfile(profile);
        setState(() => _message = 'Kayit olusturuldu.');
      } else {
        await widget.authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        setState(() => _message = 'Giris basarili.');
      }
    } catch (e) {
      setState(() => _message = 'Hata: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Kocluk Mobil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-posta'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Sifre'),
            ),
            const SizedBox(height: 10),
            if (_isRegister)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
              ),
            if (_isRegister)
              const SizedBox(height: 10),
            if (_isRegister)
              DropdownButtonFormField<AppUserRole>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(
                    value: AppUserRole.student,
                    child: Text('Ogrenci'),
                  ),
                  DropdownMenuItem(
                    value: AppUserRole.parent,
                    child: Text('Veli'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedRole = value);
                },
              ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_isRegister ? 'Kayit Ol' : 'Giris Yap'),
            ),
            TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      setState(() {
                        _isRegister = !_isRegister;
                      });
                    },
              child: Text(
                _isRegister
                    ? 'Zaten hesabim var, giris yap'
                    : 'Hesabim yok, kayit ol',
              ),
            ),
            const SizedBox(height: 8),
            Text('Durum: $_message'),
          ],
        ),
      ),
    );
  }
}

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({
    super.key,
    required this.uid,
    required this.email,
    required this.profileService,
  });

  final String uid;
  final String email;
  final UserProfileService profileService;

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameController = TextEditingController();
  AppUserRole _role = AppUserRole.student;
  bool _saving = false;

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await widget.profileService.upsertProfile(
        AppUserProfile(
          uid: widget.uid,
          email: widget.email,
          displayName: _nameController.text.trim(),
          role: _role,
          linkedStudentIds: const [],
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Kurulumu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Ad Soyad'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<AppUserRole>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: const [
                DropdownMenuItem(
                  value: AppUserRole.student,
                  child: Text('Ogrenci'),
                ),
                DropdownMenuItem(
                  value: AppUserRole.parent,
                  child: Text('Veli'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _role = value);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _saveProfile,
              child: const Text('Profili Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleHomePage extends StatelessWidget {
  const RoleHomePage({
    super.key,
    required this.profile,
    required this.authService,
  });

  final AppUserProfile profile;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hosgeldin, ${profile.displayName.isEmpty ? profile.email : profile.displayName}'),
        actions: [
          IconButton(
            onPressed: authService.signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Cikis',
          ),
        ],
      ),
      body: profile.role == AppUserRole.parent
          ? ParentHome(profile: profile)
          : StudentHome(profile: profile),
    );
  }
}

class ParentHome extends StatelessWidget {
  const ParentHome({super.key, required this.profile});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Veli paneli altyapisi hazir. Sonraki adimda ogrenci baglama ve program ekranlari eklenecek.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Text('Bagli ogrenci sayisi: ${profile.linkedStudentIds.length}'),
        ],
      ),
    );
  }
}

class StudentHome extends StatefulWidget {
  const StudentHome({super.key, required this.profile});

  final AppUserProfile profile;

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final TeacherNoteService _noteService = TeacherNoteService();
  static const _weekDays = ['pzt', 'sal', 'car', 'per', 'cum', 'cmt', 'paz'];
  String _dayKey = 'pzt';

  @override
  Widget build(BuildContext context) {
    final studentId = widget.profile.uid;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ogrenci paneli'),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: _dayKey,
            items: _weekDays
                .map((d) => DropdownMenuItem(value: d, child: Text(d.toUpperCase())))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _dayKey = value);
            },
          ),
          const SizedBox(height: 10),
          StreamBuilder<String>(
            stream: _noteService.watchTeacherNote(
              studentId: studentId,
              dayKey: _dayKey,
            ),
            builder: (context, snapshot) {
              final note = (snapshot.data ?? '').trim();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    note.isEmpty
                        ? 'Bu gun icin ogretmen notu yok.'
                        : 'Ogretmen Notu: $note',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
