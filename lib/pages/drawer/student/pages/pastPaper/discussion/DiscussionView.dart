import 'dart:async';
import 'dart:io';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'PastPaperInfoCard.dart';
import 'PdfViewer.dart';
import 'commentSection/Comments.dart';

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
  String? currentPdfUrl;
  File? pdfFile;
  int currentIndex = 0;
  bool isCommentsVisible = true;
  bool isPdfExpanded = false;
  bool chatBoxVisible = false;
  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (_pageController.page != null) {
      final newIndex = _pageController.page!.round();
      if (newIndex != currentIndex) {
        loadPaper(newIndex);
      }
    }
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

  void loadPaper(int index) async {
    if (index >= 0 && index < papers.length) {
      final paper = papers[index];
      if (paper['file'] != null && paper['file']['url'] != null) {
        final url =
            "${ApiConstants.baseUrl}/api/uploads/${paper['file']['url']}";
        setState(() {
          currentPdfUrl = url;
          currentIndex = index;
        });
        if (currentPdfUrl != null) {
          final file = await createFileOfPdfUrl(currentPdfUrl!);
          setState(() {
            pdfFile = file;
          });
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
      final response = await apiClient
          .get('/api/pastpaper/${type.toLowerCase()}/$subjectId');
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
            loadPaper(0);
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
        actions: [
          IconButton(
            icon: Icon(
              isPdfExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isPdfExpanded = !isPdfExpanded;
                if (!isCommentsVisible && !isPdfExpanded) {
                  isCommentsVisible = !isCommentsVisible;
                } else if (isPdfExpanded) {
                  isCommentsVisible = false;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              isCommentsVisible ? Icons.comment : Icons.comment_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (isPdfExpanded && !isCommentsVisible) {
                  isPdfExpanded = false;
                }
                isCommentsVisible = !isCommentsVisible;
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.format_align_center, // chat box icon
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (isCommentsVisible && !chatBoxVisible) {
                  isCommentsVisible = false;
                  chatBoxVisible = true;
                } else if (chatBoxVisible) {
                  isCommentsVisible = true;
                  chatBoxVisible = false;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.analytics, // answers so far icon
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.answersPage);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // PDF Viewer Section
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isPdfExpanded
                      ? MediaQuery.of(context).size.height * 0.7
                      : MediaQuery.of(context).size.height * 0.4,
                  child: PdfViewer(
                    pdfFile: pdfFile,
                  ),
                ),
                // Past Papers List Section
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 100,
                    child: papers.isEmpty
                        ? const Center(
                            child: Text(
                              'No papers available',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: papers.length,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (index) {
                              loadPaper(index);
                            },
                            itemBuilder: (context, index) {
                              return PastPaperInfoCard(
                                paper: papers[index],
                                isFirst: index == 0,
                                isLast: index == papers.length - 1,
                                onPaperSelected: (url, name, year) {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
                // Comments Section
                if (isCommentsVisible)
                  Expanded(
                    child: Comments(toBeDiscussedId: id),
                  ),
              ],
            ),
    );
  }
}
