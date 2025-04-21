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
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant ChatBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.discussionId != oldWidget.discussionId) {
      // Clean up old connection
      ws.removeUserFromDiscussion(oldWidget.discussionId);
      messages.clear();
      usersCount = 1;

      // Set up new connection
      ws.joinDiscussion(widget.discussionId);
      setState(() {});
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
    _msgStream = ws.messages.listen((data) {
      if (data is Map) {
        if (data['usersCount'] != null) {
          setState(() {
            usersCount = data['usersCount'] as int;
          });
        } else if (data['message'] != null) {
          setState(() {
            final message = Map<String, dynamic>.from(data);
            if (message['_id'] == null && message['name'] != null) {
              message['_id'] = message['name'];
            }
            messages.add(message);
          });
        }
      }
    });

    // Add keyboard listener
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Scroll to bottom when keyboard appears
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {});
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _msgStream?.cancel();
    _focusNode.dispose();
    ws.removeUserFromDiscussion(discussionId);
    super.dispose();
  }

  void _sendMessage(String discussionId) {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final user = {
        '_id': auth.user?['_id'],
        'name': auth.user?['name'],
        'username': auth.user?['username'] ?? '',
        'picture': auth.user?['picture'] ?? '',
      };
      ws.sendMessageInDiscussion(
          {'discussionId': discussionId, 'message': text, 'user': user});
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Custom theme colors
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Container(
      color: background,
      child: Column(
        children: [
          // Users count at the top
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, color: foreground, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Users in chat: $usersCount',
                  style: TextStyle(color: foreground, fontSize: 14),
                ),
              ],
            ),
          ),
          Divider(color: border, height: 1),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue[700] : accent,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['name']?.toString() ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white : mutedForeground,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            msg['message']?.toString() ?? '',
                            style: TextStyle(
                                color: isMe ? Colors.white : foreground,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(color: border, height: 1),
          // Message input area
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: TextStyle(color: foreground),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: mutedForeground),
                      filled: true,
                      fillColor: accent,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: border),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(discussionId),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: foreground),
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
