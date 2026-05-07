import 'package:flutter/material.dart';
import 'package:nutriginjal/services/lab_service.dart';
import 'package:nutriginjal/services/api_service.dart';
import 'package:nutriginjal/ui/widgets/stepper_form.dart';

class InputLabPage extends StatefulWidget {
  final String patientId;
  const InputLabPage({super.key, required this.patientId});

  @override
  State<InputLabPage> createState() => _InputLabPageState();
}

class _InputLabPageState extends State<InputLabPage> {
  int _currentStep = 0;
  final LabService _labService = LabService();
  final _formKey = GlobalKey<FormState>();
  
  final _ageController = TextEditingController();
  final _creatinineController = TextEditingController();
  final _ureaController = TextEditingController();
  final _gfrController = TextEditingController();
  final _bmiController = TextEditingController();

  void _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final labData = {
        'age': int.parse(_ageController.text),
        'creatinine': double.parse(_creatinineController.text),
        'urea': double.parse(_ureaController.text),
        'gfr': double.parse(_gfrController.text),
        'bmi': double.parse(_bmiController.text),
      };

      // Call ML API
      final prediction = await ApiService.analyzeCKDRisk(
        age: labData['age'] as int,
        creatinine: labData['creatinine'] as double,
        urea: labData['urea'] as double,
        gfr: labData['gfr'] as double,
        bmi: labData['bmi'] as double,
      );

      final predictionResult = {
        'isRisk': prediction.isRisk,
        'probability': prediction.probability,
        'stage': _determineStage(labData['gfr'] as double),
      };

      await _labService.saveLabResult(
        patientId: widget.patientId,
        labData: labData,
        predictionResult: predictionResult,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showResultDialog(predictionResult);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _determineStage(double gfr) {
    if (gfr >= 90) return 'Stadium 1';
    if (gfr >= 60) return 'Stadium 2';
    if (gfr >= 30) return 'Stadium 3';
    if (gfr >= 15) return 'Stadium 4';
    return 'Stadium 5';
  }

  void _showResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hasil Analisis Risiko'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risiko CKD: ${result['isRisk'] ? "Tinggi" : "Rendah"}'),
            Text('Probabilitas: ${(result['probability'] * 100).toStringAsFixed(1)}%'),
            Text('Estimasi: ${result['stage']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to dashboard
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Input Hasil Lab', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StepperForm(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        onAnalyze: _saveData,
        formKey: _formKey,
        ageController: _ageController,
        creatinineController: _creatinineController,
        ureaController: _ureaController,
        gfrController: _gfrController,
        bmiController: _bmiController,
      ),
    );
  }
}
