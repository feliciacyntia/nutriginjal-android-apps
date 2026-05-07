import 'package:flutter_test/flutter_test.dart';
import 'package:nutriginjal/data/models/lab_model.dart';

void main() {
  group('LabResult Model Test', () {
    test('Should create LabResult object from JSON correctly', () {
      final json = {
        'id': 'lab-123',
        'doctor_id': 'doc-1',
        'patient_id': 'pat-1',
        'lab_data': {'creatinine': 1.2, 'egfr': 85},
        'prediction_result': {'risk': 'low'},
        'created_at': '2024-05-01T12:00:00Z'
      };

      final result = LabResult.fromJson(json);

      expect(result.id, 'lab-123');
      expect(result.labData['creatinine'], 1.2);
      expect(result.predictionResult?['risk'], 'low');
    });
  });
}
