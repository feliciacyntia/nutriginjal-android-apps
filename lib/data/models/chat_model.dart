class ChatSession {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? 'Percakapan Baru',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ChatMessage {
  final String id;
  final String sessionId;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sessionId: json['session_id'],
      role: json['role'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isUser => role == 'user';
}
