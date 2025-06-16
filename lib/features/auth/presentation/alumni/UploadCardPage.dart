import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path/path.dart' as path;
import 'package:socian/core/utils/constants.dart';
import 'package:socian/features/auth/presentation/alumni/FaceCaptureScreen.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/widgets/my_dropdown.dart';
import 'package:socian/shared/widgets/my_snackbar.dart';

class UploadCardPage extends ConsumerStatefulWidget {
  const UploadCardPage({super.key});

  @override
  ConsumerState<UploadCardPage> createState() => _UploadCardPageState();
}

class _UploadCardPageState extends ConsumerState<UploadCardPage> {
  File? frontImage;
  File? backImage;

  String? selectedCard;

  final List<Map<String, dynamic>> cardTypes = [
    {'name': 'Student Card', '_id': 'studentCard'},
    {'name': 'Student Bus Card', '_id': 'studentBusCard'},
    {'name': 'Transcript', '_id': 'transcript'},
    {'name': 'Degree', '_id': 'degree'},
    {'name': 'Other', '_id': 'other'},
  ];

  @override
  void initState() {
    super.initState();

    final authUser = ref.read(authProvider).user;
    if (authUser?['role'] == AppRoles.alumni) {
      print("The user is $authUser");
      print("verification ${authUser?['verification']}");
      if (authUser!['verification']['studentCardUploaded'] == true &&
          authUser['verification']['livePictureUploaded'] == true) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.alumniHome, (route) => false);
      }
      if (authUser['verification']['studentCardUploaded'] == true &&
          !authUser['verification']['livePictureUploaded']) {
        Navigator.pushReplacementNamed(context, AppRoutes.alumniUploadCard);
      }
      // if (authUser!['verification']['livePictureUploaded'] == true) {
      //   return MaterialPageRoute(
      //     builder: (_) => const FaceCaptureScreen(),
      //     settings: const RouteSettings(name: AppRoutes.alumniLivePicture),
      //   );
      // }
    }
  }

  Future<void> _openCamera(bool isFrontSide, BuildContext context) async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
    );

    final controller = CameraController(camera, ResolutionPreset.high);
    await controller.initialize();

    // final captured = await Navigator.pushNamed(
    //   context,
    //   AppRoutes.alumniLivePicture,
    // );
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

    if (selectedCard == null) {
      showSnackbar(context, "Please select a document type", isError: true);
      return false;
    }
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
      ],
      'docType': selectedCard,
    };

    final response = await apiClient.postFormData(
        '/api/auth/alumni/verification/card', formData);

    print("RESPONSE upload Inage $response");
    if (response['access_token'] != null) {
      final token = response['access_token'];
      final user = JwtDecoder.decode(token);

      log("The user is in UploadCard $user");

      await ref.read(authProvider.notifier).updateAuthState(user, token);
      return true;
    } else {
      return false;
    }
  }

  double _getCardAspectRatio() {
    switch (selectedCard) {
      case 'studentCard':
      case 'studentBusCard':
        return 1.6; // Standard ID card
      case 'degree':
      case 'transcript':
        return 1.4; // More rectangular
      default:
        return 1.5; // Default
    }
  }

  Widget _imageTile(
      {required String title,
      required File? image,
      required VoidCallback onTap}) {
    final aspectRatio = _getCardAspectRatio();
    return InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
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
      appBar: AppBar(
        title: Text('Verify Your Identity',
            style: TextStyle(
                color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              MyDropdownField<String>(
                isLoading: false,
                value: selectedCard,
                items: cardTypes,
                label: "Select Document Type",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a document type';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    selectedCard = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                'images are not cropped, so dont worry about image preview',
                style: TextStyle(color: textColor.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 16),
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
              // const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

                      print("The data $data");
                      if (data == true) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const FaceCaptureScreen()));
                        // await Navigator.pushNamed(
                        //   context,
                        //   AppRoutes.alumniLivePicture,
                        // );
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
