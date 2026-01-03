import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:safeat/features/chatbot/data/gemini_service.dart';
import 'package:safeat/core/localization/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safeat/features/auth/presentation/pages/login_page.dart';
import 'package:safeat/main.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize with localized welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: AppLocalizations.of(context)!.translate('chat_welcome'),
              isUser: false,
            ),
          );
        });
      }
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF10B981),
              ),
              title: Text('Take Photo', style: GoogleFonts.outfit()),
              onTap: () {
                Navigator.pop(context);
                _processPickedImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFF10B981),
              ),
              title: Text('Choose from Gallery', style: GoogleFonts.outfit()),
              onTap: () {
                Navigator.pop(context);
                _processPickedImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPickedImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.isEmpty && _selectedImageBytes == null) return;

    final currentImageBytes = _selectedImageBytes;
    _textController.clear();
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, imageBytes: currentImageBytes),
      );
      _selectedImageBytes = null;
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final languageCode = localeNotifier.value.languageCode;
      final responseText = await _geminiService.sendMessage(
        text.isEmpty ? "What is in this image?" : text,
        languageCode: languageCode,
        imageBytes: currentImageBytes,
      );
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: responseText, isUser: false));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: AppLocalizations.of(context)!.translate('chat_error'),
              isUser: false,
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FBF9),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: Color(0xFF10B981),
                    size: 64,
                  ),
                ).animate().scale(delay: 200.ms).fadeIn(),
                const SizedBox(height: 32),
                Text(
                  "Snacky AI Needs You",
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1C1E),
                  ),
                  textAlign: TextAlign.center,
                ).animate().slideY(begin: 0.2, end: 0).fadeIn(),
                const SizedBox(height: 12),
                Text(
                  "Log in to start your personalized healthy food analysis with Snacky AI.",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: const Color(0xFF1A1C1E).withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms).fadeIn(),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                      if (mounted)
                        setState(() {}); // Refresh to check auth again
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('login_button'),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms).fadeIn(),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9), // Very light organic background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: Color(0xFF10B981),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Snacky",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: const Color(0xFF1A1C1E),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.translate('chat_snacky_status'),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [_buildLanguageSelector(const Color(0xFF10B981))],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.translate('chat_thinking'),
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 14.0,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? const Color(0xFF10B981) // Organic Green for user
                  : Colors.white, // Pure white for Snacky
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: isUser
                    ? const Radius.circular(24)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        message.imageBytes!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                MarkdownBody(
                  data: message.text,
                  styleSheet: MarkdownStyleSheet(
                    p: GoogleFonts.outfit(
                      color: isUser ? Colors.white : const Color(0xFF2D3135),
                      fontSize: 15,
                      height: 1.5,
                    ),
                    tableBody: GoogleFonts.outfit(
                      color: isUser ? Colors.white : const Color(0xFF2D3135),
                      fontSize: 13,
                    ),
                    tableHead: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: isUser ? Colors.white : const Color(0xFF2D3135),
                    ),
                    tableBorder: TableBorder.all(
                      color: isUser ? Colors.white24 : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedImageBytes != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _selectedImageBytes!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImageBytes = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFF10B981),
                ),
                onPressed: _pickImage,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F1), // Soft grey-green
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: Scrollbar(
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: GoogleFonts.outfit(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.translate('chat_placeholder'),
                          hintStyle: GoogleFonts.outfit(
                            color: Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded),
                  color: Colors.white,
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(Color organicGreen) {
    String currentLang = localeNotifier.value.languageCode == 'hi'
        ? 'HI'
        : localeNotifier.value.languageCode == 'as'
        ? 'AS'
        : 'EN';

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'EN') {
            localeNotifier.value = const Locale('en');
          } else if (value == 'HI') {
            localeNotifier.value = const Locale('hi');
          } else if (value == 'AS') {
            localeNotifier.value = const Locale('as');
          }
          if (mounted) setState(() {});
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'EN', child: Text('English')),
          const PopupMenuItem(value: 'HI', child: Text('Hindi')),
          const PopupMenuItem(value: 'AS', child: Text('Asomiya')),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: organicGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 16, color: organicGreen),
              const SizedBox(width: 4),
              Text(
                currentLang,
                style: GoogleFonts.outfit(
                  color: organicGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final Uint8List? imageBytes;

  ChatMessage({required this.text, required this.isUser, this.imageBytes});
}
