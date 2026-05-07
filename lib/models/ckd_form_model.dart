// Model untuk data form skrining CKD
class CKDFormModel {
  // Tambahkan field sesuai parameter UCI CKD Dataset
  String nama;
  int usia;
  String jenisKelamin;
  double tekananDarah;
  double albumin;
  double gulaDarah;
  // ...tambahkan parameter lain sesuai kebutuhan

  CKDFormModel({
    required this.nama,
    required this.usia,
    required this.jenisKelamin,
    required this.tekananDarah,
    required this.albumin,
    required this.gulaDarah,
    // ...tambahkan parameter lain
  });
}
