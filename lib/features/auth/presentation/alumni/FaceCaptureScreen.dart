import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/utils/constants.dart';
import 'package:universal_io/io.dart';

class FaceCaptureScreen extends ConsumerStatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  ConsumerState<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends ConsumerState<FaceCaptureScreen> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  String? _imagePath;
  bool _isTakingPicture = false;
  bool _isCameraOpening = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _controller = CameraController(
        _cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front),
        ResolutionPreset.high,
      );
      _controller.initialize();
    }
  }

  Future<void> _initCamera() async {
    if (_isCameraOpening) return;
    _isCameraOpening = true;
    await Permission.camera.request();

    try {
      _cameras = await availableCameras();
      _controller = CameraController(
        _cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front),
        ResolutionPreset.high,
      );
      if (!_controller.value.isInitialized) {
        await _controller.initialize();
      }
    } finally {
      _isCameraOpening = false;
    }
    await _controller.setFlashMode(FlashMode.always);
    setState(() {});
  }

  void _simulateFrontFlash() async {
    showDialog(
      context: context,
      barrierColor: Colors.white,
      barrierDismissible: false,
      builder: (context) => const SizedBox.expand(),
    );
    await Future.delayed(const Duration(milliseconds: 300));
    Navigator.of(context).pop();
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized || _isTakingPicture) return;

    setState(() {
      _isTakingPicture = true;
    });
    _simulateFrontFlash();
    try {
      final XFile picture = await _controller.takePicture();
      File pictured = File(picture.path);

      _imagePath = picture.path;

      print("Picture $picture");
      print("_ImagePath $_imagePath");
      print("PICTURED $pictured");

      setState(() {
        _isTakingPicture = false;
      });

      _uploadImage(File(_imagePath!));
    } catch (e) {
      setState(() {
        _isTakingPicture = false;
      });
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final apiClient = ApiClient();
    final data = <String, dynamic>{};

    print("IS FILE HERE $imageFile AND ${imageFile.path}");

    final formData = {
      'files': [
        await MultipartFile.fromFile(
          imageFile.path,
          filename:
              '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}',
          contentType:
              MediaType('image', path.extension(imageFile.path).substring(1)),
        )
      ]
    };
    // data['file'] = await MultipartFile.fromFile(
    //   imageFile.path,
    //   filename:
    //       '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}',
    //   contentType:
    //       MediaType('image', path.extension(imageFile.path).substring(1)),
    // );

    print("FILE DATA $formData");
    final response = await apiClient.postFormData(
        '/api/auth/alumni/verification/live-picture', formData);

    if (response['access_token'] != null) {
      final token = response['access_token'];
      final user = JwtDecoder.decode(token);

      await ref.read(authProvider.notifier).updateAuthState(user, token);

      Navigator.pushNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center =
            Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        const radius = 160.0;

        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: CircleOverlayPainter(radius: radius, center: center),
          child: Center(
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller),
          _buildOverlay(),
          Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: Text(
              _isTakingPicture
                  ? 'Capturing... Please stay still'
                  : 'Align your face in the circle',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _isTakingPicture ? null : _takePicture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black, width: 1.2),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey.shade800,
                  disabledForegroundColor: Colors.grey.shade400,
                ),
                child: const Text('Use Face Data'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleOverlayPainter extends CustomPainter {
  final double radius;
  final Offset center;

  CircleOverlayPainter({required this.radius, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
