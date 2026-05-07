import 'package:flutter/material.dart';

class StepperForm extends StatefulWidget {
  final int currentStep;
  final VoidCallback onStepContinue;
  final VoidCallback onStepCancel;
  final VoidCallback onAnalyze;
  final GlobalKey<FormState> formKey;

  final TextEditingController ageController;
  final TextEditingController creatinineController;
  final TextEditingController ureaController;
  final TextEditingController gfrController;
  final TextEditingController bmiController;

  const StepperForm({
    required this.currentStep,
    required this.onStepContinue,
    required this.onStepCancel,
    required this.onAnalyze,
    required this.formKey,
    required this.ageController,
    required this.creatinineController,
    required this.ureaController,
    required this.gfrController,
    required this.bmiController,
    super.key,
  });

  @override
  State<StepperForm> createState() => _StepperFormState();
}

class _StepperFormState extends State<StepperForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Stepper(
        type: StepperType.vertical,
        currentStep: widget.currentStep,
        onStepContinue: widget.onStepContinue,
        onStepCancel: widget.onStepCancel,
        steps: [
          Step(
            title: const Text('Data Diri', style: TextStyle(fontWeight: FontWeight.bold)),
            isActive: widget.currentStep >= 0,
            state: widget.currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Usia (Tahun)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  controller: widget.ageController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Usia wajib diisi';
                    final n = int.tryParse(value);
                    if (n == null || n <= 0) return 'Usia tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'BMI',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monitor_weight),
                  ),
                  keyboardType: TextInputType.number,
                  controller: widget.bmiController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'BMI wajib diisi';
                    final n = double.tryParse(value);
                    if (n == null || n <= 0) return 'BMI tidak valid';
                    return null;
                  },
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Hasil Lab Darah', style: TextStyle(fontWeight: FontWeight.bold)),
            isActive: widget.currentStep >= 1,
            state: widget.currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Kreatinin (mg/dL)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.science),
                  ),
                  keyboardType: TextInputType.number,
                  controller: widget.creatinineController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Kreatinin wajib diisi';
                    final n = double.tryParse(value);
                    if (n == null || n <= 0) return 'Nilai tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Urea (mg/dL)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.biotech),
                  ),
                  keyboardType: TextInputType.number,
                  controller: widget.ureaController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Urea wajib diisi';
                    final n = double.tryParse(value);
                    if (n == null || n <= 0) return 'Nilai tidak valid';
                    return null;
                  },
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Hasil Lab Urine', style: TextStyle(fontWeight: FontWeight.bold)),
            isActive: widget.currentStep >= 2,
            state: widget.currentStep == 2 ? StepState.indexed : StepState.indexed,
            content: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'GFR (mL/min/1.73m²)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.water_drop),
                  ),
                  keyboardType: TextInputType.number,
                  controller: widget.gfrController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'GFR wajib diisi';
                    final n = double.tryParse(value);
                    if (n == null || n <= 0) return 'Nilai tidak valid';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
        controlsBuilder: (context, details) {
          final isLast = widget.currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                if (!isLast)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Lanjut'),
                    ),
                  ),
                if (isLast)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onAnalyze,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Simpan & Analisis Risiko'),
                    ),
                  ),
                if (widget.currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Kembali'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
