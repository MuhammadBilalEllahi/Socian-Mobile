import 'package:flutter/material.dart';

class YourAnswerTextField extends StatefulWidget {
  const YourAnswerTextField({super.key});

  @override
  State<YourAnswerTextField> createState() => _YourAnswerTextFieldState();
}

class _YourAnswerTextFieldState extends State<YourAnswerTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.grey[350],
      height: 40,
      width: MediaQuery.of(context).size.width/1.5,
      child: TextField(

        decoration: InputDecoration(
          icon: Icon(Icons.question_answer_rounded),
          iconColor: Colors.teal,
          labelText: 'Write your answer',
          // border: OutlineInputBorder(),
          labelStyle: TextStyle(
            color: Colors.teal, // Replace with your desired color
          ),
        ),

      ),
    )
    ;
  }
}


