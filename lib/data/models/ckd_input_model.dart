class CkdInputForm {
  String age = "";
  String bp = "";
  double sg = 1.020;
  double al = 0;
  double su = 0;
  double rbc = 0;
  double pc = 0;
  double pcc = 0;
  double ba = 0;
  String bgr = "";
  String bu = "";
  String sc = "";
  String sod = "";
  String pot = "";
  String hemo = "";
  String pcv = "";
  String wbcc = "";
  String rbcc = "";
  double htn = 0;
  double dm = 0;
  double cad = 0;
  double appet = 0;
  double pe = 0;
  double ane = 0;

  Map<String, double> toModelInput() {
    return {
      "age": double.tryParse(age) ?? 0,
      "bp": double.tryParse(bp) ?? 0,
      "sg": sg,
      "al": al,
      "su": su,
      "rbc": rbc,
      "pc": pc,
      "pcc": pcc,
      "ba": ba,
      "bgr": double.tryParse(bgr) ?? 0,
      "bu": double.tryParse(bu) ?? 0,
      "sc": double.tryParse(sc) ?? 0,
      "sod": double.tryParse(sod) ?? 0,
      "pot": double.tryParse(pot) ?? 0,
      "hemo": double.tryParse(hemo) ?? 0,
      "pcv": double.tryParse(pcv) ?? 0,
      "wbcc": double.tryParse(wbcc) ?? 0,
      "rbcc": double.tryParse(rbcc) ?? 0,
      "htn": htn,
      "dm": dm,
      "cad": cad,
      "appet": appet,
      "pe": pe,
      "ane": ane,
    };
  }

  bool get isFormValid {
    final numericFields = [age, bp, bgr, bu, sc, sod, pot, hemo, pcv, wbcc, rbcc];
    return numericFields.every((field) => field.isNotEmpty && double.tryParse(field) != null);
  }
}

class PredictionResult {
  final String label;
  final bool isCkd;
  final String riskLevel;
  final double confidence;

  PredictionResult({
    required this.label,
    required this.isCkd,
    required this.riskLevel,
    this.confidence = 1.0,
  });
}
