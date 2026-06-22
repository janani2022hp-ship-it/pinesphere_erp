// features/student/presentation/pages/ai_chatbot_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const _green       = Color(0xFF58CC02);
const _greenDark   = Color(0xFF45A700);
const _orange      = Color(0xFFFF9600);
const _blue        = Color(0xFF1CB0F6);
const _blueDark    = Color(0xFF0081C8);
const _blueDeep    = Color(0xFF2B70C9);
const _red         = Color(0xFFFF4B4B);
const _redDark     = Color(0xFFCB3E3E);
const _purple      = Color(0xFFCE82FF);
const _purpleDark  = Color(0xFFB800FF);
const _yellow      = Color(0xFFFFD900);
const _coral       = Color(0xFFFF6B35);

const _bg          = Color(0xFFFDF6EC);
const _cardCream   = Color(0xFFFFFAF4);
const _border      = Color(0xFFE5E5EA);
const _textDark    = Color(0xFF1C1C1E);
const _textGrey    = Color(0xFF8E8E93);
const _textLight   = Color(0xFFC7C7CC);

const _tintGreen   = Color(0xFFEEFBDD);
const _tintBlue    = Color(0xFFE3F5FE);
const _tintOrange  = Color(0xFFFFF3E0);
const _tintRed     = Color(0xFFFFECEC);
const _tintPurple  = Color(0xFFF8EDFF);
const _tintYellow  = Color(0xFFFFFBE0);

class _Message {
  final String text;
  final bool isUser;
  final String time;
  final List<_QuickReply>? quickReplies;

  const _Message({
    required this.text,
    required this.isUser,
    required this.time,
    this.quickReplies,
  });
}

class _QuickReply {
  final String label;
  final IconData icon;
  const _QuickReply(this.label, this.icon);
}

const _suggestions = [
  (Icons.calculate_rounded,   'Explain Algebra',    _tintPurple, _purpleDark),
  (Icons.science_outlined,    "Newton's Laws",      _tintBlue,   _blueDark),
  (Icons.history_edu_rounded, 'Essay writing tips', _tintGreen,  _greenDark),
  (Icons.biotech_outlined,    'Chemistry basics',   _tintRed,    _redDark),
];

final _demoMessages = [
  const _Message(
    text: "Hi Arjun! 👋 I'm ScholarAI, your personal tutor. Ask me anything — concepts, homework help, or exam prep.",
    isUser: false,
    time: '9:00 AM',
    quickReplies: [
      _QuickReply('Help with Maths', Icons.calculate_rounded),
      _QuickReply('Science concepts', Icons.science_outlined),
      _QuickReply('Essay tips', Icons.edit_outlined),
    ],
  ),
  const _Message(
    text: "Teach me Newton's Laws of Motion",
    isUser: true,
    time: '9:02 AM',
  ),
  const _Message(
    text: "Great choice! Newton's Laws are the foundation of classical mechanics.\n\n"
        "1️⃣ First Law (Inertia): An object stays at rest or in motion unless acted on by a force.\n\n"
        "2️⃣ Second Law (F = ma): Force equals mass × acceleration.\n\n"
        "3️⃣ Third Law (Action-Reaction): Every action has an equal and opposite reaction.\n\n"
        "Want a practice problem or a deeper dive into any of these?",
    isUser: false,
    time: '9:02 AM',
    quickReplies: [
      _QuickReply('Practice problem', Icons.quiz_rounded),
      _QuickReply('More examples', Icons.lightbulb_outline_rounded),
    ],
  ),
];

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({super.key});

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = List<_Message>.from(_demoMessages);
  bool _showSuggestions = false;

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(_Message(
        text: text.trim(),
        isUser: true,
        time: _nowTime(),
      ));
      _showSuggestions = false;
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                itemCount: _messages.length + (_showSuggestions ? 1 : 0),
                itemBuilder: (context, i) {
                  if (_showSuggestions && i == _messages.length) {
                    return _SuggestionsRow(onTap: (s) => _sendMessage(s));
                  }
                  return _MessageBubble(
                    message: _messages[i],
                    onQuickReply: (s) => _sendMessage(s),
                  );
                },
              ),
            ),
            _InputBar(
              controller: _controller,
              onSend: () => _sendMessage(_controller.text),
              onSuggestions: () =>
                  setState(() => _showSuggestions = !_showSuggestions),
              showSuggestions: _showSuggestions,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: BoxDecoration(
        color: _cardCream,
        border: Border(bottom: BorderSide(color: _border, width: .5)),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_blue, _blueDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('✦', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ScholarAI',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                    letterSpacing: -.3,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Online · Ready to help',
                      style: GoogleFonts.fredoka(
                        fontSize: 11,
                        color: _greenDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _tintBlue,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _blue.withValues(alpha: .25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, size: 13, color: _blue),
                const SizedBox(width: 5),
                Text(
                  'All subjects',
                  style: GoogleFonts.fredoka(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _blueDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message message;
  final ValueChanged<String> onQuickReply;

  const _MessageBubble({required this.message, required this.onQuickReply});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_blue, _blueDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('✦', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: isUser ? _blue : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: _border, width: .5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      color: isUser ? Colors.white : _textDark,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: _tintBlue,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _blue.withValues(alpha: .30)),
                  ),
                  child: Center(
                    child: Text(
                      'AK',
                      style: GoogleFonts.fredoka(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _blueDark,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: isUser ? 0 : 38,
              right: isUser ? 38 : 0,
            ),
            child: Text(
              message.time,
              style: GoogleFonts.fredoka(fontSize: 10, color: _textLight),
            ),
          ),
          if (message.quickReplies != null && !isUser) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.quickReplies!
                    .map((qr) => _QuickReplyChip(
                          label: qr.label,
                          icon: qr.icon,
                          onTap: () => onQuickReply(qr.label),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickReplyChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: _tintBlue,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _blue.withValues(alpha: .25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 13, color: _blue),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _blueDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsRow extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _SuggestionsRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested topics',
            style: GoogleFonts.fredoka(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textGrey,
              letterSpacing: .2,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.8,
            children: _suggestions
                .map((s) => GestureDetector(
                      onTap: () => onTap(s.$2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: s.$3,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: s.$4.withValues(alpha: .2), width: .5),
                        ),
                        child: Row(
                          children: [
                            Icon(s.$1, size: 16, color: s.$4),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                s.$2,
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: s.$4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onSuggestions;
  final bool showSuggestions;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onSuggestions,
    required this.showSuggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      decoration: BoxDecoration(
        color: _cardCream,
        border: Border(top: BorderSide(color: _border, width: .5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onSuggestions,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: showSuggestions ? _tintPurple : _bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: showSuggestions ? _purple.withValues(alpha: .40) : _border,
                ),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: showSuggestions ? _purpleDark : _textGrey,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                style: GoogleFonts.fredoka(
                  fontSize: 13,
                  color: _textDark,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  hintStyle: GoogleFonts.fredoka(
                    fontSize: 13,
                    color: _textLight,
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_blue, _blueDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_upward_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}