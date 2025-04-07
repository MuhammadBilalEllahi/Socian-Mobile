import 'dart:async';
import 'dart:io';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DiscussionView extends StatefulWidget {
  const DiscussionView({super.key});

  @override
  State<DiscussionView> createState() => _DiscussionViewState();
}

class _DiscussionViewState extends State<DiscussionView> {
  final ApiClient apiClient = ApiClient();
  late String id;
  late String type;
  late String subjectId;
  late Future<Map<String, dynamic>> pastPapers = Future.value({});
  Map<String, dynamic>? _cachedSelectivePastPapers;
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> papers = [];
  bool isLoading = true;
  bool isReady = false;
  int? pages;
  String? currentPdfUrl;
  String? currentPdfName;
  String? currentPdfYear;
  File? pdfFile;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<File> createFileOfPdfUrl(String url) async {
    Completer<File> completer = Completer();
    debugPrint("Start downloading PDF from: $url");
    try {
      final filename = url.substring(url.lastIndexOf("/") + 1);
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      debugPrint("Saving PDF to: ${dir.path}/$filename");
      File file = File("${dir.path}/$filename");
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      debugPrint("Error downloading PDF: $e");
      throw Exception('Error downloading PDF file: $e');
    }
    return completer.future;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (routeArgs?.containsKey('_id') ?? false) {
      id = routeArgs!['_id'];
      type = routeArgs['paperType'];
      subjectId = routeArgs['subjectId']; 
      if (_cachedSelectivePastPapers == null) {
        fetchSelectivePastPapers(id);
      }
    } else {
      setState(() {
        pastPapers = Future.error('Invalid route arguments or missing ID');
      });
    }
  }

  Future<void> fetchSelectivePastPapers(String id) async {
    try {
      final response = await apiClient.get('/api/pastpaper/${type.toLowerCase()}/$subjectId');
      setState(() {
        _cachedSelectivePastPapers = response;
        if (response['papers'] != null) {
          for (var yearGroup in response['papers']) {
            if (yearGroup['papers'] != null) {
              for (var paper in yearGroup['papers']) {
                papers.add(paper);
              }
            }
          }
          if (papers.isNotEmpty) {
            final firstPaper = papers[0];
            debugPrint("First paper: $firstPaper");
            currentPdfUrl = "${ApiConstants.baseUrl}/api/uploads/${firstPaper['file']?['url']}";
            currentPdfName = firstPaper['name'];
            currentPdfYear = firstPaper['academicYear']?.toString();
            debugPrint(" ${ApiConstants.baseUrl} ==========Current PDF URL: $currentPdfUrl");
            if (currentPdfUrl != null) {
              createFileOfPdfUrl(currentPdfUrl!).then((file) {
                setState(() {
                  pdfFile = file;
                });
              });
            }
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        pastPapers = Future.error('Failed to fetch past papers: $e');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Discussion',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (currentPdfName != null && currentPdfYear != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFF2D2D2D),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentPdfName!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Year: $currentPdfYear',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14
                                ),
                              ),
                              if (pages != null)
                                Text(
                                  'Page ${currentPage + 1} of $pages',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: papers.isEmpty
                      ? ListView.builder(
                          itemCount: papers.length,
                          itemBuilder: (context, index) {
                            final paper = papers[index];
                            return ListTile(
                              title: Text(
                                '${paper['name']} (${paper['academicYear']})',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Type: ${paper['type']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              onTap: () async {
                                if (paper['file'] != null && paper['file']['url'] != null) {
                                  setState(() {
                                    currentPdfUrl = "${ApiConstants.baseUrl}/api/uploads/${paper['file']['url']}";
                                    debugPrint("Current PDF URL: $currentPdfUrl");
                                    currentPdfName = paper['name'];
                                    currentPdfYear = paper['academicYear']?.toString();
                                  });
                                  if (currentPdfUrl != null) {
                                    final file = await createFileOfPdfUrl(currentPdfUrl!);
                                    setState(() {
                                      pdfFile = file;
                                    });
                                  }
                                }
                              },
                            );
                          },
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: papers.length,
                          itemBuilder: (context, index) {
                            if (pdfFile == null) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              child: PDFView(
                                filePath: pdfFile!.path,
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
                                  });
                                },
                                onPageChanged: (page, total) {
                                  setState(() {
                                    currentPage = page!;
                                  });
                                },
                                onError: (error) {
                                  debugPrint("Error loading PDF: $error");
                                },
                                onViewCreated: (PDFViewController controller) {
                                  // You can store the controller for additional control if needed
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
