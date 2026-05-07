import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutriginjal/data/models/chat_model.dart';

class ChatService {
  SupabaseClient get _supabase => Supabase.instance.client;

  // ─── Get All Sessions ────────────────────────────────
  Future<List<ChatSession>> getChatSessions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('chat_sessions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ChatSession.fromJson(json))
        .toList();
  }

  // ─── Create Session ──────────────────────────────────
  Future<ChatSession> createChatSession(String title) async {
    final userId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('chat_sessions')
        .insert({
      'user_id': userId,
      'title': title,
    })
        .select()
        .single();

    return ChatSession.fromJson(response);
  }

  // ─── Delete Session (+ semua messages di dalamnya) ───
  Future<void> deleteChatSession(String sessionId) async {
    // Hapus semua pesan dulu (jika tidak pakai CASCADE di Supabase)
    await _supabase
        .from('messages')
        .delete()
        .eq('session_id', sessionId);

    // Baru hapus sesinya
    await _supabase
        .from('chat_sessions')
        .delete()
        .eq('id', sessionId);
  }

  // ─── Delete All Sessions milik user ─────────────────
  Future<void> deleteAllChatSessions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Ambil semua session ID milik user ini
    final sessions = await _supabase
        .from('chat_sessions')
        .select('id')
        .eq('user_id', userId);

    final sessionIds = (sessions as List)
        .map((s) => s['id'] as String)
        .toList();

    if (sessionIds.isEmpty) return;

    // Hapus semua messages dari session-session tersebut
    await _supabase
        .from('messages')
        .delete()
        .inFilter('session_id', sessionIds);

    // Hapus semua sesi
    await _supabase
        .from('chat_sessions')
        .delete()
        .eq('user_id', userId);
  }

  // ─── Stream Messages (realtime) ─────────────────────
  Stream<List<ChatMessage>> getMessagesStream(String sessionId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .order('created_at', ascending: true)
        .map((data) =>
        data.map((json) => ChatMessage.fromJson(json)).toList());
  }

  // ─── Send Message ────────────────────────────────────
  Future<void> sendMessage({
    required String sessionId,
    required String content,
    String role = 'user',
  }) async {
    await _supabase.from('messages').insert({
      'session_id': sessionId,
      'content': content,
      'role': role,
    });
  }

  // ─── Get Messages as Future (untuk Gemini History) ───
  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ChatMessage.fromJson(json))
        .toList();
  }

  // ─── Update Session Title ────────────────────────────
  Future<void> updateSessionTitle({
    required String sessionId,
    required String newTitle,
  }) async {
    await _supabase
        .from('chat_sessions')
        .update({'title': newTitle})
        .eq('id', sessionId);
  }
}