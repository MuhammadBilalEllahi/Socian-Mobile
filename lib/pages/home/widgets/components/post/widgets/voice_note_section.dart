import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

class VoiceNoteSection extends StatelessWidget {
  final bool isRecording;
  final bool isPlaying;
  final File? voiceNote;
  final List<double> waveform;
  final VoidCallback onPlayPause;
  final VoidCallback onDelete;
  final Duration recordingDuration;

  const VoiceNoteSection({
    super.key,
    required this.isRecording,
    required this.isPlaying,
    required this.voiceNote,
    required this.waveform,
    required this.onPlayPause,
    required this.onDelete,
    required this.recordingDuration,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (isRecording)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomPaint(
                      painter: WaveformPainter(
                        waveform: waveform,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(recordingDuration),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (voiceNote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: onPlayPause,
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CustomPaint(
                        painter: WaveformPainter(
                          waveform: waveform,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(recordingDuration),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final Color color;

  WaveformPainter({
    required this.waveform,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    final barWidth = width / waveform.length;

    for (var i = 0; i < waveform.length; i++) {
      final x = i * barWidth;
      final barHeight = waveform[i] * height;
      final y = (height - barHeight) / 2;
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return waveform != oldDelegate.waveform;
  }
}
