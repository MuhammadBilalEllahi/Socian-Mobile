import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socian/features/auth/presentation/alumni/FaceVerificationPage.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/widgets/my_snackbar.dart';

class UploadCardPage extends StatefulWidget {
  const UploadCardPage({super.key});

  @override
  State<UploadCardPage> createState() => _UploadCardPageState();
}

class _UploadCardPageState extends State<UploadCardPage> {
  File? frontImage;
  File? backImage;

  Future<void> _openCamera(bool isFrontSide, BuildContext context) async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
    );

    final controller = CameraController(camera, ResolutionPreset.high);
    await controller.initialize();

    final captured = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraCaptureScreen(controller: controller),
      ),
    );

    if (captured != null && captured is XFile) {
      final file = File(captured.path);
      setState(() {
        if (isFrontSide) {
          frontImage = file;
        } else {
          backImage = file;
        }
      });
    }

    await controller.dispose();
  }

  Future<bool> _uploadImages() async {
    final apiClient = ApiClient();
    final data = <String, dynamic>{};
    if (frontImage == null ||
        backImage == null ||
        !frontImage!.existsSync() ||
        !backImage!.existsSync()) {
      throw Exception(
        'Both front and back images must be uploaded before verification.',
      );
    }

    // data['files'][0] = frontImage;
    // data['files'][1]  = backImage;
    final formData = {
      'files': [
        await MultipartFile.fromFile(
          frontImage!.path,
          filename: path.basename(frontImage!.path),
          contentType:
              MediaType('image', path.extension(frontImage!.path).substring(1)),
        ),
        await MultipartFile.fromFile(
          backImage!.path,
          filename: path.basename(backImage!.path),
          contentType:
              MediaType('image', path.extension(backImage!.path).substring(1)),
        ),
      ]
    };

    final response = await apiClient.postFormData(
        '/api/auth/alumni/verification/card', formData);

    if (response['uploaded'] == true) {
      return true;
    } else {
      return false;
    }
  }

  Widget _imageTile(
      {required String title,
      required File? image,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(image,
                    fit: BoxFit.cover, width: double.infinity),
              )
            : Center(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500)),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final textColor =
        isDarkMode ? const Color.fromARGB(255, 194, 194, 194) : Colors.black;
    final backgroundColor =
        isDarkMode ? Colors.black : const Color.fromARGB(204, 255, 255, 255);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Verify Your Identity',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(
                "Front",
                style: TextStyle(color: textColor),
              ),
              _imageTile(
                  title: 'Upload Front Side of Card',
                  image: frontImage,
                  onTap: () => _openCamera(true, context)),
              const SizedBox(height: 20),
              Text(
                "Back",
                style: TextStyle(color: textColor),
              ),
              _imageTile(
                  title: 'Upload Back Side of Card',
                  image: backImage,
                  onTap: () => _openCamera(false, context)),
              const Spacer(),
              Text(
                'images are not cropped, so dont worry about image preview',
                style: TextStyle(color: textColor.withValues(alpha: 0.7)),
              ),
              TextButton(
                onPressed: () {
                  // Handle "Try another way"
                },
                child: Text('Try another way',
                    style: TextStyle(color: textColor.withValues(alpha: 0.7))),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final data = await _uploadImages();
                      if (data == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FaceVerificationPage()),
                        );
                      } else {
                        showSnackbar(
                            context, "Upload failed. Please try again.",
                            isError: true);
                      }
                    } catch (e) {
                      showSnackbar(context, "An error occurred: $e",
                          isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Upload (Recommended)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CameraCaptureScreen extends StatelessWidget {
  final CameraController controller;

  const CameraCaptureScreen({super.key, required this.controller});
  Widget _buildOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Choose horizontal card size by default
        final cardWidth = screenWidth * 0.8;
        final cardHeight = cardWidth * 0.63;

        return Stack(
          children: [
            // Overlay background
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            // Transparent cut-out card area
            Center(
              child: ClipPath(
                clipper:
                    CardClipper(cardWidth: cardWidth, cardHeight: cardHeight),
                child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  color: Colors.transparent,
                ),
              ),
            ),
            // Optional border to highlight card area
            Center(
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: controller.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(controller),
                _buildOverlay(),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.camera,
                          size: 48, color: Colors.white),
                      onPressed: () async {
                        final file = await controller.takePicture();
                        Navigator.pop(context, file);
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class CardClipper extends CustomClipper<Path> {
  final double cardWidth;
  final double cardHeight;

  CardClipper({required this.cardWidth, required this.cardHeight});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: cardWidth,
            height: cardHeight,
          ),
          const Radius.circular(12),
        ),
      );

    return path..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CardClipper oldClipper) {
    return oldClipper.cardWidth != cardWidth ||
        oldClipper.cardHeight != cardHeight;
  }
}
