import 'package:flutter/material.dart';
import 'package:nutriginjal/data/models/ckd_input_model.dart';
import 'package:nutriginjal/services/api_service.dart';
import 'package:nutriginjal/services/lab_service.dart';
import 'package:nutriginjal/ui/pages/doctor/components/lab_input_widgets.dart';
import 'package:nutriginjal/ui/pages/doctor/components/prediction_result_card.dart';

class PredictionScreen extends StatefulWidget {
  final String patientId;
  const PredictionScreen({super.key, required this.patientId});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final LabService _labService = LabService();
  CkdInputForm _form = CkdInputForm();
  bool _isLoading = false;
  PredictionResult? _result;
  String? _error;

  void _runPrediction() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await ApiService.predictCKD(_form);
      
      // Save to Supabase
      await _labService.saveLabResult(
        patientId: widget.patientId,
        labData: _form.toModelInput(),
        predictionResult: {
          'label': result.label,
          'isCkd': result.isCkd,
          'risk_level': result.riskLevel,
          'stage': result.label.split(' ').last, // Assuming label format like "Stage 1"
        },
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Input Data Lab Pasien", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCategoryGeneral(),
              _buildCategoryUrinalysis(),
              _buildCategoryBlood(),
              _buildCategoryClinical(),
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
          if (_isLoading || _result != null || _error != null)
            _buildOverlayFeedback(),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildCategoryGeneral() {
    return LabCategoryCard(
      title: "Informasi Umum",
      icon: Icons.person_outline,
      color: const Color(0xFF2563EB),
      children: [
        LabNumberInput(
          label: "Usia Pasien",
          value: _form.age,
          unit: "tahun",
          normalRange: "0 - 100",
          onValueChange: (v) => _form.age = v,
        ),
        LabNumberInput(
          label: "Tekanan Darah",
          value: _form.bp,
          unit: "mm/Hg",
          normalRange: "60 - 180",
          onValueChange: (v) => _form.bp = v,
        ),
      ],
    );
  }

  Widget _buildCategoryUrinalysis() {
    return LabCategoryCard(
      title: "Hasil Urinalisis",
      icon: Icons.opacity,
      color: const Color(0xFFD97706),
      children: [
        LabDropdownInput(
          label: "Specific Gravity",
          value: _form.sg,
          options: const [
            MapEntry(1.005, "1.005"),
            MapEntry(1.010, "1.010"),
            MapEntry(1.015, "1.015"),
            MapEntry(1.020, "1.020"),
            MapEntry(1.025, "1.025"),
          ],
          onValueChange: (v) => setState(() => _form.sg = v),
        ),
        LabDropdownInput(
          label: "Albumin",
          value: _form.al,
          options: const [
            MapEntry(0, "0 (None)"),
            MapEntry(1, "1 (Ringan)"),
            MapEntry(2, "2 (Sedang)"),
            MapEntry(3, "3 (Cukup)"),
            MapEntry(4, "4 (Tinggi)"),
            MapEntry(5, "5 (Sangat Tinggi)"),
          ],
          onValueChange: (v) => setState(() => _form.al = v),
        ),
        LabDropdownInput(
          label: "Sugar",
          value: _form.su,
          options: const [
            MapEntry(0, "0 (None)"),
            MapEntry(1, "1"),
            MapEntry(2, "2"),
            MapEntry(3, "3"),
            MapEntry(4, "4"),
            MapEntry(5, "5"),
          ],
          onValueChange: (v) => setState(() => _form.su = v),
        ),
        BinaryToggleChip(
          label: "Red Blood Cells (Urin)",
          selectedValue: _form.rbc,
          optionFalseLabel: "Normal",
          optionTrueLabel: "Abnormal",
          onValueChange: (v) => setState(() => _form.rbc = v),
        ),
        BinaryToggleChip(
          label: "Pus Cells",
          selectedValue: _form.pc,
          optionFalseLabel: "Normal",
          optionTrueLabel: "Abnormal",
          onValueChange: (v) => setState(() => _form.pc = v),
        ),
        BinaryToggleChip(
          label: "Pus Cell Clumps",
          selectedValue: _form.pcc,
          optionFalseLabel: "Not Present",
          optionTrueLabel: "Present",
          onValueChange: (v) => setState(() => _form.pcc = v),
        ),
        BinaryToggleChip(
          label: "Bacteria",
          selectedValue: _form.ba,
          optionFalseLabel: "Not Present",
          optionTrueLabel: "Present",
          onValueChange: (v) => setState(() => _form.ba = v),
        ),
      ],
    );
  }

  Widget _buildCategoryBlood() {
    return LabCategoryCard(
      title: "Hasil Darah (Blood Test)",
      icon: Icons.bloodtype_outlined,
      color: const Color(0xFFDC2626),
      children: [
        LabNumberInput(
          label: "Blood Glucose Random",
          value: _form.bgr,
          unit: "mgs/dl",
          normalRange: "70 - 200",
          onValueChange: (v) => _form.bgr = v,
        ),
        LabNumberInput(
          label: "Blood Urea",
          value: _form.bu,
          unit: "mgs/dl",
          normalRange: "10 - 150",
          onValueChange: (v) => _form.bu = v,
        ),
        LabNumberInput(
          label: "Serum Creatinine",
          value: _form.sc,
          unit: "mgs/dl",
          normalRange: "0.5 - 15",
          onValueChange: (v) => _form.sc = v,
        ),
        LabNumberInput(
          label: "Sodium",
          value: _form.sod,
          unit: "mEq/L",
          normalRange: "111 - 163",
          onValueChange: (v) => _form.sod = v,
        ),
        LabNumberInput(
          label: "Potassium",
          value: _form.pot,
          unit: "mEq/L",
          normalRange: "2.5 - 6.0",
          onValueChange: (v) => _form.pot = v,
        ),
        LabNumberInput(
          label: "Hemoglobin",
          value: _form.hemo,
          unit: "gms",
          normalRange: "3.1 - 17.8",
          onValueChange: (v) => _form.hemo = v,
        ),
        LabNumberInput(
          label: "Packed Cell Volume",
          value: _form.pcv,
          unit: "%",
          normalRange: "9 - 54",
          onValueChange: (v) => _form.pcv = v,
        ),
        LabNumberInput(
          label: "White Blood Cell Count",
          value: _form.wbcc,
          unit: "cells/cumm",
          normalRange: "3800 - 26400",
          onValueChange: (v) => _form.wbcc = v,
        ),
        LabNumberInput(
          label: "Red Blood Cell Count",
          value: _form.rbcc,
          unit: "mill/cmm",
          normalRange: "2.1 - 8.0",
          onValueChange: (v) => _form.rbcc = v,
        ),
      ],
    );
  }

  Widget _buildCategoryClinical() {
    return LabCategoryCard(
      title: "Kondisi Klinis",
      icon: Icons.medical_services_outlined,
      color: const Color(0xFF16A34A),
      children: [
        BinaryToggleChip(
          label: "Hipertensi",
          selectedValue: _form.htn,
          onValueChange: (v) => setState(() => _form.htn = v),
        ),
        BinaryToggleChip(
          label: "Diabetes Mellitus",
          selectedValue: _form.dm,
          onValueChange: (v) => setState(() => _form.dm = v),
        ),
        BinaryToggleChip(
          label: "Coronary Artery Disease",
          selectedValue: _form.cad,
          onValueChange: (v) => setState(() => _form.cad = v),
        ),
        BinaryToggleChip(
          label: "Nafsu Makan",
          selectedValue: _form.appet,
          optionFalseLabel: "Baik",
          optionTrueLabel: "Buruk",
          onValueChange: (v) => setState(() => _form.appet = v),
        ),
        BinaryToggleChip(
          label: "Pedal Edema",
          selectedValue: _form.pe,
          optionFalseLabel: "Tidak Ada",
          optionTrueLabel: "Ada",
          onValueChange: (v) => setState(() => _form.pe = v),
        ),
        BinaryToggleChip(
          label: "Anemia",
          selectedValue: _form.ane,
          onValueChange: (v) => setState(() => _form.ane = v),
        ),
      ],
    );
  }

  Widget _buildOverlayFeedback() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading) ...[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Menganalisis data di server AI...", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Mohon tunggu sebentar", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
              if (_result != null)
                PredictionResultCard(
                  result: _result!,
                  onReset: () {
                    setState(() {
                      _result = null;
                      _form = CkdInputForm();
                    });
                  },
                  onSave: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Data Lab Berhasil Disimpan!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Kembali ke Dashboard (Pop 2 kali: dari Prediksi dan dari Pilih Pasien)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              if (_error != null)
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text("Terjadi Kesalahan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[900])),
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() => _error = null),
                          child: const Text("Tutup"),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    bool isValid = _form.isFormValid;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isValid && _result == null)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text("Harap lengkapi semua field numerik", style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (isValid && !_isLoading) ? _runPrediction : null,
                icon: const Icon(Icons.science),
                label: const Text("Jalankan Prediksi AI", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
