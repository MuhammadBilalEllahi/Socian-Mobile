import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:socian/core/utils/constants.dart';

class RepeatingThumbAnimation extends StatefulWidget {
  final RiveThumb animationType;
  final Color? color;
  const RepeatingThumbAnimation(this.animationType, {this.color, super.key});

  @override
  State<RepeatingThumbAnimation> createState() =>
      _RepeatingThumbAnimationState();
}

class _RepeatingThumbAnimationState extends State<RepeatingThumbAnimation> {
  Artboard? _artboard;
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadRive();
  }

  void _loadRive() async {
    final data = await RiveFile.asset(RiveComponentStrings.thumbAsset);
    final artboard = data.mainArtboard.instance();

    if (widget.color != null) {
      // Find all shape nodes in artboard
      for (var child in artboard.children) {
        if (child is Shape) {
          // Get the fill property
          for (var fill in child.fills) {
            fill.paint.color = widget.color!;
          }
          // Get the stroke property
          for (var stroke in child.strokes) {
            stroke.paint.color = widget.color!;
          }
        }
      }
    }

    // Get the animation name from the map
    final animationName =
        RiveComponentStrings.thumbAnimations[widget.animationType];
    _controller = SimpleAnimation(animationName!, autoplay: true);
    artboard.addController(_controller);
    setState(() => _artboard = artboard);
  }

  @override
  Widget build(BuildContext context) {
    return _artboard == null
        ? const SizedBox.shrink()
        : SizedBox(
            width: 38,
            height: 38,
            child: Rive(artboard: _artboard!),
          );
  }
}
