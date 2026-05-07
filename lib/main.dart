import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutriginjal/core/constants/supabase_config.dart';
import 'package:nutriginjal/services/profile_service.dart';
import 'package:nutriginjal/data/models/profile_model.dart';
import 'package:nutriginjal/ui/pages/auth/login_page.dart';
import 'package:nutriginjal/ui/pages/admin/admin_dashboard_page.dart';
import 'package:nutriginjal/ui/pages/doctor/doctor_home_page.dart';
import 'package:nutriginjal/ui/pages/user/chat_page.dart';
import 'package:nutriginjal/ui/pages/user/user_chat_home_screen.dart';
import 'package:nutriginjal/ui/pages/user/chat_history_page.dart';
import 'package:nutriginjal/ui/pages/user/profile_page.dart';
import 'package:nutriginjal/ui/pages/ckd_screening_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase sebelum runApp
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    headers: {'ngrok-skip-browser-warning': 'true'},
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutriginjal RBAC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6FBFF),
      ),
      home: const RootNavigator(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/admin': (context) => const AdminDashboardPage(),
        '/doctor': (context) => const DoctorHomePage(),

        '/chat': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?;
          return ChatPage(
            sessionId: args?['sessionId'],
            title: args?['title'] ?? 'Chat',
          );
        },

        '/edukasi-chat': (context) => const ChatPage(
          title: 'Edukasi & Konsultasi Gizi',
          showWelcome: true,
          suggestedPrompts: [
            'Apakah tempe aman untuk ginjal?',
            'Berapa batas garam per hari?',
            'Menu sehat untuk CKD?',
          ],
        ),

        '/chat-history': (context) => const ChatHistoryPage(),
        '/profile': (context) => const ProfilePage(),
        '/ckd-screening': (context) => const CKDScreeningPage(),
      },
    );
  }
}

class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  final ProfileService _profileService = ProfileService();
  late Future<Profile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Profile?> _loadProfile() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return null;
      return await _profileService.getMyProfile();
    } catch (e) {
      debugPrint('Profile load error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek session dulu — kalau belum login langsung ke LoginPage
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return const LoginPage();

    return FutureBuilder<Profile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF4FC3F7),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        // Error atau profile null → ke login
        if (snapshot.hasError || snapshot.data == null) {
          return const LoginPage();
        }

        final profile = snapshot.data!;

        switch (profile.role) {
          case 'admin':
            return const AdminDashboardPage();
          case 'doctor':
            return const DoctorHomePage();
          case 'user':
          default:
            return const UserChatHomeScreen();
        }
      },
    );
  }
}