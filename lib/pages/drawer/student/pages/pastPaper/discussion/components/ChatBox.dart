import 'package:flutter/material.dart';

class ChatBox extends StatefulWidget {
  final String discussionId;
  const ChatBox({super.key, required this.discussionId});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final List<Map<String, String>> messages = [
    {
      'user': 'Alice',
      'text': 'Hey, did you solve Q3?',
      'timestamp': '10:30 AM',
      'avatar': 'A'
    },
    {
      'user': 'Bob',
      'text': 'Not yet, it looks tough!',
      'timestamp': '10:31 AM',
      'avatar': 'B'
    },
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int onlineUsers = 5;
  String status = 'Active';

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add({
          'user': 'You',
          'text': text,
          'timestamp': '${DateTime.now().hour}:${DateTime.now().minute}',
          'avatar': 'Y'
        });
      });
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF09090B),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF18181B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                _buildStatusIndicator(),
                const Spacer(),
                _buildHeaderActions(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF09090B),
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[messages.length - 1 - index];
                  return _buildMessageItem(msg);
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF27272A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.people_alt_rounded,
                  color: Color(0xFF4ADE80), size: 16),
              const SizedBox(width: 8),
              Text(
                '$onlineUsers online',
                style: const TextStyle(
                  color: Color(0xFF4ADE80),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF27272A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: const TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.search_rounded,
              color: Color(0xFFA1A1AA), size: 20),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              color: Color(0xFFA1A1AA), size: 20),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageItem(Map<String, String> msg) {
    final isUser = msg['user'] == 'You';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(msg['avatar'] ?? ''),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    isUser ? const Color(0xFF2563EB) : const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? null : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg['user'] ?? '',
                        style: TextStyle(
                          color: isUser
                              ? const Color(0xFFBFDBFE)
                              : const Color(0xFFA1A1AA),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        msg['timestamp'] ?? '',
                        style: TextStyle(
                          color: isUser
                              ? const Color(0xFFBFDBFE)
                              : const Color(0xFF71717A),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg['text'] ?? '',
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildAvatar(msg['avatar'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildAvatar(String initial) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF3F3F46),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF18181B),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Color(0xFFA1A1AA)),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Color(0xFF71717A)),
                filled: true,
                fillColor: const Color(0xFF27272A),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Color(0xFFFFFFFF)),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
