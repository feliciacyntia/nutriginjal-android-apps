import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:nutriginjal/data/models/ckd_input_model.dart';

class ApiService {
  static const String _baseUrl = "https://kauzan25-nutrisnaps-api.hf.space/gradio_api/call/predict_kidney";

  /// Fungsi utama untuk menjalankan prediksi CKD menggunakan Gradio API
  static Future<PredictionResult> predictCKD(CkdInputForm form) async {
    try {
      // Step 1: Submit Job
      final submitResponse = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "data": [form.toModelInput()]
        }),
      );

      if (submitResponse.statusCode != 200) {
        throw Exception("Gagal mengirim data ke server (Status: ${submitResponse.statusCode})");
      }

      final eventId = jsonDecode(submitResponse.body)['event_id'];
      if (eventId == null) throw Exception("Event ID tidak ditemukan");

      // Step 2: Poll Result
      return await _pollResult(eventId);
    } catch (e) {
      print("API Error: $e");
      rethrow;
    }
  }

  static Future<PredictionResult> _pollResult(String eventId) async {
    const int maxRetries = 15;
    const Duration delay = Duration(seconds: 1);

    for (int i = 0; i < maxRetries; i++) {
      final response = await http.get(Uri.parse("$_baseUrl/$eventId"));
      
      if (response.statusCode == 200) {
        final body = response.body;
        
        // Gradio SSE format usually contains "event: complete" followed by "data: [...]"
        if (body.contains("event: complete") && body.contains("prediction_class")) {
          // Extract JSON from the "data:" line
          final lines = body.split('\n');
          for (var line in lines) {
            if (line.startsWith("data: ")) {
              final jsonStr = line.substring(6).trim();
              final List<dynamic> results = jsonDecode(jsonStr);
              final result = results[0]; // {status: success, prediction_class: 0}
              
              final int predictionClass = result['prediction_class'];
              final bool isCkd = predictionClass == 1;
              
              return PredictionResult(
                label: isCkd ? "CKD — Berisiko" : "Normal — Tidak Berisiko",
                isCkd: isCkd,
                riskLevel: isCkd ? "HIGH" : "LOW",
                confidence: 1.0, // Model ini tidak mengembalikan confidence secara eksplisit
              );
            }
          }
        }
      }
      await Future.delayed(delay);
    }
    throw Exception("Timeout: Server tidak merespon hasil tepat waktu");
  }

  /// Fungsi lama untuk kompatibilitas (akan menggunakan logika default)
  static Future<RiskResult> analyzeCKDRisk({
    required int age,
    required double creatinine,
    required double urea,
    required double gfr,
    required double bmi,
  }) async {
    // Simulasi atau mapping sederhana ke model baru jika memungkinkan, 
    // atau sekadar wrapper untuk kompatibilitas UI lama.
    // Di sini kita kembalikan hasil dummy karena model 24 parameter butuh input lengkap.
    bool isRisk = gfr < 60 || creatinine > 1.2;
    return RiskResult(
      isRisk: isRisk,
      probability: isRisk ? 0.85 : 0.15,
    );
  }
}

class RiskResult {
  final bool isRisk;
  final double probability;
  RiskResult({required this.isRisk, required this.probability});
}
