import 'package:flutter_test/flutter_test.dart';
import 'package:nutriginjal/data/models/profile_model.dart';

void main() {
  group('Profile Model Test', () {
    test('Should create Profile from JSON correctly', () {
      final json = {
        'id': 'user-1',
        'full_name': 'Ahmad Fauzan',
        'email': 'fauzan@example.com',
        'role': 'patient',
        'avatar_url': 'https://example.com/avatar.png'
      };

      final profile = Profile.fromJson(json);

      expect(profile.id, 'user-1');
      expect(profile.fullName, 'Ahmad Fauzan');
      expect(profile.email, 'fauzan@example.com');
      expect(profile.role, 'patient');
      expect(profile.avatarUrl, 'https://example.com/avatar.png');
    });

    test('Should provide default values for missing fields', () {
      final json = {
        'id': 'user-2',
      };

      final profile = Profile.fromJson(json);

      expect(profile.fullName, 'User');
      expect(profile.email, '');
      expect(profile.role, 'user');
      expect(profile.avatarUrl, isNull);
    });
  });
}
