import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewer extends StatefulWidget {
  final File? pdfFile;

  const PdfViewer({
    super.key,
    this.pdfFile,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  int? pages;
  int currentPage = 0;
  bool isReady = false;
  bool isLoading = false;
  String? error;

  @override
  void didUpdateWidget(PdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pdfFile != oldWidget.pdfFile) {
      setState(() {
        isReady = false;
        error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pdfFile == null) {
      return const Center(
        child: Text(
          'Select a paper to view',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    if (!widget.pdfFile!.existsSync()) {
      return const Center(
        child: Text(
          'PDF file not found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        PDFView(
          key: ValueKey(widget.pdfFile!.path),
          filePath: widget.pdfFile!.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          defaultPage: 0,
          fitPolicy: FitPolicy.BOTH,
          preventLinkNavigation: false,
          onRender: (_pages) {
            setState(() {
              pages = _pages;
              isReady = true;
              isLoading = false;
            });
          },
          onPageChanged: (page, total) {
            setState(() {
              currentPage = page!;
            });
          },
          onError: (error) {
            debugPrint("Error loading PDF: $error");
            setState(() {
              this.error = error.toString();
              isLoading = false;
            });
          },
          onViewCreated: (PDFViewController controller) {
            // You can store the controller for additional control if needed
          },
        ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        if (error != null)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading PDF: $error',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
