import 'package:flutter/material.dart';
import 'package:nutriginjal/data/models/ckd_input_model.dart';

class PredictionResultCard extends StatelessWidget {
  final PredictionResult result;
  final VoidCallback onReset;

  const PredictionResultCard({
    super.key,
    required this.result,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor = result.isCkd ? Colors.red : Colors.green;
    final Color bgColor = result.isCkd ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);

    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: mainColor.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.science, color: mainColor),
                const SizedBox(width: 8),
                const Text(
                  "Hasil Prediksi CKD",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              result.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.isCkd 
                ? "⚠️ Pasien kemungkinan menderita Chronic Kidney Disease"
                : "✅ Pasien kemungkinan besar sehat (Non-CKD)",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Reset Form"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
