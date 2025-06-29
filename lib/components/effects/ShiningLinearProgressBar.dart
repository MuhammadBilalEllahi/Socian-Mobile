
import 'package:flutter/material.dart';

class ShiningLinearProgressBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final bool isLoadingComplete;

  const ShiningLinearProgressBar({
    Key? key,
    required this.progress,
    this.isLoadingComplete = false,
  }) : super(key: key);

  @override
  _ShiningLinearProgressBarState createState() =>
      _ShiningLinearProgressBarState();
}

class _ShiningLinearProgressBarState extends State<ShiningLinearProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isLoadingComplete) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ShiningLinearProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoadingComplete && !_shimmerController.isAnimating) {
      _shimmerController.repeat();
    } else if (!widget.isLoadingComplete && _shimmerController.isAnimating) {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressWidth = MediaQuery.of(context).size.width * widget.progress;

    return SizedBox(
      height: 4,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
                                height: 2.3,
            color: Colors.grey[300],
          ),
          Container(
            height: 2.3,
            width: progressWidth,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (widget.isLoadingComplete)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shimmerController,
                builder: (_, __) {
                  return ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0),
                        ],
                        stops: const [0.1, 0.5, 0.9],
                        begin: Alignment(-1 - 3 * _shimmerController.value, 0),
                        end: Alignment(1 + 3 * _shimmerController.value, 0),
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.lighten,
                    child: Container(
                      color: Colors.blueAccent.withOpacity(0.5),
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
