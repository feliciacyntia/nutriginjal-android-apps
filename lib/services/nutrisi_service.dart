import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:csv/csv.dart';
import 'package:nutriginjal/data/models/nutrisi_model.dart';

class NutrisiService {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<NutrisiItem> _cachedData = [];

  // ✅ Mapping kata kunci → nama field nutrisi
  static const Map<String, String> _nutrisiKeywords = {
    'protein': 'protein',
    'natrium': 'natrium',
    'garam': 'natrium',
    'sodium': 'natrium',
    'kalium': 'kalium',
    'potasium': 'kalium',
    'fosfor': 'fosfor',
    'phosphor': 'fosfor',
    'lemak': 'lemak',
    'energi': 'energi',
    'kalori': 'energi',
    'karbohidrat': 'karbohidrat',
    'karbo': 'karbohidrat',
  };

  // ✅ Kata kunci query umum yang tidak merujuk nama makanan spesifik
  static const List<String> _generalQueryKeywords = [
    'menu', 'makanan', 'rekomendasi', 'aman', 'boleh',
    'tidak boleh', 'hindari', 'bagus', 'baik', 'sehat',
    'ckd', 'ginjal', 'diet', 'daftar', 'contoh',
    'apa saja', 'tips', 'saran', 'anjuran',
  ];

  Future<void> loadDataset() async {
    if (_cachedData.isNotEmpty) {
      debugPrint('[NutrisiService] Dataset sudah di-cache (${_cachedData.length} items), skip load.');
      return;
    }

    try {
      debugPrint('[NutrisiService] Mengunduh dataset dari Supabase Storage...');

      final response = await _supabase
          .storage
          .from('Dataset')
          .download('nutrisirecovered.csv');

      final csvString = utf8.decode(response);

      // ✅ Tambah eol eksplisit untuk handle berbagai jenis line ending
      final List<List<dynamic>> rows = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false, // biar tidak salah parse angka
      ).convert(csvString);

      debugPrint('[NutrisiService] Total baris CSV (termasuk header): ${rows.length}');

      if (rows.length < 2) {
        debugPrint('[NutrisiService] ⚠️ CSV kosong atau hanya ada header.');
        return;
      }

      // ✅ Debug header untuk verifikasi index
      debugPrint('[NutrisiService] Header CSV: ${rows[0]}');

      // ✅ Index kolom yang benar berdasarkan struktur CSV asli:
      // 0:no, 1:kode baru, 2:makanan, 3:air, 4:energi, 5:protein,
      // 6:lemak, 7:karbohidrat, 8:serat, 9:abu, 10:kalsium,
      // 11:fosfor(p), 12:besi, 13:natrium(na), 14:kalium(ka),
      // 15:tembaga, 16:seng, 17:retinol, 18:karoten, 19:karoten total,
      // 20:thiamin, 21:riboflavin, 22:niasin, 23:vit c, 24:bdd,
      // 25:mentah/olahan, 26:kelompok makanan, 27:sumber, 28:deskripsi

      final List<NutrisiItem> parsed = [];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        // Skip baris yang terlalu pendek atau kosong
        if (row.length < 27) {
          debugPrint('[NutrisiService] Skip baris $i (kolom tidak cukup: ${row.length})');
          continue;
        }

        try {
          parsed.add(NutrisiItem(
            makanan: row[2].toString().trim(),
            kelompok: row[26].toString().trim(),
            energi: _parseDouble(row[4]),
            protein: _parseDouble(row[5]),
            lemak: _parseDouble(row[6]),
            karbohidrat: _parseDouble(row[7]),
            fosfor: _parseDouble(row[11]),
            natrium: _parseDouble(row[13]),
            kalium: _parseDouble(row[14]),
          ));
        } catch (e) {
          debugPrint('[NutrisiService] ⚠️ Error parse baris $i: $e | data: $row');
        }
      }

      _cachedData = parsed;
      debugPrint('[NutrisiService] ✅ Dataset berhasil dimuat: ${_cachedData.length} items.');

      // ✅ Debug sampel 3 item pertama untuk verifikasi
      for (int i = 0; i < _cachedData.length && i < 3; i++) {
        debugPrint('[NutrisiService] Sampel[$i]: ${_cachedData[i].toRagDescription()}');
      }
    } catch (e, stackTrace) {
      debugPrint('[NutrisiService] ❌ Error loadDataset: $e');
      debugPrint('[NutrisiService] StackTrace: $stackTrace');
    }
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    final str = val.toString().trim().replaceAll(',', '.');
    if (str.isEmpty || str == '-') return 0.0;
    return double.tryParse(str) ?? 0.0;
  }

  /// Retrieval utama — gabungan keyword search + fallback nutrisi + fallback umum
  List<NutrisiItem> retrieve(String query, {int topK = 5}) {
    if (_cachedData.isEmpty) {
      debugPrint('[NutrisiService] ⚠️ retrieve() dipanggil tapi _cachedData kosong!');
      return [];
    }

    final queryLower = query.toLowerCase();
    final queryWords = queryLower
        .split(RegExp(r'[\s,\?!\.]+'))
        .where((w) => w.length > 2)
        .toList();

    debugPrint('[NutrisiService] retrieve() → queryWords: $queryWords');

    if (queryWords.isEmpty) return _cachedData.take(topK).toList();

    // ✅ Deteksi apakah query umum (bukan nama makanan spesifik)
    final bool isGeneralQuery =
    _generalQueryKeywords.any((kw) => queryLower.contains(kw));

    // ✅ Deteksi nutrisi spesifik yang ditanyakan
    String? targetNutrisi;
    for (final entry in _nutrisiKeywords.entries) {
      if (queryLower.contains(entry.key)) {
        targetNutrisi = entry.value;
        break;
      }
    }

    debugPrint('[NutrisiService] isGeneralQuery: $isGeneralQuery | targetNutrisi: $targetNutrisi');

    // ✅ Query umum + ada nutrisi spesifik → top by nutrisi
    if (isGeneralQuery && targetNutrisi != null) {
      final result = _getTopByNutrisi(targetNutrisi, topK);
      debugPrint('[NutrisiService] Path: general+nutrisi → ${result.length} items');
      return result;
    }

    // ✅ Query umum tanpa nutrisi spesifik → sampel representatif
    if (isGeneralQuery) {
      final result = _cachedData.take(topK).toList();
      debugPrint('[NutrisiService] Path: general → ${result.length} items');
      return result;
    }

    // ✅ Pencarian berdasarkan nama makanan
    final List<MapEntry<NutrisiItem, int>> scoredItems = _cachedData.map((item) {
      int score = 0;
      for (final word in queryWords) {
        if (item.makanan.toLowerCase().contains(word)) score += 5;
        if (item.kelompok.toLowerCase().contains(word)) score += 1;
      }
      return MapEntry(item, score);
    }).where((entry) => entry.value > 0).toList();

    scoredItems.sort((a, b) => b.value.compareTo(a.value));

    // ✅ Fallback: nama makanan tidak match tapi ada kata nutrisi
    if (scoredItems.isEmpty && targetNutrisi != null) {
      final result = _getTopByNutrisi(targetNutrisi, topK);
      debugPrint('[NutrisiService] Path: fallback nutrisi → ${result.length} items');
      return result;
    }

    // ✅ Fallback terakhir: sampel umum agar Gemini tetap punya konteks
    if (scoredItems.isEmpty) {
      final result = _cachedData.take(5).toList();
      debugPrint('[NutrisiService] Path: fallback umum → ${result.length} items');
      return result;
    }

    final result = scoredItems.take(topK).map((e) => e.key).toList();
    debugPrint('[NutrisiService] Path: nama makanan → ${result.length} items');
    return result;
  }

  /// Ambil item dengan kandungan nutrisi tertinggi (descending)
  List<NutrisiItem> _getTopByNutrisi(String nutrisi, int topK) {
    final sorted = List<NutrisiItem>.from(_cachedData);
    sorted.sort((a, b) {
      final valA = _getNutrisiValue(a, nutrisi);
      final valB = _getNutrisiValue(b, nutrisi);
      return valB.compareTo(valA);
    });
    return sorted.take(topK).toList();
  }

  double _getNutrisiValue(NutrisiItem item, String nutrisi) {
    switch (nutrisi) {
      case 'protein':      return item.protein;
      case 'natrium':      return item.natrium;
      case 'kalium':       return item.kalium;
      case 'fosfor':       return item.fosfor;
      case 'lemak':        return item.lemak;
      case 'energi':       return item.energi;
      case 'karbohidrat':  return item.karbohidrat;
      default:             return 0;
    }
  }

  String formatContext(List<NutrisiItem> items) {
    if (items.isEmpty) {
      return 'Tidak ada data nutrisi spesifik yang ditemukan di dataset.';
    }
    return items.map((item) => '- ${item.toRagDescription()}').join('\n');
  }
}