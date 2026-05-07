import 'package:flutter_test/flutter_test.dart';
import 'package:nutriginjal/data/models/profile_model.dart';

void main() {
  group('Navigation Logic (Role Based) Test', () {
    test('Admin should have admin role access', () {
      final adminProfile = Profile(
        id: '1',
        fullName: 'Admin User',
        email: 'admin@test.com',
        role: 'admin',
      );

      expect(adminProfile.role, equals('admin'));
      expect(adminProfile.role == 'admin', isTrue);
    });

    test('Doctor should have doctor role access', () {
      final doctorProfile = Profile(
        id: '2',
        fullName: 'Dr. Strange',
        email: 'doctor@test.com',
        role: 'doctor',
      );

      expect(doctorProfile.role, equals('doctor'));
      expect(doctorProfile.role == 'user', isFalse);
    });

    test('Default user should have user role', () {
      final userProfile = Profile(
        id: '3',
        fullName: 'Common User',
        email: 'user@test.com',
        role: 'user',
      );

      expect(userProfile.role, equals('user'));
    });
  });
}
