class LabResult {
  final String id;
  final String? doctorId;
  final String? patientId;
  final String? patientName;
  final Map<String, dynamic> labData;
  final Map<String, dynamic>? predictionResult;
  final DateTime createdAt;

  LabResult({
    required this.id,
    this.doctorId,
    this.patientId,
    this.patientName,
    required this.labData,
    this.predictionResult,
    required this.createdAt,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      id: json['id']?.toString() ?? '',
      doctorId: json['doctor_id'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      labData: json['lab_data'] is Map ? Map<String, dynamic>.from(json['lab_data']) : {},
      predictionResult: json['prediction_result'] != null ? Map<String, dynamic>.from(json['prediction_result']) : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}
