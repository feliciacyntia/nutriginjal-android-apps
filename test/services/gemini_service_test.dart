import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriginjal/services/gemini_service.dart';

// Create mocks
class MockGenerativeModel extends Mock implements GenerativeModel {}
class MockChatSession extends Mock implements ChatSession {}
class MockGenerateContentResponse extends Mock implements GenerateContentResponse {}
class MockCandidate extends Mock implements Candidate {}
class MockTextPart extends Mock implements TextPart {}

void main() {
  late GeminiService geminiService;
  late MockGenerativeModel mockModel;
  late MockChatSession mockChatSession;

  setUpAll(() {
    registerFallbackValue(Content.text(''));
  });

  setUp(() {
    mockModel = MockGenerativeModel();
    mockChatSession = MockChatSession();
    geminiService = GeminiService(model: mockModel);
  });

  group('GeminiService Tests', () {
    test('generateResponse should return text from AI', () async {
      // Setup mock response
      final mockResponse = MockGenerateContentResponse();
      final mockCandidate = MockCandidate();
      
      when(() => mockCandidate.text).thenReturn("Halo! Saya asisten nutrisi Anda.");
      when(() => mockResponse.text).thenReturn("Halo! Saya asisten nutrisi Anda.");
      when(() => mockResponse.candidates).thenReturn([mockCandidate]);
      
      // Setup chat session mock
      when(() => mockModel.startChat(history: any(named: 'history')))
          .thenReturn(mockChatSession);
      when(() => mockChatSession.sendMessage(any()))
          .thenAnswer((_) async => mockResponse);

      final result = await geminiService.generateResponse(prompt: "Halo");

      expect(result, equals("Halo! Saya asisten nutrisi Anda."));
      verify(() => mockChatSession.sendMessage(any())).called(1);
    });

    test('generateTitle should return a clean title string', () async {
      final mockResponse = MockGenerateContentResponse();
      when(() => mockResponse.text).thenReturn("Judul Percakapan CKD");
      
      when(() => mockModel.generateContent(any()))
          .thenAnswer((_) async => mockResponse);

      final title = await geminiService.generateTitle("Saya ingin tanya tentang diet");

      expect(title, equals("Judul Percakapan CKD"));
      verify(() => mockModel.generateContent(any())).called(1);
    });

    test('should return default message when AI response is null', () async {
      final mockResponse = MockGenerateContentResponse();
      when(() => mockResponse.text).thenReturn(null);
      
      when(() => mockModel.startChat(history: any(named: 'history')))
          .thenReturn(mockChatSession);
      when(() => mockChatSession.sendMessage(any()))
          .thenAnswer((_) async => mockResponse);

      final result = await geminiService.generateResponse(prompt: "Tes");

      expect(result, contains("Maaf, saya tidak dapat memproses"));
    });
  });
}
