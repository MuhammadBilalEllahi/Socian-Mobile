import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String userId; // Recipient ID
  final String userName;

  const ChatPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _apiClient = ApiClient();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late io.Socket _socket;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isTyping = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    _userId = auth.user?['_id'];
    if (_userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not logged in';
      });
      return;
    }
    _init();
    _fetch();
    _controller.addListener(_handleTyping);
  }

  void _init() {
    _socket = io.io('YOUR_BACKEND_URL', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('Connected to Socket.IO');
      _socket.emit('joinConversation', {
        'userId': _userId,
        'recipientId': widget.userId,
      });
    });

    _socket.on('prevMessages', (messages) {
      setState(() {
        _messages = (messages as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
      _scroll();
    });

    _socket.on('newMessage', (message) {
      setState(() {
        _messages.add(message as Map<String, dynamic>);
      });
      _scroll();
      if (message['recipientId'] == _userId) {
        final ids = [_userId!, widget.userId]..sort();
        final conversationId = ids.join(':');
        _socket.emit('markAsRead', {
          'conversationId': conversationId,
          'messageIds': [message['_id']],
        });
      }
    });

    _socket.on('messageStatusUpdate', (data) {
      setState(() {
        for (var message in _messages) {
          if (data['messageIds']?.contains(message['_id']) ?? false) {
            message['status'] = data['status'];
          }
        }
      });
    });

    _socket.on('newNotification', (notification) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New message: ${notification['message']}')),
      );
    });

    _socket.on('error', (error) {
      print('Socket.IO error: $error');
      setState(() {
        _errorMessage = 'Socket error: $error';
      });
    });

    _socket.onDisconnect((_) => print('Disconnected from Socket.IO'));
  }

  void _handleTyping() {
    setState(() => _isTyping = _controller.text.isNotEmpty);
    if (_isTyping) {
      HapticFeedback.lightImpact();
    }
  }

Future<void> _fetch() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });
  try {
    // Fetch from HTTP API
    final response = await _apiClient.get('/api/messages/${widget.userId}');
    final httpMessages = (response['messages'] as List).cast<Map<String, dynamic>>();
    
    setState(() {
      _messages = httpMessages;
      _isLoading = false;
    });
    
    // Socket will send additional messages via 'prevMessages' event
  } catch (e) {
    String errorMsg = 'Failed to load messages';
    if (e is dio.DioException) {
      errorMsg += ': ${e.response?.statusCode} ${e.response?.data['message'] ?? e.message}';
    }
    setState(() {
      _errorMessage = errorMsg;
      _isLoading = false;
    });
  }
}

Future<void> _send() async {
  final content = _controller.text.trim();
  if (content.isEmpty || _userId == null) return;

  final auth = ref.read(authProvider);
  final message = {
    'recipientId': widget.userId,
    'content': content,
    'user': {
      '_id': _userId,
      'name': auth.user?['name'] ?? 'Current User',
      'username': auth.user?['username'] ?? 'current_user',
      'picture': auth.user?['profile']?['picture'] ?? '',
    },
  };

  final tempId = DateTime.now().millisecondsSinceEpoch.toString();
  try {
    // Optimistically add message to UI
    setState(() {
      _messages.add({
        '_id': tempId,
        'senderId': _userId,
        'recipientId': widget.userId,
        'content': content,
        'status': 'sent',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
    _scroll();

    // Save via HTTP API as fallback
    final response = await _apiClient.post('/api/messages', {
      'recipientId': widget.userId,
      'content': content,
    });

    // Update with real ID from server
    if (response['data'] != null) {
      final serverMessage = response['data'];
      setState(() {
        _messages.removeWhere((m) => m['_id'] == tempId);
        _messages.add({
          '_id': serverMessage['_id'],
          'senderId': _userId,
          'recipientId': widget.userId,
          'content': content,
          'status': 'sent',
          'timestamp': serverMessage['createdAt'],
        });
      });
    }

    _controller.clear();
    HapticFeedback.mediumImpact();
  } catch (e) {
    print('Error sending message: $e');
    setState(() {
      _messages.removeWhere((m) => m['_id'] == tempId);
      _errorMessage = 'Failed to send: $e';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send: ${e.toString()}')),
    );
  }
}

  void _scroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTyping);
    _controller.dispose();
    _scrollController.dispose();
    _socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode
        ? LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : LinearGradient(
            colors: [Color(0xFFE2E8F0), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
    final foreground = isDarkMode ? Colors.white : Color(0xFF0F172A);
    final mutedForeground = isDarkMode ? Color(0xFFA5B4FC) : Color(0xFF64748B);
    const primary = Color(0xFF8B5CF6);

    if (_errorMessage != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: background),
          child: Center(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: mutedForeground, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: background),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, foreground),
              Expanded(child: _buildMessageList(context, foreground, mutedForeground, primary)),
              _buildInputArea(context, foreground, mutedForeground, primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color foreground) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border(bottom: BorderSide(color: foreground.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: foreground),
                onPressed: () => Navigator.pop(context),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: foreground.withOpacity(0.2),
                child: Text(
                  widget.userName[0].toUpperCase(),
                  style: TextStyle(color: foreground, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.userName,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.circle, color: foreground),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, Color foreground, Color mutedForeground, Color primary) {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: primary))
        : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: mutedForeground, fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
            : _messages.isEmpty
                ? Center(
                    child: Text(
                      'Start the conversation!',
                      style: TextStyle(
                        color: mutedForeground,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _messages.length) {
                        return _buildTypingIndicator(mutedForeground);
                      }
                      final message = _messages[index];
                      final isSentByUser = message['senderId'] != widget.userId;
                      final createdAt = DateTime.parse(message['timestamp'] ?? message['createdAt'] ?? DateTime.now().toIso8601String());
                      final formattedTime = DateFormat('HH:mm').format(createdAt);

                      return Align(
                        alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSentByUser
                                ? primary.withOpacity(0.9)
                                : foreground.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['content'] ?? '',
                                style: TextStyle(
                                  color: isSentByUser ? Colors.white : foreground,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      color: isSentByUser ? Colors.white70 : mutedForeground,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (isSentByUser && message['status'] != 'sent') ...[
                                    SizedBox(width: 4),
                                    Icon(
                                      message['status'] == 'read' ? Icons.done_all : Icons.done,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
  }

  Widget _buildTypingIndicator(Color mutedForeground) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Typing...',
              style: TextStyle(color: mutedForeground, fontStyle: FontStyle.italic),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 8,
              height: 8,
              child: CircularProgressIndicator(strokeWidth: 2, color: mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, Color foreground, Color mutedForeground, Color primary) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: foreground.withOpacity(0.1),
            border: Border(top: BorderSide(color: foreground.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.emoji_emotions_outlined, color: mutedForeground),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.attach_file, color: mutedForeground),
                onPressed: () {},
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: foreground, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: mutedForeground.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: foreground.withOpacity(0.05),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: _send,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}