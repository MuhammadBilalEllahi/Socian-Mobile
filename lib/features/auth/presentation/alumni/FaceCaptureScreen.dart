import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socian/shared/services/api_client.dart';

class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  String? _imagePath;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await Permission.camera.request();

    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras
          .firstWhere((cam) => cam.lensDirection == CameraLensDirection.front),
      ResolutionPreset.high,
    );
    await _controller.initialize();
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
      _imagePath = picture.path;

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

    data['file'] = await MultipartFile.fromFile(
      imageFile.path,
      filename:
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}',
      contentType:
          MediaType('image', path.extension(imageFile.path).substring(1)),
    );

    await apiClient.postFormData(
        '/api/auth/alumni/verification/live-picture', data);
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
