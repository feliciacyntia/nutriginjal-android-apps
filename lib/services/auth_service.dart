import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Sign in with Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // Web Client ID dari Firebase/Google Cloud Console
      const webClientId = '1066674845758-b35tal0r9fo4lri1fvts5g4609bnvjr1.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'ID Token tidak ditemukan dari Google.';
      }

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      print('DEBUG AUTH ERROR: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // 1. Sign out dari Supabase
      await _supabase.auth.signOut();
      
      // 2. Sign out dari Google (agar muncul pilihan akun lagi saat login berikutnya)
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        await googleSignIn.disconnect(); // Memutuskan koneksi sepenuhnya
      }
    } catch (e) {
      print('DEBUG SIGNOUT ERROR: $e');
    }
  }

  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;
}
