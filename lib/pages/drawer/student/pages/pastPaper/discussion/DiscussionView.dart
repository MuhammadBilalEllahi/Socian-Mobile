import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../pages/message/ChatPage.dart';
import '../../../../../../pages/profile/ProfilePage.dart';
import 'PastPaperInfoCard.dart';
import 'PdfViewer.dart';
import 'commentSection/Comments.dart';
import 'components/ChatBox.dart';

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
    // debugPrint("Start downloading PDF from: $url");
    try {
      final filename = url.substring(url.lastIndexOf("/") + 1);
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      // debugPrint("Saving PDF to: ${dir.path}/$filename");
      File file = File("${dir.path}/$filename");
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      // debugPrint("Error downloading PDF: $e");
      throw Exception('Error downloading PDF file: $e');
    }
    return completer.future;
  }

  void loadPaper(int index) async {
    if (index >= 0 && index < papers.length) {
      final paper = papers[index];
      // debugPrint("DATAof $paper");
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
        developer.log("----------papers: ${papers[currentIndex]}");
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

  Widget _buildInfoRow(
      String label, String value, Color foreground, Color mutedForeground) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
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
                                  onLongPress: () => {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        final isDarkMode =
                                            Theme.of(context).brightness ==
                                                Brightness.dark;

                                        // Shadcn-style color scheme
                                        final background = isDarkMode
                                            ? const Color(0xFF09090B)
                                            : Colors.white;
                                        final foreground = isDarkMode
                                            ? Colors.white
                                            : const Color(0xFF09090B);
                                        final muted = isDarkMode
                                            ? const Color(0xFF27272A)
                                            : const Color(0xFFF4F4F5);
                                        final mutedForeground = isDarkMode
                                            ? const Color(0xFFA1A1AA)
                                            : const Color(0xFF71717A);
                                        final border = isDarkMode
                                            ? const Color(0xFF27272A)
                                            : const Color(0xFFE4E4E7);
                                        final accent = isDarkMode
                                            ? const Color(0xFF18181B)
                                            : const Color(0xFFFAFAFA);
                                        final primary = isDarkMode
                                            ? const Color(0xFF18181B)
                                            : const Color(0xFF18181B);

                                        return Dialog(
                                          backgroundColor: background,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Container(
                                            constraints: const BoxConstraints(
                                                maxWidth: 400, maxHeight: 600),
                                            padding: const EdgeInsets.all(24),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.description,
                                                        size: 32,
                                                        color: primary,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Past Paper Info',
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    foreground,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Version 1.0.0',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    mutedForeground,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Text(
                                                    'File Information',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: foreground,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: accent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: border),
                                                    ),
                                                    child: Text(
                                                      'File ${index + 1}',
                                                      style: TextStyle(
                                                        color: foreground,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'PDF URL:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: foreground,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final url =
                                                          "${ApiConstants.baseUrl}/api/uploads/${file['url']}";
                                                      try {
                                                        if (await canLaunchUrl(
                                                            Uri.parse(url))) {
                                                          await launchUrl(
                                                            Uri.parse(url),
                                                            mode: LaunchMode
                                                                .externalApplication,
                                                          );
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Could not open URL: $url'),
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                          );
                                                        }
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                'Error opening URL: $e'),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    onLongPress: () {
                                                      final url =
                                                          "${ApiConstants.baseUrl}/api/uploads/${file['url']}";
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          backgroundColor:
                                                              background,
                                                          title: Text(
                                                            'PDF URL',
                                                            style: TextStyle(
                                                                color:
                                                                    foreground),
                                                          ),
                                                          content:
                                                              SelectableText(
                                                            url,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'monospace',
                                                              color: foreground,
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                              child: Text(
                                                                'Close',
                                                                style: TextStyle(
                                                                    color:
                                                                        primary),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                try {
                                                                  if (await canLaunchUrl(
                                                                      Uri.parse(
                                                                          url))) {
                                                                    await launchUrl(
                                                                      Uri.parse(
                                                                          url),
                                                                      mode: LaunchMode
                                                                          .externalApplication,
                                                                    );
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  }
                                                                } catch (e) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(
                                                                          'Error opening URL: $e'),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              child: Text(
                                                                'Open',
                                                                style: TextStyle(
                                                                    color:
                                                                        primary),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration: BoxDecoration(
                                                        color: accent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: border),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              "${ApiConstants.baseUrl}/api/uploads/${file['url']}",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'monospace',
                                                                color:
                                                                    foreground,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Icon(
                                                            Icons.open_in_new,
                                                            size: 16,
                                                            color:
                                                                mutedForeground,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Upload Information:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: foreground,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 12),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration: BoxDecoration(
                                                      color: accent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: border,
                                                          width: 1),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.05),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ProfilePage(
                                                                      userId: file[
                                                                              'uploadedBy']
                                                                          [
                                                                          '_id'],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: primary
                                                                      .withOpacity(
                                                                          0.1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                                child: Icon(
                                                                  Icons.person,
                                                                  color:
                                                                      primary,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 12),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    file['uploadedBy']
                                                                        [
                                                                        'name'],
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          foreground,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '@${file['uploadedBy']['username']}',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          mutedForeground,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    file['uploadedBy']
                                                                        [
                                                                        'universityEmail'],
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          mutedForeground,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.message,
                                                                color: primary,
                                                                size: 20,
                                                              ),
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ChatPage(
                                                                      userId: file[
                                                                              'uploadedBy']
                                                                          [
                                                                          '_id'],
                                                                      userName:
                                                                          file['uploadedBy']
                                                                              [
                                                                              'name'],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 12),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: muted,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                          ),
                                                          child: Text(
                                                            'Uploaded at: ${DateTime.parse(file['uploadedAt']).toString().split('.')[0]}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  mutedForeground,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 12),
                                                        SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              // TODO: Implement connect functionality
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      'Connect functionality coming soon!'),
                                                                ),
                                                              );
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  primary,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              'Connect',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (file['teachers'] !=
                                                          null &&
                                                      file['teachers']
                                                          .isNotEmpty) ...[
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'Associated Teachers:',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: foreground,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    ...file['teachers']
                                                        .map<Widget>(
                                                            (teacher) =>
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              12),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          16),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color:
                                                                        accent,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color:
                                                                          border,
                                                                      width: 1,
                                                                    ),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.05),
                                                                        blurRadius:
                                                                            8,
                                                                        offset: const Offset(
                                                                            0,
                                                                            2),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          if (teacher['imageUrl'] !=
                                                                              null)
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => ProfilePage(
                                                                                      userId: teacher['_id'],
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                width: 40,
                                                                                height: 40,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(20),
                                                                                  image: DecorationImage(
                                                                                    image: NetworkImage(teacher['imageUrl']),
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          else
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => ProfilePage(
                                                                                      userId: teacher['_id'],
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                width: 40,
                                                                                height: 40,
                                                                                decoration: BoxDecoration(
                                                                                  color: primary.withOpacity(0.1),
                                                                                  borderRadius: BorderRadius.circular(20),
                                                                                ),
                                                                                child: Icon(
                                                                                  Icons.person,
                                                                                  color: primary,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          const SizedBox(
                                                                              width: 12),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    if (teacher['userAttachedBool'] == true) {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                          builder: (context) => ProfilePage(
                                                                                            userId: teacher['userAttached']['_id'],
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                  },
                                                                                  child: Text(
                                                                                    teacher['name'],
                                                                                    style: TextStyle(
                                                                                      fontSize: 16,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      color: foreground,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  teacher['email'],
                                                                                  style: TextStyle(
                                                                                    fontSize: 12,
                                                                                    color: mutedForeground,
                                                                                  ),
                                                                                ),
                                                                                if (teacher['campusOrigin'] != null) ...[
                                                                                  Text(
                                                                                    teacher['campusOrigin']['name'] ?? 'Unknown Campus',
                                                                                    style: TextStyle(
                                                                                      fontSize: 11,
                                                                                      color: mutedForeground,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              if (teacher['rating'] != null)
                                                                                Container(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                                  decoration: BoxDecoration(
                                                                                    color: primary.withOpacity(0.1),
                                                                                    borderRadius: BorderRadius.circular(12),
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Icon(
                                                                                        Icons.star,
                                                                                        size: 14,
                                                                                        color: primary,
                                                                                      ),
                                                                                      const SizedBox(width: 4),
                                                                                      Text(
                                                                                        '${teacher['rating']}',
                                                                                        style: TextStyle(
                                                                                          fontSize: 12,
                                                                                          fontWeight: FontWeight.w500,
                                                                                          color: primary,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              const SizedBox(width: 8),
                                                                              IconButton(
                                                                                icon: Icon(
                                                                                  Icons.message,
                                                                                  color: primary,
                                                                                  size: 20,
                                                                                ),
                                                                                onPressed: () {
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => ChatPage(
                                                                                        userId: teacher['_id'],
                                                                                        userName: teacher['name'],
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              12),
                                                                      if (teacher[
                                                                              'department'] !=
                                                                          null) ...[
                                                                        Container(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 8,
                                                                              vertical: 4),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                muted,
                                                                            borderRadius:
                                                                                BorderRadius.circular(6),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            'Department: ${teacher['department']['name']}',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: mutedForeground,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                8),
                                                                      ],
                                                                      if (teacher[
                                                                              'onLeave'] !=
                                                                          null) ...[
                                                                        Container(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 8,
                                                                              vertical: 4),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: teacher['onLeave']
                                                                                ? Colors.orange.withOpacity(0.1)
                                                                                : Colors.green.withOpacity(0.1),
                                                                            borderRadius:
                                                                                BorderRadius.circular(6),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            teacher['onLeave']
                                                                                ? 'On Leave'
                                                                                : 'Active',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: teacher['onLeave'] ? Colors.orange : Colors.green,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                8),
                                                                      ],
                                                                      if (teacher['feedbackSummary'] !=
                                                                              null &&
                                                                          teacher['feedbackSummary']
                                                                              .isNotEmpty) ...[
                                                                        Text(
                                                                          'Recent Feedback:',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                foreground,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                4),
                                                                        Container(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                muted,
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            teacher['feedbackSummary'][0]['summary'],
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 11,
                                                                              color: mutedForeground,
                                                                              height: 1.4,
                                                                            ),
                                                                            maxLines:
                                                                                3,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                      const SizedBox(
                                                                          height:
                                                                              12),
                                                                      SizedBox(
                                                                        width: double
                                                                            .infinity,
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            // TODO: Implement connect functionality for teachers
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(
                                                                                content: Text('Connect with ${teacher['name']} coming soon!'),
                                                                              ),
                                                                            );
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                primary,
                                                                            foregroundColor:
                                                                                Colors.white,
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 8),
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            'Connect with ${teacher['name']}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ))
                                                        .toList(),
                                                  ],
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Paper Details:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: foreground,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration: BoxDecoration(
                                                      color: accent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: border),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildInfoRow(
                                                            'Paper Name',
                                                            papers[currentIndex]
                                                                ['name'],
                                                            foreground,
                                                            mutedForeground),
                                                        _buildInfoRow(
                                                            'Type',
                                                            papers[currentIndex]
                                                                ['type'],
                                                            foreground,
                                                            mutedForeground),
                                                        _buildInfoRow(
                                                            'Category',
                                                            papers[currentIndex]
                                                                ['category'],
                                                            foreground,
                                                            mutedForeground),
                                                        _buildInfoRow(
                                                            'Term',
                                                            papers[currentIndex]
                                                                ['term'],
                                                            foreground,
                                                            mutedForeground),
                                                        _buildInfoRow(
                                                            'Academic Year',
                                                            papers[currentIndex]
                                                                    [
                                                                    'academicYear']
                                                                .toString(),
                                                            foreground,
                                                            mutedForeground),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Metadata:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: foreground,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration: BoxDecoration(
                                                      color: accent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: border),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildInfoRow(
                                                            'Views',
                                                            papers[currentIndex]
                                                                        [
                                                                        'metadata']
                                                                    ['views']
                                                                .toString(),
                                                            foreground,
                                                            mutedForeground),
                                                        _buildInfoRow(
                                                            'Downloads',
                                                            papers[currentIndex]
                                                                        [
                                                                        'metadata']
                                                                    [
                                                                    'downloads']
                                                                .toString(),
                                                            foreground,
                                                            mutedForeground),
                                                        _buildInfoRow(
                                                            'Answers',
                                                            papers[currentIndex]
                                                                        [
                                                                        'metadata']
                                                                    ['answers']
                                                                .toString(),
                                                            foreground,
                                                            mutedForeground),
                                                        _buildInfoRow(
                                                            'Total Questions',
                                                            papers[currentIndex]
                                                                        [
                                                                        'metadata']
                                                                    [
                                                                    'totalQuestions']
                                                                .toString(),
                                                            foreground,
                                                            mutedForeground),
                                                        _buildInfoRow(
                                                            'Answered Questions',
                                                            papers[currentIndex]
                                                                        [
                                                                        'metadata']
                                                                    [
                                                                    'answeredQuestions']
                                                                .toString(),
                                                            foreground,
                                                            mutedForeground),
                                                        _buildInfoRow(
                                                            'Last Accessed',
                                                            DateTime.parse(papers[
                                                                            currentIndex]
                                                                        [
                                                                        'metadata']
                                                                    [
                                                                    'lastAccessed'])
                                                                .toString()
                                                                .split('.')[0],
                                                            foreground,
                                                            mutedForeground),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      style:
                                                          TextButton.styleFrom(
                                                        backgroundColor:
                                                            primary,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 12),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'Close',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  },
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
