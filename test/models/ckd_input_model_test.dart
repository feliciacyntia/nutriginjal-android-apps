import 'package:flutter_test/flutter_test.dart';
import 'package:nutriginjal/data/models/ckd_input_model.dart';

void main() {
  group('CkdInputForm Validation and Mapping Tests', () {
    test('isFormValid should return false when numeric fields are empty', () {
      final form = CkdInputForm();
      expect(form.isFormValid, isFalse);
    });

    test('isFormValid should return true when all required fields are filled with numbers', () {
      final form = CkdInputForm()
        ..age = "45"
        ..bp = "80"
        ..bgr = "120"
        ..bu = "36"
        ..sc = "1.2"
        ..sod = "135"
        ..pot = "4.5"
        ..hemo = "15"
        ..pcv = "44"
        ..wbcc = "7800"
        ..rbcc = "5.2";
      
      expect(form.isFormValid, isTrue);
    });

    test('isFormValid should return false if one numeric field is invalid', () {
      final form = CkdInputForm()
        ..age = "45"
        ..bp = "abc" // Invalid
        ..bgr = "120"
        ..bu = "36"
        ..sc = "1.2"
        ..sod = "135"
        ..pot = "4.5"
        ..hemo = "15"
        ..pcv = "44"
        ..wbcc = "7800"
        ..rbcc = "5.2";
      
      expect(form.isFormValid, isFalse);
    });

    test('toModelInput should correctly map fields to double values', () {
      final form = CkdInputForm()
        ..age = "50"
        ..bp = "90"
        ..al = 2.0
        ..htn = 1.0;

      final inputMap = form.toModelInput();

      expect(inputMap['age'], 50.0);
      expect(inputMap['bp'], 90.0);
      expect(inputMap['al'], 2.0);
      expect(inputMap['htn'], 1.0);
      // Default value check
      expect(inputMap['su'], 0.0);
    });
  });

  group('PredictionResult Model Test', () {
    test('PredictionResult should hold values correctly', () {
      final result = PredictionResult(
        label: "CKD - Berisiko",
        isCkd: true,
        riskLevel: "HIGH",
        confidence: 0.95
      );

      expect(result.label, "CKD - Berisiko");
      expect(result.isCkd, isTrue);
      expect(result.riskLevel, "HIGH");
      expect(result.confidence, 0.95);
    });
  });
}
