import 'package:beyondtheclass/pages/drawer/student/pages/pastPaper/discussion/answerPage/PastPaperInfoCard.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter/material.dart';

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

  final moreCount = 2;

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
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: background,
              border: Border(
                bottom: BorderSide(
                  color: border,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              height: 80,
              child: papers.isEmpty
                  ? Center(
                      child: Text(
                        'No papers available',
                        style: TextStyle(
                          color: mutedForeground,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: papers.length,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        loadAnswers(index);
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
                          onChatBoxToggle: () {},
                        );
                      },
                    ),
            ),
          ),
          // Answers Section
          Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: primaryColor,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading answers...',
                            style: TextStyle(
                              color: mutedForeground,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : answers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.question_answer_outlined,
                                size: 48,
                                color: mutedForeground,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No answers available',
                                style: TextStyle(
                                  color: mutedForeground,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: answers.length,
                          itemBuilder: (context, index) {
                            final question = answers[index];

                            return Container(
                                margin: const EdgeInsets.only(bottom: 24.0),
                                decoration: BoxDecoration(
                                  color: cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: border,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Question Header
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'Q${question['questionNumberOrAlphabet']}: ${question['questionContent']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: foreground,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      // Answers
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: question['answers'] != null
                                              ? (question['answers'] as List)
                                                          .length <
                                                      moreCount
                                                  ? (question['answers']
                                                          as List)
                                                      .length
                                                  : moreCount
                                              : 0,
                                          itemBuilder: (context, index) {
                                            final answer =
                                                question['answers'][index];
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                color: answerBackground,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Answer Content with User Avatar
                                                  RichText(
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 4,
                                                      text: TextSpan(children: [
                                                        WidgetSpan(
                                                            child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 4),
                                                          child: CircleAvatar(
                                                            radius: 12,
                                                            backgroundImage:
                                                                NetworkImage(
                                                              answer['answeredByUser']
                                                                          [
                                                                          'profile']
                                                                      [
                                                                      'picture'] ??
                                                                  'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg',
                                                            ),
                                                          ),
                                                        )),
                                                        TextSpan(
                                                          spellOut: true,
                                                          text: answer[
                                                                  'content'] ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: foreground,
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                      ])),
                                                  const SizedBox(height: 12),
                                                  // Voting and Comments Section
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.attach_file,
                                                            size: 16,
                                                            color:
                                                                mutedForeground,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            '${answer['upvotes']}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  mutedForeground,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Icon(
                                                            Icons.image,
                                                            size: 16,
                                                            color:
                                                                mutedForeground,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            '${answer['upvotes']}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  mutedForeground,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .thumb_up_outlined,
                                                            size: 16,
                                                            color:
                                                                mutedForeground,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            '${answer['upvotes']}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  mutedForeground,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 16),
                                                          Icon(
                                                            Icons
                                                                .thumb_down_outlined,
                                                            size: 16,
                                                            color:
                                                                mutedForeground,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            '${answer['downvotes']}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  mutedForeground,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 16),
                                                          Icon(
                                                            Icons
                                                                .comment_outlined,
                                                            size: 16,
                                                            color:
                                                                mutedForeground,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            '${(answer['replies'] as List).length}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  mutedForeground,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            );
                                          }),
                                      if (question['answers'] != null &&
                                          (question['answers'] as List).length >
                                              moreCount)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                "+ ${(question['answers'] as List).length - moreCount} answers",
                                                style: TextStyle(
                                                  color: mutedForeground,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 12,
                                                color: mutedForeground,
                                              ),
                                            ],
                                          ),
                                        )
                                    ]));
                          })),
        ]));
  }
}
