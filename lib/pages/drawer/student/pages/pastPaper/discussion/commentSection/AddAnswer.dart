import 'package:flutter/material.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'AddQuestion.dart';

class AddAnswer extends StatefulWidget {
  final String toBeDiscussedId;
  final String? selectedQuestionId;

  const AddAnswer({
    Key? key,
    required this.toBeDiscussedId,
    this.selectedQuestionId,
  }) : super(key: key);

  @override
  State<AddAnswer> createState() => _AddAnswerState();
}

class _AddAnswerState extends State<AddAnswer> {
  final ApiClient _apiClient = ApiClient();
  final answerController = TextEditingController();
  String? selectedQuestionId;
  String? selectedQuestionContent;
  List<dynamic> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedQuestionId = widget.selectedQuestionId;
    _fetchQuestions();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await _apiClient.post(
        '/api/discussion/questions/all',
        {'toBeDiscussedId': widget.toBeDiscussedId},
      );
      debugPrint("question- $response");
      setState(() {
        questions = response['data'] ?? [];
        if (selectedQuestionId != null) {
          final question = questions.firstWhere(
            (q) => q['_id'] == selectedQuestionId,
            orElse: () => null,
          );
          if (question != null) {
            selectedQuestionContent = question['questionContent'];
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch questions: $e')),
      );
    }
  }

  void _showAddQuestionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => AddQuestion(
          toBeDiscussedId: widget.toBeDiscussedId,
          onQuestionSelected: (questionId) {
            setState(() {
              selectedQuestionId = questionId;
              final question = questions.firstWhere(
                (q) => q['_id'] == questionId,
                orElse: () => null,
              );
              if (question != null) {
                selectedQuestionContent = question['questionContent'];
              }
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _submitAnswer() async {
    if (selectedQuestionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a question')),
      );
      return;
    }

    if (answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide an answer')),
      );
      return;
    }

    try {
      await _apiClient.post('/api/discussion/create/answer', {
        'questionId': selectedQuestionId,
        'answerContent': answerController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Answer submitted successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit answer: $e')),
      );
    }
  }

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
    final cardBackground =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);
    final hoverBackground =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: mutedForeground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Add Answer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: foreground,
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedQuestionId,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        dropdownColor: cardBackground,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 14,
                        ),
                        icon:
                            Icon(Icons.arrow_drop_down, color: mutedForeground),
                        hint: Text(
                          'Select Question',
                          style: TextStyle(
                            color: mutedForeground,
                            fontSize: 14,
                          ),
                        ),
                        items: questions.map((question) {
                          return DropdownMenuItem<String>(
                            value: question['_id'],
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Q${question['questionNumberOrAlphabet']}',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    question['questionContent'],
                                    style: TextStyle(
                                      color: foreground,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedQuestionId = value;
                            final question = questions.firstWhere(
                              (q) => q['_id'] == value,
                              orElse: () => null,
                            );
                            if (question != null) {
                              selectedQuestionContent =
                                  question['questionContent'];
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: IconButton(
                    onPressed: _showAddQuestionSheet,
                    icon: Icon(Icons.add, color: primaryColor),
                    tooltip: 'Add New Question',
                  ),
                ),
              ],
            ),
            if (selectedQuestionContent != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Q${questions.firstWhere((q) => q['_id'] == selectedQuestionId)['questionNumberOrAlphabet']}',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedQuestionContent!,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border),
              ),
              child: TextField(
                controller: answerController,
                maxLines: 5,
                style: TextStyle(color: foreground),
                decoration: InputDecoration(
                  labelText: 'Your Answer',
                  labelStyle: TextStyle(color: mutedForeground),
                  hintText: 'Type your answer here...',
                  hintStyle: TextStyle(color: mutedForeground.withOpacity(0.7)),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Answer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
