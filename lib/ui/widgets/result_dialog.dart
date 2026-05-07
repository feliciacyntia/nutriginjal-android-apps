import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final bool isRisk;
  final double probability;
  const ResultDialog({required this.isRisk, required this.probability, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(isRisk ? 'Beresiko CKD' : 'Tidak Beresiko'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRisk ? Icons.warning : Icons.check_circle,
            color: isRisk ? Colors.red : Colors.green,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'Probabilitas: ${(probability * 100).toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Tutup'),
        ),
      ],
    );
  }
}
