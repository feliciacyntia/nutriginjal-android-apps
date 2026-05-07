import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutriginjal/data/models/profile_model.dart';

class ProfileService {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<Profile?> getMyProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(data);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // Admin only: Get all profiles
  Future<List<Profile>> getAllProfiles() async {
    try {
      final List<dynamic> data = await _supabase.from('profiles').select();
      return data.map((json) => Profile.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching all profiles: $e');
      return [];
    }
  }

  Future<void> updateProfile({required String fullName, String? avatarUrl}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('profiles').update({
      'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    }).eq('id', userId);
  }
}
