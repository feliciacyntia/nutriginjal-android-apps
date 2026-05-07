class LabResult {
  final String id;
  final String? doctorId;
  final String? patientId;
  final Map<String, dynamic> labData;
  final Map<String, dynamic>? predictionResult;
  final DateTime createdAt;

  LabResult({
    required this.id,
    this.doctorId,
    this.patientId,
    required this.labData,
    this.predictionResult,
    required this.createdAt,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      id: json['id'],
      doctorId: json['doctor_id'],
      patientId: json['patient_id'],
      labData: json['lab_data'] as Map<String, dynamic>,
      predictionResult: json['prediction_result'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
