import 'package:flutter/material.dart';
import 'package:nutriginjal/ui/widgets/stepper_form.dart';
import 'package:nutriginjal/ui/widgets/result_dialog.dart';
import 'package:nutriginjal/services/api_service.dart';

class CKDScreeningPage extends StatefulWidget {
  const CKDScreeningPage({super.key});

  @override
  State<CKDScreeningPage> createState() => _CKDScreeningPageState();
}

class _CKDScreeningPageState extends State<CKDScreeningPage> {
  int currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController ageController = TextEditingController();
  final TextEditingController creatinineController = TextEditingController();
  final TextEditingController ureaController = TextEditingController();
  final TextEditingController gfrController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();

  @override
  void dispose() {
    ageController.dispose();
    creatinineController.dispose();
    ureaController.dispose();
    gfrController.dispose();
    bmiController.dispose();
    super.dispose();
  }

  void _analyzeRisk() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final age = int.parse(ageController.text);
      final creatinine = double.parse(creatinineController.text);
      final urea = double.parse(ureaController.text);
      final gfr = double.parse(gfrController.text);
      final bmi = double.parse(bmiController.text);

      final result = await ApiService.analyzeCKDRisk(
        age: age,
        creatinine: creatinine,
        urea: urea,
        gfr: gfr,
        bmi: bmi,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (_) => ResultDialog(
          isRisk: result.isRisk,
          probability: result.probability,
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Skrining Risiko CKD", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StepperForm(
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 2) {
            setState(() => currentStep++);
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() => currentStep--);
          }
        },
        onAnalyze: _analyzeRisk,
        formKey: _formKey,
        ageController: ageController,
        creatinineController: creatinineController,
        ureaController: ureaController,
        gfrController: gfrController,
        bmiController: bmiController,
      ),
    );
  }
}
