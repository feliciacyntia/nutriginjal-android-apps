import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nutriginjal/services/chat_service.dart';
import 'package:nutriginjal/services/gemini_service.dart';
import 'package:nutriginjal/services/nutrisi_service.dart';
import 'package:nutriginjal/data/models/chat_model.dart';
import 'package:nutriginjal/core/utils/ckd_nutrition_prompt.dart';
import 'package:nutriginjal/ui/widgets/chat_bubble.dart';
import 'package:nutriginjal/ui/widgets/suggested_prompt_buttons.dart';

const bool _kDebugChat = true;

class ChatPage extends StatefulWidget {
  final String? sessionId;
  final String title;
  final bool showWelcome;
  final List<String> suggestedPrompts;

  const ChatPage({
    super.key,
    this.sessionId,
    this.title = 'Chat',
    this.showWelcome = false,
    this.suggestedPrompts = const [],
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final GeminiService _geminiService = GeminiService();
  final NutrisiService _nutrisiService = NutrisiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String? _currentSessionId;
  bool _isDatasetLoading = true;
  bool _isLoading = false;
  bool _isChatActive = false;

  // State streaming
  String _streamingText = '';
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _currentSessionId = widget.sessionId;
    _isChatActive = widget.sessionId != null;
    _loadDataset();
  }

  Future<void> _loadDataset() async {
    if (_kDebugChat) debugPrint('=== [DATASET] Mulai memuat dataset...');
    await _nutrisiService.loadDataset();
    if (_kDebugChat) debugPrint('=== [DATASET] Dataset selesai dimuat.');
    if (mounted) setState(() => _isDatasetLoading = false);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _startChat(String initialText) async {
    if (initialText.trim().isEmpty) return;
    if (_kDebugChat) debugPrint('=== [SESSION] Membuat sesi: "$initialText"');

    setState(() {
      _isLoading = true;
      _isChatActive = true;
    });

    try {
      final truncated = initialText.length > 20
          ? '${initialText.substring(0, 20)}...'
          : initialText;

      final session = await _chatService
          .createChatSession('${widget.title}: $truncated')
          .timeout(const Duration(seconds: 15));

      if (_kDebugChat) debugPrint('=== [SESSION] ID: ${session.id}');

      if (mounted) {
        setState(() {
          _currentSessionId = session.id;
          _isLoading = false;
        });
        await _sendMessage(initialText);
      }
    } catch (e) {
      if (_kDebugChat) debugPrint('=== [SESSION ERROR] $e');
      if (mounted) {
        setState(() {
          _isChatActive = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulai sesi: $e'),
            backgroundColor: Colors.red.shade400,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: () => _startChat(initialText),
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendMessage(String text) async {
    final messageContent = text.trim();
    if (messageContent.isEmpty || _currentSessionId == null) return;

    _messageController.clear();
    setState(() {
      _isLoading = true;
      _streamingText = '';
      _isStreaming = true;
    });

    try {
      // 1. Simpan pesan user
      await _chatService.sendMessage(
        sessionId: _currentSessionId!,
        content: messageContent,
        role: 'user',
      );

      // 2. RAG
      final relevantItems = _nutrisiService.retrieve(messageContent);

      if (_kDebugChat) {
        debugPrint('╔══════════════════════════════════════╗');
        debugPrint('║        DEBUG CHAT PIPELINE           ║');
        debugPrint('╚══════════════════════════════════════╝');
        debugPrint('▶ [1] QUERY    : "$messageContent"');
        debugPrint('▶ [2] RAG ITEMS: ${relevantItems.length} item');
        if (relevantItems.isEmpty) debugPrint('  ⚠️  Tidak ada item relevan!');
        for (int i = 0; i < relevantItems.length; i++) {
          debugPrint('  [${i + 1}] ${relevantItems[i]}');
        }
      }

      // 3. Build context & prompt
      final contextText = _nutrisiService.formatContext(relevantItems);
      final fullPrompt = CkdNutritionPrompt.build(
        context: contextText,
        userQuestion: messageContent,
      );

      if (_kDebugChat) {
        debugPrint('▶ [3] CONTEXT: ${contextText.trim().isEmpty ? '⚠️ KOSONG!' : 'OK'}');
        debugPrint('▶ [4] FULL PROMPT:\n${'─' * 40}\n$fullPrompt\n${'─' * 40}');
      }

      // 4. History
      final historyMessages =
      await _chatService.getMessages(_currentSessionId!);
      final geminiHistory = historyMessages
          .take(historyMessages.length - 1)
          .map((msg) => Content(
        msg.role == 'user' ? 'user' : 'model',
        [TextPart(msg.content)],
      ))
          .toList();

      if (_kDebugChat) debugPrint('▶ [5] HISTORY: ${geminiHistory.length} pesan');

      // 5. Streaming
      final buffer = StringBuffer();
      await for (final chunk in _geminiService.generateResponseStream(
        prompt: fullPrompt,
        history: geminiHistory,
      )) {
        buffer.write(chunk);
        if (mounted) {
          setState(() => _streamingText = buffer.toString());
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        }
      }

      final finalReply = buffer.toString().trim().isEmpty
          ? 'Maaf, saya tidak dapat memproses permintaan Anda saat ini.'
          : buffer.toString();

      if (_kDebugChat) {
        debugPrint('▶ [6] REPLY:\n${'─' * 40}\n$finalReply\n${'─' * 40}');
        debugPrint('✅ Pipeline selesai.');
      }

      // 6. Simpan ke DB
      await _chatService.sendMessage(
        sessionId: _currentSessionId!,
        content: finalReply,
        role: 'assistant',
      );
    } catch (e, stackTrace) {
      if (_kDebugChat) {
        debugPrint('=== [ERROR] $e');
        debugPrint('=== [STACKTRACE] $stackTrace');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan jawaban AI: $e'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isStreaming = false;
          _streamingText = '';
        });
      }
    }
  }

  void _handleSubmit() {
    final text = _messageController.text;
    if (text.trim().isEmpty || _isLoading || _isDatasetLoading) return;

    if (!_isChatActive) {
      _startChat(text);
    } else {
      _sendMessage(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF26C6DA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isDatasetLoading
          ? _buildInitializingView()
          : Column(
        children: [
          Expanded(
            child: _isChatActive
                ? _buildChatArea()
                : _buildWelcomeArea(),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInitializingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF26C6DA)),
          const SizedBox(height: 16),
          const Text(
            'Memuat database nutrisi...',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Mohon tunggu sebentar',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeArea() {
    if (!widget.showWelcome) {
      return const Center(
        child: Text(
          'Mulai dengan menanyakan sesuatu tentang nutrisi 😊',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF26C6DA).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: Color(0xFF26C6DA),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: Text(
                'Tanyakan apa saja seputar nutrisi dan pola hidup sehat untuk ginjal Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            if (widget.suggestedPrompts.isNotEmpty) ...[
              const SizedBox(height: 32),
              SuggestedPromptButtons(
                prompts: widget.suggestedPrompts,
                onPromptSelected: _startChat,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    if (_isLoading && _currentSessionId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF26C6DA)),
            SizedBox(height: 16),
            Text('Menyiapkan sesi...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return StreamBuilder<List<ChatMessage>>(
      stream: _chatService.getMessagesStream(_currentSessionId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          if (_kDebugChat) debugPrint('=== [STREAM ERROR]: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final messages = snapshot.data ?? [];

        // Sembunyikan streaming bubble jika pesan AI terakhir sudah tersimpan
        final lastIsSaved = messages.isNotEmpty &&
            messages.last.role == 'assistant' &&
            messages.last.id != 'streaming';
        final showStreamBubble = _isStreaming && !lastIsSaved;

        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: messages.length + (showStreamBubble ? 1 : 0),
          itemBuilder: (context, index) {
            if (showStreamBubble && index == messages.length) {
              final streamMsg = ChatMessage(
                id: 'streaming',
                sessionId: _currentSessionId!,
                role: 'assistant',
                content: _streamingText,
                createdAt: DateTime.now(),
              );
              return ChatBubble(message: streamMsg, isStreaming: true);
            }
            return ChatBubble(message: messages[index]);
          },
        );
      },
    );
  }

  Widget _buildInputBar() {
    final bool isDisabled = _isLoading || _isDatasetLoading;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: !isDisabled,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: _isDatasetLoading
                        ? 'Menunggu data nutrisi...'
                        : 'Tulis pertanyaan...',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _handleSubmit(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey.shade200
                    : const Color(0xFF26C6DA),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: isDisabled ? null : _handleSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}