// import 'package:flutter/material.dart';
// import 'package:universal_io/io.dart';
// import '../CreatePost.dart';

// class MediaControls extends StatelessWidget {
//   final Function() onImagePick;
//   final Function() onVideoPick;
//   final Function() onVoiceNoteStart;
//   final Function() onVoiceNoteStop;
//   final bool isRecording;
//   final bool showMap;
//   final Function() onMapToggle;
//   final PostType postType;
//   final List<File> mediaFiles;
//   final File? voiceNote;
//   final bool isVoiceSelected;

//   const MediaControls({
//     super.key,
//     required this.onImagePick,
//     required this.onVideoPick,
//     required this.onVoiceNoteStart,
//     required this.onVoiceNoteStop,
//     required this.isRecording,
//     required this.showMap,
//     required this.onMapToggle,
//     required this.postType,
//     required this.mediaFiles,
//     required this.voiceNote,
//     required this.isVoiceSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(
//             color: theme.dividerColor.withOpacity(0.1),
//           ),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           if (!isRecording && voiceNote == null) ...[
//             if (!(postType == PostType.society && showMap)) ...[
//               _buildGhostButton(
//                 context,
//                 icon: Icons.image_outlined,
//                 label: 'Photo',
//                 onPressed: onImagePick,
//               ),
//               _buildGhostButton(
//                 context,
//                 icon: Icons.videocam_outlined,
//                 label: 'Video',
//                 onPressed: onVideoPick,
//               ),
//             ],
//             if (postType == PostType.society && mediaFiles.isEmpty)
//               _buildBlackButton(
//                 context,
//                 icon: showMap ? Icons.map : Icons.map_outlined,
//                 label: 'Map',
//                 onPressed: onMapToggle,
//               ),
//           ],
//           if (mediaFiles.isEmpty && !(postType == PostType.society && showMap))
//             if (isVoiceSelected)
//               _buildBlackButton(
//                 context,
//                 icon: isRecording ? Icons.stop : Icons.mic_none_outlined,
//                 label: isRecording ? 'Stop' : 'Start Recording',
//                 onPressed: isRecording ? onVoiceNoteStop : onVoiceNoteStart,
//               )
//             else
//               _buildGhostButton(
//                 context,
//                 icon: Icons.mic_none_outlined,
//                 label: 'Voice',
//                 onPressed: onVoiceNoteStart,
//               ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGhostButton(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//   }) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(8),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: isDark ? Colors.grey[900] : Colors.grey[100],
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: theme.dividerColor.withOpacity(0.1),
//             ),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 icon,
//                 size: 20,
//                 color: theme.colorScheme.onSurface.withOpacity(0.8),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.8),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBlackButton(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//   }) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(8),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: isDark ? Colors.white : Colors.black,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 icon,
//                 size: 20,
//                 color: isDark ? Colors.black : Colors.white,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: isDark ? Colors.black : Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import '../CreatePost.dart';

class MediaControls extends StatelessWidget {
  final Function() onImagePick;
  final Function() onVideoPick;
  final Function() onVoiceNoteStart;
  final Function() onVoiceNoteStop;
  final bool isRecording;
  final PostType postType;
  final List<File> mediaFiles;
  final File? voiceNote;
  final bool isVoiceSelected;

  const MediaControls({
    super.key,
    required this.onImagePick,
    required this.onVideoPick,
    required this.onVoiceNoteStart,
    required this.onVoiceNoteStop,
    required this.isRecording,
    required this.postType,
    required this.mediaFiles,
    required this.voiceNote,
    required this.isVoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (!isRecording && voiceNote == null) ...[
            _buildGhostButton(
              context,
              icon: Icons.image_outlined,
              label: 'Photo',
              onPressed: onImagePick,
            ),
            _buildGhostButton(
              context,
              icon: Icons.videocam_outlined,
              label: 'Video',
              onPressed: onVideoPick,
            ),
          ],
          if (mediaFiles.isEmpty)
            if (isVoiceSelected)
              _buildBlackButton(
                context,
                icon: isRecording ? Icons.stop : Icons.mic_none_outlined,
                label: isRecording ? 'Stop' : 'Start Recording',
                onPressed: isRecording ? onVoiceNoteStop : onVoiceNoteStart,
              )
            else
              _buildGhostButton(
                context,
                icon: Icons.mic_none_outlined,
                label: 'Voice',
                onPressed: onVoiceNoteStart,
              ),
        ],
      ),
    );
  }

  Widget _buildGhostButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlackButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isDark ? Colors.black : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
