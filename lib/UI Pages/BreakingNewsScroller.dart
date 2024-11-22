import 'package:flutter/material.dart';

class BreakingNewsScroller extends StatefulWidget {
  final String newsText;

  const BreakingNewsScroller({super.key, required this.newsText});

  @override
  State<BreakingNewsScroller> createState() => _BreakingNewsScrollerState();
}

class _BreakingNewsScrollerState extends State<BreakingNewsScroller> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 1.0, end: -1.0).animate(_controller)
        .drive(CurveTween(curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Positioned(
            left: _animation.value * MediaQuery.of(context).size.width,
            child: Text(
              widget.newsText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}