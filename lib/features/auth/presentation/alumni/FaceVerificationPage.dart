import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FaceVerificationPage extends StatefulWidget {
  const FaceVerificationPage({super.key});

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  XFile? _video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Face Verification',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(
                                File(_image!.path),
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _image == null
                        ? const Center(
                            child: Text('Upload Live Selfie',
                                style: TextStyle(color: Colors.black)))
                        : null,
                  ),
                  _faceOverlayGuide()
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickImage,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Upload Selfie'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _recordVideo,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Record Video'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _recordVideo() async {
    final video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      setState(() {
        _video = video;
      });
    }
  }

  Widget _faceOverlayGuide() {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          border:
              Border.all(color: Colors.greenAccent.withOpacity(0.6), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal:
                    BorderSide(color: Colors.red.withOpacity(0.7), width: 1),
              ),
            ),
            child: const Center(
              child: Text(
                'Align face within bounds (Top 20%, Bottom 20%)',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
