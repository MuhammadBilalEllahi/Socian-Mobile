import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RepeatingThumbAnimation extends StatefulWidget {
  const RepeatingThumbAnimation({super.key});

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
    final data = await RiveFile.asset('assets/animations/t_g_thumb.riv');
    debugPrint("RVIVE $data");
    final artboard = data.mainArtboard;
    _controller = SimpleAnimation('Tap', autoplay: true);
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
