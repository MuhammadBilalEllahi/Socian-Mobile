import 'package:flutter/material.dart';

class DateBadge extends StatelessWidget {
  final String date;

  const DateBadge({
    super.key,
    required this.date, required int fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      date,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[600],
      ),
    );
  }
}
