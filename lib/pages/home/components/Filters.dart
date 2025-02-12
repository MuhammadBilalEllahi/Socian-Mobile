import 'package:flutter/material.dart';

class Filters extends StatefulWidget {
  final Color color;
  final String text;

  const Filters({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0),
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)
        ),
        child: Container(
          color: widget.color,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.text,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
