import 'package:beyondtheclass/pages/drawer/student/pages/pastPaper/discussion/components/PastPaperInfoCard.dart';
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
        final response = await apiClient.get(
            '/api/discussion/structured-question/${paper['_id']}/answers?includeSubQuestions=true');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Answers'),
      ),
      body: Column(
        children: [
          // Past Papers List Section
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: SizedBox(
              height: 80,
              child: papers.isEmpty
                  ? const Center(
                      child: Text('No papers available'),
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
                ? const Center(child: CircularProgressIndicator())
                : answers.isEmpty
                    ? const Center(child: Text('No answers available'))
                    : ListView.builder(
                        itemCount: answers.length,
                        itemBuilder: (context, index) {
                          final answer = answers[index];
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    answer['content'] ?? '',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Votes: ${(answer['upvotes'] ?? 0) - (answer['downvotes'] ?? 0)}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
