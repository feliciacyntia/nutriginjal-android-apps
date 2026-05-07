import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nutriginjal/core/constants/supabase_config.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService({GenerativeModel? model})
      : _model = model ??
      GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: SupabaseConfig.geminiApiKey,
        systemInstruction: Content.system(
          'Kamu adalah NutriSnapS AI, Asisten Gizi Klinis untuk pasien '
              'Penyakit Ginjal Kronis (CKD). Selalu jawab dalam Bahasa Indonesia '
              'yang ramah, terstruktur, dan berbasis data referensi yang diberikan. '
              'Jangan pernah mengarang informasi nutrisi di luar data yang ada.',
        ),
        generationConfig: GenerationConfig(
          temperature: 0.1,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 4096,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );

  /// Stream respons token demi token
  Stream<String> generateResponseStream({
    required String prompt,
    List<Content>? history,
  }) async* {
    final chat = _model.startChat(history: history);
    final responseStream = chat.sendMessageStream(Content.text(prompt));
    await for (final chunk in responseStream) {
      final text = chunk.text;
      if (text != null && text.isNotEmpty) yield text;
    }
  }

  /// Fallback non-stream (tetap dipertahankan)
  Future<String> generateResponse({
    required String prompt,
    List<Content>? history,
  }) async {
    final chat = _model.startChat(history: history);
    final response = await chat.sendMessage(Content.text(prompt));
    return response.text ?? 'Maaf, saya tidak dapat memproses permintaan Anda saat ini.';
  }

  Future<String> generateTitle(String firstMessage) async {
    final prompt =
        'Buat judul ringkas maksimal 5 kata dalam Bahasa Indonesia '
        'untuk percakapan yang dimulai dengan: "$firstMessage". '
        'Hanya tulis judulnya saja, tanpa tanda kutip.';
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text?.replaceAll('"', '').trim() ?? 'Chat Baru';
  }
}