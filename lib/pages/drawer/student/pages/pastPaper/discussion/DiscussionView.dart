import 'dart:async';
import 'dart:io';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/shared/services/WebSocketService.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'PastPaperInfoCard.dart';
import 'PdfViewer.dart';
import 'commentSection/Comments.dart';
import 'components/ChatBox.dart';
import 'dart:developer' as developer;

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
  int currentFileIndex = 0;
  bool isCommentsVisible = true;
  bool isPdfExpanded = false;
  bool chatBoxVisible = false;
  String? activeChatBoxId;
  String? activePdfId;

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
        setState(() {
          currentIndex = newIndex;
          if (papers.isNotEmpty &&
              papers[currentIndex]['files'] != null &&
              papers[currentIndex]['files'].isNotEmpty) {
            activePdfId = papers[currentIndex]['files'][0]['_id'];
            loadPaper(currentIndex);
          }
        });
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
      debugPrint("DATAof $paper");
      id = paper['_id'];
      if (paper['files'] != null && paper['files'].isNotEmpty) {
        final file = paper['files'].firstWhere(
          (f) => f['_id'] == activePdfId,
          orElse: () => paper['files'][0],
        );
        final url = "${ApiConstants.baseUrl}/api/uploads/${file['url']}";
        developer.log("1.PDF URL: $url");
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

  void loadFile(String fileId) async {
    if (currentIndex >= 0 && currentIndex < papers.length) {
      final paper = papers[currentIndex];
      if (paper['files'] != null) {
        final file = paper['files'].firstWhere(
          (f) => f['_id'] == fileId,
          orElse: () => paper['files'][0],
        );
        final url = "${ApiConstants.baseUrl}/api/uploads/${file['url']}";
        developer.log("2.PDF URL: $url");
        setState(() {
          currentPdfUrl = url;
          activePdfId = fileId;
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
        debugPrint("----------papers: ${papers[currentIndex]}");
      });
    } catch (e) {
      setState(() {
        pastPapers = Future.error('Failed to fetch past papers: $e');
        isLoading = false;
      });
    }
  }

  void _handleChatBoxToggle(int index) {
    setState(() {
      final paperId = papers[index]['_id'];
      activeChatBoxId = paperId;

      // Show bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            snap: true,
            snapSizes: const [0.3, 0.5, 0.8],
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[600]
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ChatBox(
                      discussionId: paperId,
                      key: ValueKey(paperId),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Custom theme colors
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: Text(
          'Discussion',
          style: TextStyle(color: foreground),
        ),
        iconTheme: IconThemeData(color: foreground),
        actions: [
          IconButton(
            icon: Icon(
              isPdfExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
              color: foreground,
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
              color: foreground,
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
            icon: Icon(
              Icons.analytics,
              color: foreground,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.answersPage, arguments: {
                'pastPapers': pastPapers,
                'subjectId': subjectId,
                'papers': papers,
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: foreground,
              ),
            )
          : Column(
              children: [
                // PDF Viewer Section
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  height: isPdfExpanded
                      ? MediaQuery.of(context).size.height * 0.7
                      : MediaQuery.of(context).size.height * 0.4,
                  child: Column(
                    children: [
                      Expanded(
                        child: PdfViewer(
                          pdfFile: pdfFile,
                        ),
                      ),
                      if (papers.isNotEmpty &&
                          papers[currentIndex]['files'] != null &&
                          papers[currentIndex]['files'].length > 1)
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: papers[currentIndex]['files'].length,
                            itemBuilder: (context, index) {
                              final file = papers[currentIndex]['files'][index];
                              final isSelected = file['_id'] == activePdfId;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton(
                                  onPressed: () => loadFile(file['_id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'File ${index + 1}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                // Past Papers List Section
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: SizedBox(
                    height: 80,
                    child: papers.isEmpty
                        ? Center(
                            child: Text(
                              'No papers available',
                              style: TextStyle(color: foreground),
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
                                onChatBoxToggle: () =>
                                    _handleChatBoxToggle(index),
                              );
                            },
                          ),
                  ),
                ),
                // Comments Section
                if (isCommentsVisible)
                  Expanded(
                    child: Comments(
                      toBeDiscussedId: papers[currentIndex]['_id'],
                      key: ValueKey(papers[currentIndex]['_id']),
                    ),
                  ),
              ],
            ),
    );
  }
}
