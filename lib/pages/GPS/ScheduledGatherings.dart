import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/services/secure_storage_service.dart';
import 'package:socian/shared/utils/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ScheduledGatherings extends ConsumerStatefulWidget {
  const ScheduledGatherings({super.key});

  @override
  ConsumerState<ScheduledGatherings> createState() =>
      _ScheduledGatheringsState();
}

class _ScheduledGatheringsState extends ConsumerState<ScheduledGatherings>
    with SingleTickerProviderStateMixin {
  final String baseUrl = ApiConstants.baseUrl;
  final ApiClient _apiClient = ApiClient();
  final List<Map<String, dynamic>> _upcomingGatherings = [];
  final List<Map<String, dynamic>> _currentGatherings = [];
  final List<Map<String, dynamic>> _previousGatherings = [];
  String? errorMessage;
  bool _isLoading = true;
  IO.Socket? _socket;
  String? _userId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserId();
    _fetchGatherings();
    _initSocket();
  }

  Future<void> _loadUserId() async {
    try {
      final token = await SecureStorageService.instance.getToken();
      if (token != null) {
        final decoded = JwtDecoder.decode(token);
        setState(() {
          _userId = decoded['_id']?.toString();
        });
      }
    } catch (e) {
      debugPrint('Error decoding token: $e');
    }
  }

  void _initSocket() {
    try {
      _socket = IO.io(baseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
      });

      _socket?.connect();

      _socket?.on('connect', (_) {
        debugPrint('Connected to Socket.IO server');
      });

      _socket?.on('reconnect', (_) {
        debugPrint('Reconnected to Socket.IO server');
      });

      _socket?.on('gatheringUpdate', (data) {
        debugPrint('Gathering update received: $data');
        _fetchGatherings();
      });

      _socket?.on('attendanceUpdate', (data) {
        debugPrint('Attendance update received: $data');
        final gatheringId = data['gatheringId']?.toString();
        final attendees = data['attendees'] as List<dynamic>?;

        if (gatheringId == null || attendees == null) return;

        setState(() {
          final currentIndex = _currentGatherings
              .indexWhere((g) => g['_id']?.toString() == gatheringId);
          if (currentIndex != -1) {
            _currentGatherings[currentIndex]['attendees'] = attendees;
          }

          final upcomingIndex = _upcomingGatherings
              .indexWhere((g) => g['_id']?.toString() == gatheringId);
          if (upcomingIndex != -1) {
            _upcomingGatherings[upcomingIndex]['attendees'] = attendees;
          }
        });
      });

      _socket?.on('error', (error) => debugPrint('Socket error: $error'));
      _socket?.on('disconnect',
          (_) => debugPrint('Disconnected from Socket.IO server'));
    } catch (e) {
      debugPrint('Socket initialization error: $e');
    }
  }

  Future<void> _fetchGatherings() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _apiClient.getList('/api/gatherings/all');

      setState(() {
        _upcomingGatherings.clear();
        _currentGatherings.clear();
        _previousGatherings.clear();

        final now = DateTime.now();

        final gatherings =
            (response as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

        for (var gathering in gatherings) {
          final startTime =
              DateTime.tryParse(gathering['startTime']?.toString() ?? '')
                  ?.toLocal();
          final endTime =
              DateTime.tryParse(gathering['endTime']?.toString() ?? '')
                  ?.toLocal();

          if (startTime == null || endTime == null) {
            debugPrint('Invalid time for gathering: ${gathering['title']}');
            continue;
          }

          debugPrint('Gathering: ${gathering['title']}');
          debugPrint('Now: $now');
          debugPrint('Start Time: $startTime');
          debugPrint('End Time: $endTime');

          if (startTime.isAfter(now)) {
            _upcomingGatherings.add(gathering);
            debugPrint('Added to Upcoming');
          } else if (startTime.isBefore(now) && endTime.isAfter(now)) {
            _currentGatherings.add(gathering);
            debugPrint('Added to Current');
          } else if (endTime.isBefore(now)) {
            _previousGatherings.add(gathering);
            debugPrint('Added to Previous');
          }
        }

        debugPrint('Upcoming: ${_upcomingGatherings.length}');
        debugPrint('Current: ${_currentGatherings.length}');
        debugPrint('Previous: ${_previousGatherings.length}');

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching gatherings: $e');
      setState(() {
        errorMessage = e is ApiException ? e.message : 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteGathering(String gatheringId) async {
    try {
      final response = await _apiClient.delete('/api/gatherings/$gatheringId');
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gathering deleted successfully')),
        );
        await _fetchGatherings();
      }
    } catch (e) {
      debugPrint('Error deleting gathering: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to delete gathering: ${e is ApiException ? e.message : e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final foreground =
        isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final muted =
        isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA3A3A3) : const Color(0xFF737373);
    final border =
        isDarkMode ? const Color(0xFF262626) : const Color(0xFFE5E5E5);
    final accent =
        isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA);
    final primaryColor =
        isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final cardBackground =
        isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    final cardBorder =
        isDarkMode ? const Color(0xFF262626) : const Color(0xFFE5E5E5);
    final cardShadow = isDarkMode
        ? Colors.black.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'Your Gatherings',
          style: TextStyle(
            color: foreground,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: foreground),
            onPressed: _fetchGatherings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: mutedForeground,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.3,
          ),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Current'),
            Tab(text: 'Previous'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading gatherings...',
                    style: TextStyle(
                      color: mutedForeground,
                      fontSize: 14,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: mutedForeground,
                          fontSize: 14,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: background,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _fetchGatherings,
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGatheringList(
                      gatherings: _upcomingGatherings,
                      emptyMessage: 'No upcoming gatherings',
                      emptyIcon: Icons.event_rounded,
                      foreground: foreground,
                      mutedForeground: mutedForeground,
                      accent: cardBackground,
                      border: cardBorder,
                      isUpcoming: true,
                      cardShadow: cardShadow,
                    ),
                    _buildGatheringList(
                      gatherings: _currentGatherings,
                      emptyMessage: 'No current gatherings',
                      emptyIcon: Icons.event_available,
                      foreground: foreground,
                      mutedForeground: mutedForeground,
                      accent: cardBackground,
                      border: cardBorder,
                      isUpcoming: true,
                      cardShadow: cardShadow,
                    ),
                    _buildGatheringList(
                      gatherings: _previousGatherings,
                      emptyMessage: 'No previous gatherings',
                      emptyIcon: Icons.history,
                      foreground: foreground,
                      mutedForeground: mutedForeground,
                      accent: cardBackground,
                      border: cardBorder,
                      isUpcoming: false,
                      cardShadow: cardShadow,
                    ),
                  ],
                ),
    );
  }

  Widget _buildGatheringList({
    required List<Map<String, dynamic>> gatherings,
    required String emptyMessage,
    required IconData emptyIcon,
    required Color foreground,
    required Color mutedForeground,
    required Color accent,
    required Color border,
    required bool isUpcoming,
    required Color cardShadow,
  }) {
    if (gatherings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 48,
              color: mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: mutedForeground,
                fontSize: 14,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchGatherings,
      color: foreground,
      backgroundColor: accent,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: gatherings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final gathering = gatherings[index];
          final startTime =
              DateTime.tryParse(gathering['startTime']?.toString() ?? '')
                      ?.toLocal() ??
                  DateTime.now();
          final endTime =
              DateTime.tryParse(gathering['endTime']?.toString() ?? '')
                      ?.toLocal() ??
                  DateTime.now();
          final now = DateTime.now();
          final isActive = now.isAfter(startTime) && now.isBefore(endTime);
          final isCreator = _userId != null &&
              _userId ==
                  (gathering['creatorId'] is Map
                      ? gathering['creatorId']['_id']?.toString()
                      : gathering['creatorId']?.toString());
          final attendeesCount =
              (gathering['attendees'] as List<dynamic>?)?.length ?? 0;
          final societyName = gathering['societyId'] is Map
              ? gathering['societyId']['name']?.toString()
              : null;
          final creatorName = gathering['creatorId'] is Map
              ? gathering['creatorId']['name']?.toString()
              : gathering['creatorId']?.toString() ?? 'Unknown';

          return Container(
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: cardShadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GatheringDetailScreen(
                      gathering: Gathering.fromJson(gathering),
                      socket: _socket,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            gathering['title']?.toString() ?? 'Untitled',
                            style: TextStyle(
                              color: foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCreator)
                          IconButton(
                            icon: Icon(Icons.more_vert,
                                size: 20, color: mutedForeground),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: accent,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                                builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.delete,
                                          color: Colors.red),
                                      title: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                      onTap: () {
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: accent,
                                            title:
                                                const Text('Delete Gathering'),
                                            content: const Text(
                                                'Are you sure you want to delete this gathering?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  _deleteGathering(
                                                      gathering['_id']
                                                              ?.toString() ??
                                                          '');
                                                },
                                                child: const Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (gathering['description'] != null &&
                        gathering['description'].toString().isNotEmpty)
                      Column(
                        children: [
                          Text(
                            gathering['description']?.toString() ?? '',
                            style: TextStyle(
                              color: mutedForeground,
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    Text(
                      'Hosted by ${societyName ?? creatorName}',
                      style: TextStyle(
                        color: mutedForeground,
                        fontSize: 14,
                        letterSpacing: -0.3,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: mutedForeground,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd, yyyy').format(startTime),
                          style: TextStyle(
                            color: mutedForeground,
                            fontSize: 14,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: mutedForeground,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('hh:mm a').format(startTime)} - ${DateFormat('hh:mm a').format(endTime)}',
                          style: TextStyle(
                            color: mutedForeground,
                            fontSize: 14,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isUpcoming
                                ? (isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.1))
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isUpcoming
                                  ? (isActive
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.blue.withOpacity(0.2))
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            isUpcoming
                                ? (isActive ? 'Active Now' : 'Upcoming')
                                : 'Completed',
                            style: TextStyle(
                              color: isUpcoming
                                  ? (isActive ? Colors.green : Colors.blue)
                                  : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isUpcoming && isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.group,
                                    size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  '$attendeesCount attending',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}

class GatheringDetailScreen extends StatefulWidget {
  final Gathering gathering;
  final IO.Socket? socket;

  const GatheringDetailScreen(
      {super.key, required this.gathering, this.socket});

  @override
  State<GatheringDetailScreen> createState() => _GatheringDetailScreenState();
}

class _GatheringDetailScreenState extends State<GatheringDetailScreen>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  bool _isWithinRadius = false;
  bool _isGatheringActive = false;
  bool _hasMarkedAttendance = false;
  List<Attendee> _attendees = [];
  Timer? _locationUpdateTimer;
  final Map<String, BitmapDescriptor> _userIcons = {};
  AnimationController? _animationController;
  Animation<double>? _animation;
  String? _userId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _attendees = widget.gathering.attendees;
    _checkGatheringStatus();
    _getUserLocation();
    _initSocket();
    _initAnimation();
    _loadUserId();
    _loadUserName();
    _generateUserIcons();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    _animationController!.forward();
  }

  Future<void> _loadUserId() async {
    try {
      final userId = await _getUserId();
      setState(() {
        _userId = userId;
      });
    } catch (e) {
      debugPrint('Error loading user ID: $e');
    }
  }

  Future<void> _loadUserName() async {
    try {
      final token = await SecureStorageService.instance.getToken();
      if (token != null) {
        final decoded = JwtDecoder.decode(token);
        setState(() {
          _userName = decoded['name']?.toString() ?? 'Unknown';
        });
      }
    } catch (e) {
      debugPrint('Error loading user name: $e');
    }
  }

  Future<void> _generateUserIcons() async {
    if (_userId != null) {
      _userIcons[_userId!] = await _createDotIcon(_generateColor(_userId!));
    }

    for (var attendee in _attendees) {
      if (!_userIcons.containsKey(attendee.userId)) {
        _userIcons[attendee.userId] =
            await _createDotIcon(_generateColor(attendee.userId));
      }
    }
    setState(() {});
  }

  Color _generateColor(String userId) {
    final random = Random(userId.hashCode);
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  Future<BitmapDescriptor> _createDotIcon(Color color) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = color;
    canvas.drawCircle(const Offset(12, 12), 12, paint);
    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(24, 24);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<String?> _getUserId() async {
    final token = await SecureStorageService.instance.getToken();
    if (token != null) {
      final decoded = JwtDecoder.decode(token);
      return decoded['_id']?.toString();
    }
    return null;
  }

  void _initSocket() {
    widget.socket?.on('attendanceUpdate', (data) {
      debugPrint('Attendance update in detail screen: $data');
      final gatheringId = data['gatheringId']?.toString();
      final attendees = data['attendees'] as List<dynamic>?;

      if (gatheringId == widget.gathering.id && attendees != null) {
        setState(() {
          _attendees = attendees
              .map((a) => Attendee.fromJson(a as Map<String, dynamic>))
              .toList();
          _generateUserIcons();
        });
      }
    });
  }

  void _checkGatheringStatus() {
    final now = DateTime.now();
    setState(() {
      _isGatheringActive = now.isAfter(widget.gathering.startTime) &&
          now.isBefore(widget.gathering.endTime);
      debugPrint('Gathering Active: $_isGatheringActive');
      debugPrint('Now: $now');
      debugPrint('Start: ${widget.gathering.startTime}');
      debugPrint('End: ${widget.gathering.endTime}');
    });
    if (_isGatheringActive && _hasMarkedAttendance) {
      _startLocationUpdates();
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _checkIfWithinRadius();
    } catch (e) {
      debugPrint('Error getting user location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  void _checkIfWithinRadius() {
    if (_userLocation == null) return;

    final distance = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      widget.gathering.location.latitude,
      widget.gathering.location.longitude,
    );

    setState(() {
      _isWithinRadius = distance <= widget.gathering.radius;
    });
  }

  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isGatheringActive || !_hasMarkedAttendance) {
        timer.cancel();
        return;
      }

      try {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium);
        final newLocation = LatLng(position.latitude, position.longitude);
        final distance = Geolocator.distanceBetween(
          newLocation.latitude,
          newLocation.longitude,
          widget.gathering.location.latitude,
          widget.gathering.location.longitude,
        );

        if (distance > widget.gathering.radius) {
          setState(() {
            _userLocation = null;
            _isWithinRadius = false;
            _hasMarkedAttendance = false;
          });
          _locationUpdateTimer?.cancel();
          await _updateLocation(newLocation.latitude, newLocation.longitude);
          return;
        }

        setState(() {
          _userLocation = newLocation;
          _isWithinRadius = true;
        });
        await _updateLocation(newLocation.latitude, newLocation.longitude);
      } catch (e) {
        debugPrint('Error updating location: $e');
      }
    });
  }

  Future<void> _updateLocation(double latitude, double longitude) async {
    try {
      final data = {
        'latitude': latitude,
        'longitude': longitude,
      };
      final response = await _apiClient.post(
        '/api/gatherings/${widget.gathering.id}/update-location',
        data,
        headers: {'Content-Type': 'application/json'},
      );
      if (response['removed'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have left the gathering radius')),
        );
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  Future<void> _markAttendance() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (_userLocation == null) {
        throw Exception('Location not available');
      }

      if (!_isWithinRadius) {
        throw Exception('You are not within the gathering radius');
      }

      final data = {
        'userId': userId,
        'latitude': _userLocation!.latitude,
        'longitude': _userLocation!.longitude,
      };

      final response = await _apiClient.post(
        '/api/gatherings/${widget.gathering.id}/attend',
        data,
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        _hasMarkedAttendance = true;
        _attendees = (response['attendees'] as List<dynamic>?)
                ?.map((a) => Attendee.fromJson(a as Map<String, dynamic>))
                .toList() ??
            _attendees;
      });

      _startLocationUpdates();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully')),
      );
    } catch (e) {
      debugPrint('Error marking attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final background = isDarkMode
        ? const Color(0xFF09090B).withOpacity(0.9)
        : Colors.white.withOpacity(0.9);
    final gatheringLocation = LatLng(
      widget.gathering.location.latitude,
      widget.gathering.location.longitude,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.gathering.title,
          style: TextStyle(
            color: foreground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Full-screen map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: gatheringLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(gatheringLocation),
              );
            },
            markers: {
              if (_userLocation != null &&
                  _isWithinRadius &&
                  _hasMarkedAttendance)
                Marker(
                  markerId: const MarkerId('user_location'),
                  position: _userLocation!,
                  icon: _userIcons[_userId] ?? BitmapDescriptor.defaultMarker,
                  infoWindow: InfoWindow(title: _userName ?? 'You'),
                ),
              ..._attendees.map(
                (attendee) => Marker(
                  markerId: MarkerId(attendee.userId),
                  position: LatLng(
                      attendee.location.latitude, attendee.location.longitude),
                  icon: _userIcons[attendee.userId] ??
                      BitmapDescriptor.defaultMarker,
                  infoWindow: InfoWindow(title: attendee.name),
                ),
              ),
            },
            circles: {
              Circle(
                circleId: const CircleId('radius'),
                center: gatheringLocation,
                radius: widget.gathering.radius.toDouble(),
                fillColor: Colors.blue.withOpacity(0.2),
                strokeColor: Colors.blue,
                strokeWidth: 2,
              ),
            },
          ),
          // Gradient overlay for readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    isDarkMode ? Colors.black54 : Colors.white54,
                  ],
                ),
              ),
            ),
          ),
          // Compact info card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: FadeTransition(
              opacity: _animation!,
              child: GestureDetector(
                onTap: () {
                  // Optional: Expand card on tap (not implemented for minimal design)
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.gathering.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${_attendees.length} attending',
                            style: TextStyle(
                              fontSize: 12,
                              color: mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hosted by ${widget.gathering.societyName ?? widget.gathering.creatorName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedForeground,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat('hh:mm a').format(widget.gathering.startTime)} - ${DateFormat('hh:mm a').format(widget.gathering.endTime)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      if (_isGatheringActive && !_hasMarkedAttendance)
                        const SizedBox(height: 12),
                      if (_isGatheringActive && !_hasMarkedAttendance)
                        Center(
                          child: ElevatedButton(
                            onPressed: _isWithinRadius ? _markAttendance : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              "I'm Here",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _locationUpdateTimer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }
}

class Gathering {
  final String id;
  final String title;
  final String? description;
  final Location location;
  final int radius;
  final DateTime startTime;
  final DateTime endTime;
  final List<Attendee> attendees;
  final String creatorId;
  final String creatorName;
  final String? societyId;
  final String? societyName;

  Gathering({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.radius,
    required this.startTime,
    required this.endTime,
    required this.attendees,
    required this.creatorId,
    required this.creatorName,
    this.societyId,
    this.societyName,
  });

  factory Gathering.fromJson(Map<String, dynamic> json) {
    return Gathering(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      description: json['description']?.toString(),
      location:
          Location.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      radius: int.tryParse(json['radius']?.toString() ?? '') ?? 100,
      startTime:
          DateTime.tryParse(json['startTime']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
      endTime:
          DateTime.tryParse(json['endTime']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
      attendees: (json['attendees'] as List<dynamic>?)
              ?.map((a) => Attendee.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      creatorId: (json['creatorId'] is Map
              ? json['creatorId']['_id']?.toString()
              : json['creatorId']?.toString()) ??
          '',
      creatorName: (json['creatorId'] is Map
              ? json['creatorId']['name']?.toString()
              : json['creatorId']?.toString()) ??
          'Unknown',
      societyId: (json['societyId'] is Map
          ? json['societyId']['_id']?.toString()
          : json['societyId']?.toString()),
      societyName: (json['societyId'] is Map
          ? json['societyId']['name']?.toString()
          : null),
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
    );
  }
}

class Attendee {
  final String userId;
  final String name;
  final Location location;
  final DateTime timestamp;

  Attendee({
    required this.userId,
    required this.name,
    required this.location,
    required this.timestamp,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      location:
          Location.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
    );
  }
}
