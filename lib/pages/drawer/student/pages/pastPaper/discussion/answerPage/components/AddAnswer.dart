import 'package:flutter/material.dart';
import 'package:socian/shared/services/api_client.dart';
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
  _AddAnswerState createState() => _AddAnswerState();
}

class _AddAnswerState extends State<AddAnswer> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController answerController = TextEditingController();

  bool isLoading = true;
  List<Map<String, dynamic>> _flatQuestions = [];
  List<DropdownMenuItem<String>> _questionItems = [];

  String? selectedQuestionId;
  String? selectedQuestionContent;
  String? selectedQuestionPath;

  @override
  void initState() {
    super.initState();
    selectedQuestionId = widget.selectedQuestionId;
    _loadQuestions();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => isLoading = true);
    try {
      final resp = await _apiClient.post(
        '/api/discussion/parent-questions/populated/all',
        {'toBeDiscussedId': widget.toBeDiscussedId},
      );
      final data = resp['data'] as List<dynamic>? ?? [];
      _flatQuestions = _flattenQuestions(data);

      // build dropdown items once
      _questionItems = _flatQuestions.map((q) {
        final path = q['path'] as String;
        final content = q['questionContent'] as String;
        return DropdownMenuItem<String>(
          value: q['_id'] as String,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Q$path:',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  content,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      }).toList();

      // restore any initial selection
      if (widget.selectedQuestionId != null) {
        final sel = _flatQuestions.firstWhere(
          (q) => q['_id'] == widget.selectedQuestionId,
          orElse: () => <String, dynamic>{},
        );
        if (sel.isNotEmpty) {
          selectedQuestionId = sel['_id'] as String;
          selectedQuestionContent = sel['questionContent'] as String;
          selectedQuestionPath = sel['path'] as String;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch questions: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _flattenQuestions(
    List<dynamic> questions, {
    String? parentPath,
  }) {
    final flat = <Map<String, dynamic>>[];
    for (var q in questions) {
      final code = q['questionNumberOrAlphabet'] as String? ?? '';
      final path = parentPath != null ? '$parentPath.$code' : code;
      flat.add({
        '_id': q['_id'],
        'path': path,
        'questionContent': q['questionContent'],
      });
      if (q['subQuestions'] != null) {
        flat.addAll(_flattenQuestions(q['subQuestions'] as List<dynamic>,
            parentPath: path));
      }
    }
    return flat;
  }

  void _onQuestionChanged(String? id) {
    if (id == null) return;
    final sel = _flatQuestions.firstWhere((q) => q['_id'] == id);
    setState(() {
      selectedQuestionId = id;
      selectedQuestionContent = sel['questionContent'] as String?;
      selectedQuestionPath = sel['path'] as String?;
    });
  }

  Future<void> _submitAnswer() async {
    if (selectedQuestionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a question')),
      );
      return;
    }
    if (answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide an answer')),
      );
      return;
    }
    try {
      await _apiClient.post('/api/discussion/create/answer', {
        'toBeDiscussedId': widget.toBeDiscussedId,
        'questionId': selectedQuestionId,
        'answer': answerController.text.trim(),
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

  void _showAddQuestionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        expand: false,
        builder: (ctx, scroll) => AddQuestion(
          toBeDiscussedId: widget.toBeDiscussedId,
          onQuestionSelected: (id) {
            // Navigator.pop(ctx);
            _loadQuestions(); // reload so new Q shows up
            Future.microtask(() => _onQuestionChanged(id));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF09090B) : Colors.white;
    final fg = isDark ? Colors.white : const Color(0xFF09090B);
    final muted = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final borderColor =
        isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final primary = Theme.of(context).primaryColor;
    final cardBg = isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
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
                  color: muted, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text('Add Answer',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: fg)),
          const SizedBox(height: 16),
          if (isLoading)
            Center(child: CircularProgressIndicator(color: primary))
          else
            Column(children: [
              Row(children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        items: _questionItems,
                        value: selectedQuestionId,
                        isExpanded: true,
                        dropdownColor: cardBg,
                        icon: Icon(Icons.arrow_drop_down, color: muted),
                        hint: Text('Select Question',
                            style: TextStyle(color: muted, fontSize: 14)),
                        onChanged: _onQuestionChanged,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                      color: cardBg,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    icon: Icon(Icons.add, color: primary),
                    tooltip: 'Add New Question',
                    onPressed: _showAddQuestionSheet,
                  ),
                ),
              ]),
              if (selectedQuestionContent != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: cardBg,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Q${selectedQuestionPath ?? ''}',
                            style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(selectedQuestionContent!,
                            style: TextStyle(color: fg, fontSize: 14)),
                      ]),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  controller: answerController,
                  maxLines: 5,
                  style: TextStyle(color: fg),
                  decoration: InputDecoration(
                    labelText: 'Your Answer',
                    labelStyle: TextStyle(color: muted),
                    hintText: 'Type your answer here...',
                    hintStyle: TextStyle(color: muted.withOpacity(0.7)),
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
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Submit Answer',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ]),
        ],
      ),
    );
  }
}
