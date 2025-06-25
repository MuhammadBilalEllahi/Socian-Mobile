import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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
  final bool _isTyping = false;
  String? _userId;

  // Refined color palette
  static const _primary = Color(0xFF2C2C2E);
  static const _primaryLight = Color(0xFFF2F2F7);
  static const _accent = Color(0xFF007AFF);
  static const _surface = Color(0xFFFFFFFF);
  static const _surfaceDark = Color(0xFF1C1C1E);
  static const _textPrimary = Color(0xFF000000);
  static const _textSecondary = Color(0xFF3C3C43);
  static const _textTertiary = Color(0xFF8E8E93);
  static const _divider = Color(0xFFE5E5EA);
  static const _dividerDark = Color(0xFF38383A);

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scroll());
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
      print('New message received: $message');
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
        SnackBar(
          content: Text('New message: ${notification['message']}'),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
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

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _apiClient.get('/api/messages/${widget.userId}');
      final httpMessages =
          (response['messages'] as List).cast<Map<String, dynamic>>();
      print('Fetched messages: $httpMessages');
      setState(() {
        _messages = httpMessages;
        _isLoading = false;
      });
      _scroll();
    } catch (e) {
      String errorMsg = 'Failed to load messages';
      if (e is dio.DioException) {
        errorMsg +=
            ': ${e.response?.statusCode} ${e.response?.data['message'] ?? e.message}';
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
      setState(() {
        _messages.add({
          '_id': tempId,
          'senderId': _userId,
          'recipientId': widget.userId,
          'content': content,
          'status': 'sent',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        });
      });
      _scroll();

      final response = await _apiClient.post('/api/messages', {
        'recipientId': widget.userId,
        'content': content,
      });

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
      HapticFeedback.selectionClick();
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        _messages.removeWhere((m) => m['_id'] == tempId);
        _errorMessage = 'Failed to send: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: ${e.toString()}'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _scroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: isDark ? _surfaceDark : _surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: isDark ? _textTertiary : _textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: isDark ? _textTertiary : _textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? _surfaceDark : _surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isDark),
            Expanded(child: _buildMessageList(context, isDark)),
            _buildInputArea(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? _surfaceDark : _surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? _dividerDark : _divider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : _textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
            padding: const EdgeInsets.all(12),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? _primary : _primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.userName[0].toUpperCase(),
                style: TextStyle(
                  color: isDark ? Colors.white : _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.userName,
              style: TextStyle(
                color: isDark ? Colors.white : _textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _accent,
          strokeWidth: 2,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(
                color: isDark ? _textTertiary : _textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _fetch,
              style: TextButton.styleFrom(
                foregroundColor: _accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet',
          style: TextStyle(
            color: isDark ? _textTertiary : _textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    // Group messages by date
    final groupedMessages = <String, List<Map<String, dynamic>>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('HH:mm');

    for (var message in _messages) {
      DateTime createdAt;
      try {
        createdAt = DateTime.parse(message['timestamp'] ??
                message['createdAt'] ??
                DateTime.now().toIso8601String())
            .toLocal();
      } catch (e) {
        print(
            'Error parsing timestamp: ${message['timestamp'] ?? message['createdAt']}');
        createdAt = DateTime.now();
      }
      final messageDate =
          DateTime(createdAt.year, createdAt.month, createdAt.day);
      String dateKey;

      if (messageDate == today) {
        dateKey = 'Today';
      } else if (messageDate == yesterday) {
        dateKey = 'Yesterday';
      } else {
        dateKey = dateFormat.format(createdAt);
      }

      if (!groupedMessages.containsKey(dateKey)) {
        groupedMessages[dateKey] = [];
      }
      groupedMessages[dateKey]!.add(message);
    }

    final items = <Widget>[];
    groupedMessages.forEach((dateKey, messages) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (isDark ? _textTertiary : _textSecondary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dateKey,
                style: TextStyle(
                  color: isDark ? _textTertiary : _textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      );

      for (var message in messages) {
        DateTime createdAt;
        try {
          createdAt = DateTime.parse(message['timestamp'] ??
                  message['createdAt'] ??
                  DateTime.now().toIso8601String())
              .toLocal();
        } catch (e) {
          print(
              'Error parsing timestamp: ${message['timestamp'] ?? message['createdAt']}');
          createdAt = DateTime.now();
        }
        final isSentByUser = message['senderId'] != widget.userId;
        final formattedTime = timeFormat.format(createdAt);

        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              mainAxisAlignment: isSentByUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSentByUser
                        ? _accent
                        : (isDark ? _primary : _primaryLight),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['content'] ?? '',
                        style: TextStyle(
                          color: isSentByUser
                              ? Colors.white
                              : (isDark ? Colors.white : _textPrimary),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: isSentByUser
                                  ? Colors.white.withOpacity(0.7)
                                  : (isDark ? _textTertiary : _textSecondary),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (isSentByUser && message['status'] != 'sent') ...[
                            const SizedBox(width: 4),
                            Icon(
                              message['status'] == 'read'
                                  ? Icons.done_all
                                  : Icons.done,
                              size: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: items,
    );
  }

  Widget _buildInputArea(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? _surfaceDark : _surface,
        border: Border(
          top: BorderSide(
            color: isDark ? _dividerDark : _divider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? _primary : _primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(
                  color: isDark ? Colors.white : _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: TextStyle(
                    color: isDark ? _textTertiary : _textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _send(),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                minLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
