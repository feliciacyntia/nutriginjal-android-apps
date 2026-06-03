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

  Future<void> deleteLabResult(String id) async {
    try {
      print("DEBUG: Mencoba menghapus riwayat ID: $id");
      final response = await _supabase
          .from('lab_results')
          .delete()
          .eq('id', id)
          .select(); // .select() mengembalikan data yang baru saja dihapus
      
      final deletedRows = response as List;
      if (deletedRows.isEmpty) {
        print("DEBUG WARNING: Tidak ada baris yang terhapus! Cek apakah RLS Policy 'DELETE' sudah dibuat di Supabase.");
        throw Exception("Izin hapus ditolak oleh database (RLS Policy)");
      } else {
        print("DEBUG SUCCESS: Berhasil menghapus ${deletedRows.length} baris.");
      }
    } catch (e) {
      print("DEBUG ERROR: Gagal menghapus: $e");
      rethrow;
    }
  }

  Future<List<LabResult>> getPatientLabResults(String patientId) async {
    final response = await _supabase
        .from('lab_results')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => LabResult.fromJson(json)).toList();
  }

  Future<List<LabResult>> getDoctorLabHistory() async {
    final doctorId = _supabase.auth.currentUser?.id;
    if (doctorId == null) return [];

    try {
      final response = await _supabase
          .from('lab_results')
          .select('*, profiles!patient_id(full_name)') // Menggunakan bang (!) untuk mempertegas relasi ke patient_id
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);
      
      return (response as List).map((json) {
        final data = Map<String, dynamic>.from(json);
        // Ambil nama dari join profiles
        if (json['profiles'] != null) {
          data['patient_name'] = json['profiles']['full_name'];
        }
        return LabResult.fromJson(data);
      }).toList();
    } catch (e) {
      print('DEBUG: Error fetching lab history: $e');
      return [];
    }
  }
}
