import 'package:flutter_test/flutter_test.dart';
import 'package:nutriginjal/data/models/ckd_input_model.dart';
import 'package:nutriginjal/services/api_service.dart';

void main() {
  group('ApiService CKD Prediction Test', () {
    test('predictCKD should return a valid PredictionResult when given dummy input', () async {
      // 1. Create dummy input data
      final dummyForm = CkdInputForm();
      dummyForm.age = "45";
      dummyForm.bp = "80";
      dummyForm.sg = 1.020;
      dummyForm.al = 1;
      dummyForm.su = 0;
      dummyForm.rbc = 0; // Normal
      dummyForm.pc = 0;  // Normal
      dummyForm.pcc = 0; // Not Present
      dummyForm.ba = 0;  // Not Present
      dummyForm.bgr = "120";
      dummyForm.bu = "40";
      dummyForm.sc = "1.2";
      dummyForm.sod = "135";
      dummyForm.pot = "4.5";
      dummyForm.hemo = "14.5";
      dummyForm.pcv = "40";
      dummyForm.wbcc = "8000";
      dummyForm.rbcc = "5.0";
      dummyForm.htn = 0;   // No
      dummyForm.dm = 0;    // No
      dummyForm.cad = 0;   // No
      dummyForm.appet = 0; // Good
      dummyForm.pe = 0;    // No
      dummyForm.ane = 0;   // No

      // 2. Ensure form is valid
      expect(dummyForm.isFormValid, isTrue);

      // 3. Call the API (Integration test style)
      // Note: This requires internet connection and the HF Space to be active.
      try {
        final result = await ApiService.predictCKD(dummyForm);

        // 4. Validate output
        print("Prediction Result: ${result.label}");
        print("Is CKD: ${result.isCkd}");
        print("Risk Level: ${result.riskLevel}");

        expect(result, isA<PredictionResult>());
        expect(result.label, isNotEmpty);
        expect(result.riskLevel, anyOf(["HIGH", "LOW"]));
      } catch (e) {
        fail("API call failed with error: $e");
      }
    });
  });
}
