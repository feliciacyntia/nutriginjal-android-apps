import 'package:flutter_test/flutter_test.dart';
import 'package:nutriginjal/data/models/chat_model.dart';

void main() {
  group('ChatSession Model Test', () {
    test('Should create ChatSession from JSON correctly', () {
      final json = {
        'id': 'session-1',
        'user_id': 'user-123',
        'title': 'Konsultasi Nutrisi',
        'created_at': '2024-05-01T10:00:00Z'
      };

      final session = ChatSession.fromJson(json);

      expect(session.id, 'session-1');
      expect(session.userId, 'user-123');
      expect(session.title, 'Konsultasi Nutrisi');
      expect(session.createdAt, isA<DateTime>());
    });

    test('Should use default title if null in JSON', () {
      final json = {
        'id': 'session-2',
        'user_id': 'user-123',
        'created_at': '2024-05-01T10:00:00Z'
      };

      final session = ChatSession.fromJson(json);
      expect(session.title, 'Percakapan Baru');
    });
  });

  group('ChatMessage Model Test', () {
    test('Should create ChatMessage from JSON correctly', () {
      final json = {
        'id': 'msg-1',
        'session_id': 'session-1',
        'role': 'user',
        'content': 'Apa itu CKD?',
        'created_at': '2024-05-01T10:01:00Z'
      };

      final message = ChatMessage.fromJson(json);

      expect(message.id, 'msg-1');
      expect(message.content, 'Apa itu CKD?');
      expect(message.role, 'user');
      expect(message.isUser, isTrue);
    });

    test('isUser should be false for assistant role', () {
      final message = ChatMessage(
        id: 'msg-2',
        sessionId: 'session-1',
        role: 'assistant',
        content: 'CKD adalah...',
        createdAt: DateTime.now()
      );

      expect(message.isUser, isFalse);
    });
  });
}
