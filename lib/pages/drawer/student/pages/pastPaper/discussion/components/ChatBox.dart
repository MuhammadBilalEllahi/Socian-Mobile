import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:beyondtheclass/shared/services/WebSocketService.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ChatMessage = Map<String, dynamic>;

class ChatBox extends ConsumerStatefulWidget {
  final String discussionId;
  const ChatBox({super.key, required this.discussionId});

  @override
  ConsumerState<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends ConsumerState<ChatBox> {
  final List<ChatMessage> messages = [];
  int usersCount = 1;
  final TextEditingController _controller = TextEditingController();
  late final WebSocketService ws;
  late final String discussionId;
  StreamSubscription? _msgStream;
  late final auth = ref.watch(authProvider);

  @override
  void didUpdateWidget(covariant ChatBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint(
        "----------discussionId: ${widget.discussionId} and ${oldWidget.discussionId}");
    if (widget.discussionId != oldWidget.discussionId) {
      // Clean up old
      ws.removeUserFromDiscussion(oldWidget.discussionId);
      messages.clear();
      ws.joinDiscussion(widget.discussionId);

      setState(() {});
      debugPrint("----------discussionId after setState: $discussionId");
    }
  }

  @override
  void initState() {
    super.initState();
    discussionId = widget.discussionId;
    ws = WebSocketService();
    ws.connect();
    ws.joinDiscussion(discussionId);
    // Listen for messages
    debugPrint("----------discussionId: $discussionId");
    _msgStream = ws.messages.listen((data) {
      if (data is Map && data['message'] != null) {
        debugPrint("----------data: $data");
        setState(() {
          messages.add(Map<String, dynamic>.from(data));
        });
      } else if (data is Map && data['usersCount'] != null) {
        setState(() {
          usersCount = data['usersCount'] as int;
        });
      } else if (data is Map && data['users'] != null) {
        // Optionally handle users list
      } else if (data is Map &&
          data['socketId'] != null &&
          data['user'] != null &&
          data['message'] != null) {
        setState(() {
          messages.add(Map<String, dynamic>.from(data));
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _msgStream?.cancel();
    super.dispose();
  }

  void _sendMessage(String discussionId) {
    debugPrint(
        "----------discussionId: for sending message out: $discussionId");
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final user = {
        '_id': auth.user?['_id'],
        'name': auth.user?['name'],
        'username': auth.user?['username'] ?? '',
        'picture': auth.user?['picture'] ?? '',
      };
      debugPrint("----------discussionId: for sending message: $discussionId");
      ws.sendMessageInDiscussion([discussionId, text, user]);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      child: Column(
        children: [
          // Users count at the top
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Users in chat: $usersCount',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isMe = msg['_id'] == auth.user?['_id'];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue[700] : Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['user']?.toString() ?? '',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            msg['message']?.toString() ??
                                msg['text']?.toString() ??
                                '',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(discussionId),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _sendMessage(discussionId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
