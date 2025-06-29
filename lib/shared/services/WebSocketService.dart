import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:socian/shared/utils/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Singleton WebSocketService for robust, single-connection management using socket_io_client
class WebSocketService with WidgetsBindingObserver {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  IO.Socket? _socket;
  StreamController<dynamic>? _messageController;
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _url;
  Timer? _reconnectTimer;

  /// Connect to the WebSocket server (idempotent)
  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      // Already connected or connecting
      return;
    }
    _isConnecting = true;
    _url = ApiConstants.baseUrl;
    try {
      _socket = IO.io(_url!, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': false, // We'll handle reconnection manually
      });
      _socket!.connect();
      _socket!.on('connect', (_) {
        _isConnected = true;
        _isConnecting = false;
      });
      _socket!.on('disconnect', (_) {
        _onDisconnected();
      });
      _socket!.on('connect_error', (error) {
        _onDisconnected();
      });
      _socket!.on('error', (error) {
        _onDisconnected();
      });
      _messageController ??= StreamController.broadcast();
      _socket!.on('message', (data) {
        _messageController?.add(data);
      });
    } catch (e) {
      _isConnecting = false;
      _onDisconnected();
    }
  }

  /// Send a message through the WebSocket
  void sendMessageInDiscussion(dynamic message) {
    if (_isConnected && _socket != null) {
      _socket!.emit('message', message);
    }
  }

  void receiveMessageInDiscussion() {
    if (_isConnected && _socket != null) {
      _socket!.on('message', (message) {
        _messageController?.add(message);
        debugPrint("----------message: $message");
      });
    }
  }

  void joinDiscussion(String discussionId) {
    if (_isConnected && _socket != null) {
      _socket!.emit('joinDiscussion', discussionId);
      _socket!.on('users', (users) {
        debugPrint("----------users: $users");
      });
      _socket!.on('usersCount', (usersCount) {
        debugPrint("----------usersCount: $usersCount");
        _messageController?.add({'usersCount': usersCount});
      });
    }
  }

  void removeUserFromDiscussion(String discussionId) {
    if (_isConnected && _socket != null) {
      _socket!.emit('removeUserFromDiscussion', discussionId);
      _socket!.on('usersCount', (usersCount) {
        debugPrint("----------usersCount after remove: $usersCount");
        _messageController?.add({'usersCount': usersCount});
      });
    }
  }

  void joinNotification(String userId) {
    log("Joining notification room for user: $userId, joinNotifications");
    if (_isConnected && _socket != null) {
      _socket!.emit('joinNotifications', userId);
      debugPrint(" Joined notification room for user: $userId");

      // Optional: Listen to new notifications
      _socket!.on('newNotification', (notification) {
        debugPrint(" New notification received: $notification");
        _messageController?.add({'newNotification': notification});
      });
    }
  }

  /// Listen to incoming messages
  Stream<dynamic> get messages {
    _messageController ??= StreamController.broadcast();
    return _messageController!.stream;
  }

  /// Disconnect and clean up
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isConnected = false;
    _isConnecting = false;
    _socket?.dispose();
    _socket = null;
    _messageController?.close();
    _messageController = null;
  }

  /// Handle disconnection and schedule reconnection
  void _onDisconnected() {
    _isConnected = false;
    _isConnecting = false;
    _socket?.dispose();
    _socket = null;
    // Don't close the messageController so listeners stay alive
    if (_url != null && _reconnectTimer == null) {
      _reconnectTimer = Timer(const Duration(seconds: 3), () {
        _reconnectTimer = null;
        connect();
      });
    }
  }

  /// App lifecycle awareness
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Try to reconnect if not connected
      if (!_isConnected && _url != null) {
        connect();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Optionally disconnect or pause connection
      // disconnect();
    }
  }

  /// Dispose (call on app exit)
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
  }
}
