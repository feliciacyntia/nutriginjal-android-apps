import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutriginjal/data/models/lab_model.dart';

class LabService {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> saveLabResult({
    required String patientId,
    required Map<String, dynamic> labData,
    Map<String, dynamic>? predictionResult,
  }) async {
    final doctorId = _supabase.auth.currentUser?.id;

    await _supabase.from('lab_results').insert({
      'doctor_id': doctorId,
      'patient_id': patientId,
      'lab_data': labData,
      'prediction_result': predictionResult,
    });
  }

  Future<List<LabResult>> getPatientLabResults(String patientId) async {
    final response = await _supabase
        .from('lab_results')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => LabResult.fromJson(json)).toList();
  }
}
