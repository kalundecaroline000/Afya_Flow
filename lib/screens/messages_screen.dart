import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  final String patientName;

  const MessagesScreen({super.key, required this.patientName});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Pre-populate with initial patient context messages about booking
    _messages.addAll([
      {
        'text': 'Hello Doctor, I would like to book an appointment regarding my chest discomfort next Tuesday morning.',
        'isMe': false,
        'time': '10:15 AM'
      },
      {
        'text': 'I noticed it mostly happens when climbing up stairs or walking briskly.',
        'isMe': false,
        'time': '10:16 AM'
      },
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': 'Just now',
      });
      _messageController.clear();
    });
  }

  // AI Assistance suggestion injector
  void _injectAISuggestion(String suggestionText) {
    setState(() {
      _messageController.text = suggestionText;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF008080);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.patientName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🤖 AI Co-Pilot Quick Updates & Hints Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              border: Border(bottom: BorderSide(color: Colors.purple.shade100)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.purple.shade700, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "AfyaFlow AI Suggestions",
                      style: TextStyle(color: Colors.purple.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildAISuggestionChip(
                        "Approve booking for Tuesday 9:00 AM",
                        "Hello, I can see you on Tuesday at 9:00 AM. Please register at triage when you arrive.",
                      ),
                      const SizedBox(width: 8),
                      _buildAISuggestionChip(
                        "Ask for vitals/history",
                        "Are you currently tracking your blood pressure? Please share your recent readings.",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 💬 Chat History Bubble Stream Area
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isMe = msg['isMe'];

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? primaryTeal : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                      border: isMe ? null : Border.all(color: Colors.grey.shade200, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            msg['time'],
                            style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🎹 Interactive Live Messaging Input Dock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a dynamic reply...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: primaryTeal,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestionChip(String title, String continuousText) {
    return ActionChip(
      label: Text(title, style: const TextStyle(fontSize: 12, color: Colors.purple)),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.purple.shade200),
      onPressed: () => _injectAISuggestion(continuousText),
    );
  }
}