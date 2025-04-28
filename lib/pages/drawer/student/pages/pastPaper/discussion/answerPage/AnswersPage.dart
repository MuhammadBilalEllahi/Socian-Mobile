import 'package:beyondtheclass/pages/drawer/student/pages/pastPaper/discussion/answerPage/components/PastPaperInfoCard.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter/material.dart';

// Import for AddAnswer bottom sheet
import 'components/AddAnswer.dart';
import 'widgets/PastPapersHeader.dart';
import 'widgets/AnswersList.dart';

class AnswersPage extends StatefulWidget {
  const AnswersPage({super.key, required});

  @override
  State<AnswersPage> createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
  late Future<Map<String, dynamic>> pastPapers = Future.value({});
  final ApiClient apiClient = ApiClient();
  late String subjectId;
  List<Map<String, dynamic>> papers = [];
  List<Map<String, dynamic>> answers = [];
  bool isLoading = true;
  int currentIndex = 0;
  final PageController _pageController = PageController();

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
        loadAnswers(newIndex);
      }
    }
  }

  Future<void> loadAnswers(int index) async {
    if (index >= 0 && index < papers.length) {
      final paper = papers[index];
      setState(() {
        isLoading = true;
        currentIndex = index;
      });

      try {
        final response = await apiClient.post(
            '/api/discussion/questions/populated/all',
            {'toBeDiscussedId': paper['_id']});

        debugPrint("RESPONSE __ ${response['answers']}");
        setState(() {
          answers = List<Map<String, dynamic>>.from(response['answers'] ?? []);
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load answers: $e')),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (routeArgs?.containsKey('pastPapers') ?? false) {
      pastPapers = routeArgs?['pastPapers'] ?? {};
      subjectId = routeArgs!['subjectId'];
      if (routeArgs.containsKey('papers')) {
        setState(() {
          papers = List<Map<String, dynamic>>.from(routeArgs['papers'] ?? []);
          if (papers.isNotEmpty) {
            loadAnswers(0);
          }
        });
      }
    } else {
      setState(() {
        pastPapers = Future.error('Invalid route arguments or missing ID');
      });
    }
  }

  bool showFull = false;
  int moreCount = 2;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final primaryColor = Theme.of(context).primaryColor;
    final cardBackground = isDarkMode ? const Color(0xFF18181B) : Colors.white;
    final answerBackground =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);

    // Get the current paper's toBeDiscussedId (paper['_id'])
    String? toBeDiscussedId =
        (papers.isNotEmpty && currentIndex < papers.length)
            ? papers[currentIndex]['_id']
            : null;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'Answers',
          style: TextStyle(
            color: foreground,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: foreground),
        centerTitle: true,
      ),
      body: Column(children: [
        // Past Papers List Section
        PastPapersHeader(
          papers: papers,
          pageController: _pageController,
          onPageChanged: (index) => loadAnswers(index),
        ),
        // Answers Section
        Expanded(
          child: AnswersList(
            answers: answers,
            isLoading: isLoading,
            primaryColor: primaryColor,
            mutedForeground: mutedForeground,
            cardBackground: cardBackground,
            border: border,
            foreground: foreground,
            answerBackground: answerBackground,
            moreCount: moreCount,
            showFull: showFull,
            onShowMoreToggle: (questionIndex, show) {
              setState(() {
                showFull = show;
              });
            },
          ),
        ),
      ]),
      floatingActionButton: toBeDiscussedId == null
          ? null
          : Container(
              decoration: BoxDecoration(
                border: Border.all(color: mutedForeground),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FloatingActionButton(
                backgroundColor: background,
                elevation: 2,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.7,
                      minChildSize: 0.5,
                      maxChildSize: 0.9,
                      expand: false,
                      builder: (context, scrollController) => AddAnswer(
                        toBeDiscussedId: toBeDiscussedId,
                      ),
                    ),
                  );
                },
                child: Icon(Icons.add, color: foreground),
              ),
            ),
    );
  }
}
