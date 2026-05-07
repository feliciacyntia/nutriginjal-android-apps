import 'package:flutter_test/flutter_test.dart';
import 'package:nutriginjal/data/models/nutrisi_model.dart';

void main() {
  group('NutrisiItem Model Test', () {
    test('toRagDescription should format string correctly for AI context', () {
      final item = NutrisiItem(
        makanan: "Apel",
        kelompok: "Buah",
        energi: 52,
        protein: 0.3,
        natrium: 1,
        kalium: 107,
        fosfor: 11,
        lemak: 0.2,
        karbohidrat: 14,
      );

      final description = item.toRagDescription();

      expect(description, contains("Apel (Buah)"));
      expect(description, contains("Energi 52.0 kkal"));
      expect(description, contains("Protein 0.3g"));
      expect(description, contains("Natrium 1.0mg"));
      expect(description, contains("Kalium 107.0mg"));
      expect(description, contains("Fosfor 11.0mg"));
    });
  });
}
