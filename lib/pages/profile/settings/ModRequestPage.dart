import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:socian/components/widgets/my_snackbar.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/api_client.dart';

class ModRequestPage extends ConsumerStatefulWidget {
  const ModRequestPage({super.key});

  @override
  ConsumerState<ModRequestPage> createState() => _ModRequestPageState();
}

class _ModRequestPageState extends ConsumerState<ModRequestPage> {
  String _text = "";
  String _statusText = "";
  final TextEditingController _reasonTextEditingController =
      TextEditingController();
  bool _isLoading = false;
  bool _isSubmitting = false;
  String _profilePicture = "";
  String _name = "";
  String _username = "";
  String _startTime = "";
  String _endTime = "";
  String _reason = "";
  // Premium color scheme
  static const Color primaryBlack = Color(0xFF0A0A0A);
  static const Color secondaryBlack = Color(0xFF1A1A1A);
  static const Color cardBlack = Color(0xFF1E1E1E);
  static const Color borderGray = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color goldAccentDark = Color(0xFFB8860B);

  @override
  void initState() {
    super.initState();
    checkModRequest();
  }

  void checkModRequest() async {
    setState(() => _isLoading = true);
    final apiClient = ApiClient();
    try {
      if (ref.read(authProvider).user?["super_role"] == "mod") {
        _text = "Approved";
        _statusText =
            "Congratulations! Your moderator request has been approved.";

        final response = await apiClient.get('/api/user/mod-information');
        log("MOd info $response");
        if (response["data"] != null) {
          _profilePicture = response["data"]["_id"]["profile"]["picture"];
          _name = response["data"]["_id"]["name"];
          _username = response["data"]["_id"]["username"];
          _startTime = response["data"]["startTime"];
          _endTime = response["data"]["endTime"];
          _reason = response["data"]["reason"];
        }

        return;
      }

      final response = await apiClient.get('/api/user/mod-request/status');

      if (response["access_token"] != null) {
        final token = response["access_token"];
        final user = JwtDecoder.decode(token);
        await ref.read(authProvider.notifier).updateAuthState(user, token);
      }

      if (response["status"] == "pending") {
        _text = "In Progress";
        _statusText =
            "Your moderator request is currently under review. We'll notify you once a decision is made.";
      } else if (response["status"] == "approved") {
        _text = "Approved";
        _statusText =
            "Congratulations! Your moderator request has been approved.";
      } else if (response["status"] == "rejected") {
        _text = "Rejected";
        _statusText =
            "Your moderator request has been declined. You may submit a new request with additional information.";
      } else {
        _text = "Not Submitted";
        _statusText =
            "Submit your application to become a moderator for your campus community.";
      }
    } catch (e) {
      log("Error in checkModRequest: $e");
      _text = "Error";
      _statusText = "Failed to load request status. Please try again.";
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void submitModRequest() async {
    if (ref.read(authProvider).user?["super_role"] == "mod") {
      showSnackbar(context, "You are already a moderator.");
      return;
    }
    if (_reasonTextEditingController.text.trim().isEmpty) {
      showSnackbar(
          context, "Please provide a detailed reason for your application");
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ApiClient();
      final response = await apiClient.post('/api/user/mod/request', {
        "reason": _reasonTextEditingController.text.trim(),
      });
      if (response["status"] == "Submitted") {
        _reasonTextEditingController.clear();
        showSnackbar(context, "Application submitted successfully!");
        return;
      }
      if (response["status"] == "pending") {
        _text = "In Progress";
        _statusText =
            "Your moderator request has been submitted successfully and is under review.";
        _reasonTextEditingController.clear();
        showSnackbar(context, "Application submitted successfully!");
      } else if (response["status"] == "approved") {
        _text = "Approved";
        _statusText =
            "Congratulations! Your moderator request has been approved.";
      } else if (response["status"] == "rejected") {
        _text = "Rejected";
        _statusText =
            "Your previous request was declined. This new request is now under review.";
      }
    } catch (e) {
      print(e);
      showSnackbar(context, "Failed to submit application. Please try again.");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _formatDateTime(String dateString) {
    try {
      DateTime dateTime;

      // Try parsing as ISO string first
      if (dateString.contains('T') || dateString.contains('Z')) {
        dateTime = DateTime.parse(dateString);
      } else {
        // Try parsing as milliseconds timestamp
        final timestamp = int.tryParse(dateString);
        if (timestamp != null) {
          dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else {
          return "Invalid date";
        }
      }

      // Format the date in a readable way
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      log("Error parsing date: $e");
      return "Invalid date";
    }
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    IconData iconData;

    switch (_text) {
      case "In Progress":
        badgeColor = Colors.orange;
        iconData = Icons.hourglass_empty;
        break;
      case "Approved":
        badgeColor = goldAccent;
        iconData = Icons.verified;
        break;
      case "Rejected":
        badgeColor = Colors.red;
        iconData = Icons.cancel_outlined;
        break;
      default:
        badgeColor = borderGray;
        iconData = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: badgeColor, size: 16),
          const SizedBox(width: 6),
          Text(
            _text,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: primaryBlack,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlack,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: goldAccent),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Moderator Application"),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: goldAccent),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [secondaryBlack, cardBlack],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderGray),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: goldAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: goldAccent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _text == "Approved"
                                          ? "You are a Moderator"
                                          : "Become a Moderator",
                                      style: const TextStyle(
                                        color: textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    const Text(
                                      "Lead and manage your campus community",
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _buildStatusBadge(),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryBlack,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderGray),
                            ),
                            child: Text(
                              _statusText,
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // User Information Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBlack,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderGray),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your Information",
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                              "University",
                              authState.user?["university"]["universityId"]
                                      ?["name"] ??
                                  "Not specified"),
                          _buildInfoRow(
                              "Campus",
                              authState.user?["university"]["campusId"]
                                      ?["name"] ??
                                  "Not specified"),
                          _buildInfoRow("Current Role",
                              authState.user?["role"] ?? "Student"),
                          if (_text == "Approved")
                            _buildInfoRow(
                                "Moderator Since",
                                _startTime.isNotEmpty
                                    ? _formatDateTime(_startTime)
                                    : "N/A"),
                          if (_text == "Approved")
                            _buildInfoRow(
                                "Moderator Till",
                                _endTime.isNotEmpty
                                    ? _formatDateTime(_endTime)
                                    : "N/A"),
                          if (_text == "Approved")
                            _buildInfoRow("Reason", _reason),
                          if (authState.user?["super_role"] != null)
                            _buildInfoRow(
                                "Super Role", authState.user?["super_role"]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Application Form Section
                    if (_text != "Approved" && _text != "In Progress") ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBlack,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderGray),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Application Details",
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Why do you want to become a moderator?",
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: primaryBlack,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderGray),
                              ),
                              child: TextField(
                                controller: _reasonTextEditingController,
                                maxLines: 5,
                                style: const TextStyle(color: textPrimary),
                                decoration: InputDecoration(
                                  hintText:
                                      "Describe your motivation, experience, and how you plan to contribute to the community...",
                                  hintStyle: TextStyle(
                                      color: textSecondary.withOpacity(0.7)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting ? null : submitModRequest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: goldAccent,
                                  foregroundColor: primaryBlack,
                                  disabledBackgroundColor: borderGray,
                                  disabledForegroundColor: textSecondary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: primaryBlack,
                                        ),
                                      )
                                    : const Text(
                                        "Submit Application",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Benefits Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBlack,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderGray),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Moderator Benefits",
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildBenefitItem(
                              "Manage community content and discussions"),
                          _buildBenefitItem(
                              "Help maintain a positive campus environment"),
                          _buildBenefitItem(
                              "Access to advanced moderation tools"),
                          _buildBenefitItem(
                              "Leadership recognition in your campus"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: goldAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reasonTextEditingController.dispose();
    super.dispose();
  }
}
