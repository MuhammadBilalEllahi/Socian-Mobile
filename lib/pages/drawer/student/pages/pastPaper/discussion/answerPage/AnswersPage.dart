import 'package:flutter/material.dart';

class AnswersPage extends StatefulWidget {
  const AnswersPage({super.key});

  @override
  State<AnswersPage> createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Answers Page'),
      ),
    );
  }
}
