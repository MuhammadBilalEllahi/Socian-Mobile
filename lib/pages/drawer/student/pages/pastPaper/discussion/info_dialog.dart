import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../../../pages/message/ChatPage.dart';
import '../../../../../../pages/profile/ProfilePage.dart';

class InfoDialog extends StatefulWidget {
  final Map<String, dynamic> file;
  final Map<String, dynamic> paper;
  final int fileIndex;

  const InfoDialog({
    super.key,
    required this.file,
    required this.paper,
    required this.fileIndex,
  });

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  late Map<String, dynamic> paper;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  String downloadStatus = '';
  final apiClient = ApiClient();
  final dio = Dio();

  @override
  void initState() {
    super.initState();
    paper = Map<String, dynamic>.from(widget.paper);
  }

  Future<void> _trackDownload() async {
    if (isDownloading) return;

    setState(() {
      isDownloading = true;
    });

    try {
      await apiClient.post('/api/pastpaper/download/${paper['_id']}', {});

      // Update local download count
      setState(() {
        paper['metadata']['downloads'] =
            (paper['metadata']['downloads'] ?? 0) + 1;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download tracked successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error tracking download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        final manageStatus = await Permission.manageExternalStorage.request();
        if (manageStatus != PermissionStatus.granted) {
          throw Exception('Storage permission is required to save files');
        }
      }
    }
  }

  String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      final fileName = segments.last;
      // Extract the original filename if it exists
      if (fileName.contains('.pdf')) {
        return 'socian-$fileName';
      }
    }
    return 'socian-past_paper_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  Future<String?> _pickSaveLocation() async {
    try {
      final fileName = _getFileNameFromUrl(widget.file['url']);

      if (Platform.isAndroid) {
        // For Android, use the default Downloads directory
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final downloadsPath = '${directory.path}/Download';
          final downloadsDir = Directory(downloadsPath);
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          return '$downloadsPath/$fileName';
        }
      } else {
        // For iOS and other platforms, let user pick the location
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save PDF file',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        return outputFile;
      }
    } catch (e) {
      print('Error picking save location: $e');
    }
    return null;
  }

  void _showDownloadSuccessDialog(String savePath) {
    // Extract only the path from "/Download/" onwards
    String displayPath = savePath;
    final downloadIndex = savePath.indexOf('/Download/');
    if (downloadIndex != -1) {
      displayPath = savePath.substring(downloadIndex);
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
        final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
        final accent =
            isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
        final border =
            isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
        final mutedForeground =
            isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

        return AlertDialog(
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Download Complete!',
                style: TextStyle(
                  color: foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your PDF has been successfully downloaded.',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saved to:',
                        style: TextStyle(
                          color: mutedForeground,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        displayPath,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: mutedForeground,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final result = await OpenFilex.open(savePath);
                  if (result.type != ResultType.done) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Could not open file: ${result.message}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  print('Error opening file: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open file: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text(
                'Open File',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadFile() async {
    if (isDownloading) return;

    setState(() {
      isDownloading = true;
      downloadProgress = 0.0;
      downloadStatus = 'Preparing download...';
    });

    try {
      // Request storage permission
      await _requestStoragePermission();

      // Pick save location
      setState(() {
        downloadStatus = 'Choosing save location...';
      });

      final savePath = await _pickSaveLocation();
      if (savePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Track download first
      await _trackDownload();

      // Download file
      setState(() {
        downloadStatus = 'Downloading...';
      });

      final url = "${ApiConstants.baseUrl}/api/uploads/${widget.file['url']}";

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
              downloadStatus =
                  'Downloading... ${(downloadProgress * 100).toStringAsFixed(1)}%';
            });
          }
        },
      );

      setState(() {
        downloadStatus = 'Download completed!';
      });

      if (mounted) {
        _showDownloadSuccessDialog(savePath);
      }
    } catch (e) {
      setState(() {
        downloadStatus = 'Download failed';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() {
        isDownloading = false;
        downloadProgress = 0.0;
        downloadStatus = '';
      });
    }
  }

  String formatUploadedDate(String rawDate) {
    final date = DateTime.parse(rawDate);
    final day = date.day;
    final suffix = (day >= 11 && day <= 13)
        ? 'th'
        : [
            'th',
            'st',
            'nd',
            'rd',
            'th',
            'th',
            'th',
            'th',
            'th',
            'th'
          ][day % 10];
    return '$day$suffix ${DateFormat('MMM yyyy hh:mm a').format(date)}';
  }

  Widget _buildInfoRow(
      String label, String value, Color foreground, Color mutedForeground) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Shadcn-style color scheme
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
    final primary =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFF18181B);

    return Dialog(
      backgroundColor: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 32,
                    color: primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Past Paper Info',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: foreground,
                          ),
                        ),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'File Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border),
                ),
                child: Text(
                  'File ${widget.fileIndex + 1}',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PDF URL:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () async {
                  final url =
                      "${ApiConstants.baseUrl}/api/uploads/${widget.file['url']}";
                  try {
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not open URL: $url'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error opening URL: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                onLongPress: () {
                  final url =
                      "${ApiConstants.baseUrl}/api/uploads/${widget.file['url']}";
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: background,
                      title: Text(
                        'PDF URL',
                        style: TextStyle(color: foreground),
                      ),
                      content: SelectableText(
                        url,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: foreground,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Close',
                            style: TextStyle(color: primary),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(
                                  Uri.parse(url),
                                  mode: LaunchMode.externalApplication,
                                );
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error opening URL: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Open',
                            style: TextStyle(color: primary),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${ApiConstants.baseUrl}/api/uploads/${widget.file['url']}",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: foreground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Download Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDownloading) ...[
                      Text(
                        downloadStatus,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: downloadProgress,
                        backgroundColor: border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isDownloading ? null : _downloadFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: border,
                          disabledForegroundColor: mutedForeground,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: isDownloading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.download, size: 20),
                        label: Text(
                          isDownloading
                              ? 'Downloading...'
                              : 'Download to Device',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Upload Information:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(
                                  userId: widget.file['uploadedBy']['_id'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.person,
                              color: primary,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.file['uploadedBy']['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: foreground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${widget.file['uploadedBy']['username']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.file['uploadedBy']['universityEmail'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: muted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Uploaded at: ${formatUploadedDate(widget.file['uploadedAt'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedForeground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Implement connect functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Connect functionality coming soon!'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Connect',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.message,
                            color: primary,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  userId: widget.file['uploadedBy']['_id'],
                                  userName: widget.file['uploadedBy']['name'],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.file['teachers'] != null &&
                  widget.file['teachers'].isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Associated Teachers:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.file['teachers']
                    .map<Widget>((teacher) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (teacher['imageUrl'] != null)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfilePage(
                                              userId: teacher['_id'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                teacher['imageUrl']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    GestureDetector(
                                      onTap: () {
                                        if (teacher['userAttachedBool'] ==
                                            true) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProfilePage(
                                                userId: teacher['userAttached']
                                                    ['_id'],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: primary.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: primary,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (teacher['userAttachedBool'] ==
                                                true) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfilePage(
                                                    userId:
                                                        teacher['userAttached']
                                                            ['_id'],
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                teacher['name'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: foreground,
                                                ),
                                              ),
                                              if (teacher['userAttachedBool'] ==
                                                  true) ...[
                                                const Icon(
                                                  Icons.verified,
                                                  color: Colors.blue,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                              ]
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          teacher['email'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: mutedForeground,
                                          ),
                                        ),
                                        if (teacher['campusOrigin'] !=
                                            null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            teacher['campusOrigin']['name'] ??
                                                'Unknown Campus',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: mutedForeground,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (teacher['department'] != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: muted,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Department: ${teacher['department']['name']}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: mutedForeground,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Row(
                                children: [
                                  if (teacher['onLeave'] != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: teacher['onLeave']
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        teacher['onLeave']
                                            ? 'On Leave'
                                            : 'Activly Teaching',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: teacher['onLeave']
                                              ? Colors.orange
                                              : Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  if (teacher['rating'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 14,
                                            color: primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${teacher['rating']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.message,
                                      color: primary,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            userId: teacher['_id'],
                                            userName: teacher['name'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (teacher['feedbackSummary'] != null &&
                                  teacher['feedbackSummary'].isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Recent Feedback:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: foreground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: muted,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    teacher['feedbackSummary'][0]['summary'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: mutedForeground,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement connect functionality for teachers
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Connect with ${teacher['name']} coming soon!'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Connect with ${teacher['name']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
              const SizedBox(height: 16),
              Text(
                'Paper Details:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Paper Name', paper['name'], foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Type', paper['type'], foreground, mutedForeground),
                    _buildInfoRow('Category', paper['category'], foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Term', paper['term'], foreground, mutedForeground),
                    _buildInfoRow(
                        'Academic Year',
                        paper['academicYear'].toString(),
                        foreground,
                        mutedForeground),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Metadata:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                        'Views',
                        paper['metadata']['views'].toString(),
                        foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Downloads',
                        paper['metadata']['downloads'].toString(),
                        foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Answers',
                        paper['metadata']['answers'].toString(),
                        foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Total Questions',
                        paper['metadata']['totalQuestions'].toString(),
                        foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Answered Questions',
                        paper['metadata']['answeredQuestions'].toString(),
                        foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Last Accessed',
                        formatUploadedDate(paper['metadata']['lastAccessed']),
                        foreground,
                        mutedForeground),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
