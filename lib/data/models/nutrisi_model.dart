class NutrisiItem {
  final String makanan;
  final String kelompok;
  final double energi;
  final double protein;
  final double natrium;
  final double kalium;
  final double fosfor;
  final double lemak;
  final double karbohidrat;

  NutrisiItem({
    required this.makanan,
    required this.kelompok,
    required this.energi,
    required this.protein,
    required this.natrium,
    required this.kalium,
    required this.fosfor,
    required this.lemak,
    required this.karbohidrat,
  });

  String toRagDescription() {
    return "$makanan ($kelompok) mengandung: "
        "Energi ${energi} kkal, Protein ${protein}g, "
        "Natrium ${natrium}mg, Kalium ${kalium}mg, Fosfor ${fosfor}mg.";
  }
}
