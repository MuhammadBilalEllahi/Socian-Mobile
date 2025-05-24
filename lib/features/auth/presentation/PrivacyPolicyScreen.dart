// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// void showPrivacyPolicyBottomSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.black,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//     ),
//     builder: (context) {
//       return DraggableScrollableSheet(
//         expand: false,
//         builder: (context, scrollController) {
//           return Column(
//             children: [
//               Expanded(
//                 child: Scrollbar(
//                   thumbVisibility: true,
//                   child: SingleChildScrollView(
//                     controller: scrollController,
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                     child: DefaultTextStyle(
//                       style: const TextStyle(color: Colors.white, fontSize: 14),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("Privacy Policy for Socian", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 8),
//                           const Text("Effective Date: May 24, 2025", style: TextStyle(color: Colors.grey)),
//                           const SizedBox(height: 16),
//                           const Text(
//                               "Socian (“we”, “our”, or “us”) is committed to protecting your privacy. "
//                               "This Privacy Policy outlines how we collect, use, share, and protect your "
//                               "information through the Socian mobile application (“App”)."),
//                           const SizedBox(height: 8),
//                           const Text(
//                               "This policy complies with Google Play Developer Policies and reflects our "
//                               "responsibilities regarding personal, device, and sensitive user data."),
//                           const SizedBox(height: 24),
//                           sectionTitle("1. Information We Collect"),
//                           sectionBullet("a. Personal Information – Name, email (Google Sign-In), profile picture, university/student ID, society memberships, and roles."),
//                           sectionBullet("b. Device Info – Device model, OS version, IP, and crash logs."),
//                           sectionBullet("c. Media & File Access – For camera, gallery, and PDF uploads."),
//                           sectionBullet("d. Location Data – To suggest and manage society-based events and activities."),
//                           sectionBullet("e. Usage Analytics – Collected through PostHog to improve user experience."),
//                           const SizedBox(height: 24),
//                           sectionTitle("2. How We Use Your Information"),
//                           sectionList([
//                             "Authenticate users via Google Sign-In",
//                             "Manage academic and society-based roles",
//                             "Enable post creation and media/document uploads",
//                             "Suggest location-based events",
//                             "Improve user experience with analytics"
//                           ]),
//                           const SizedBox(height: 24),
//                           sectionTitle("3. Data Sharing and Disclosure"),
//                           const Text("We do not sell or rent your data. Limited sharing may occur:"),
//                           sectionList([
//                             "With third-party services (e.g., Firebase, PostHog)",
//                             "With other users (limited profile visibility)",
//                             "With law enforcement if legally required"
//                           ]),
//                           const SizedBox(height: 24),
//                           sectionTitle("4. Data Retention"),
//                           const Text("Data is kept as long as your account is active. You can request deletion at any time by contacting us."),
//                           const SizedBox(height: 24),
//                           sectionTitle("5. Children’s Privacy"),
//                           const Text("Socian is not intended for children under 13. If such data is found, we will delete it promptly."),
//                           const SizedBox(height: 24),
//                           sectionTitle("6. Your Rights"),
//                           sectionList([
//                             "Access, update, or delete your data",
//                             "Revoke device permissions (camera, location, etc.)",
//                             "Request opt-out from analytics"
//                           ]),
//                           const SizedBox(height: 8),
//                           linkText("privacy@socian.app", "mailto:privacy@socian.app"),
//                           const SizedBox(height: 24),
//                           sectionTitle("7. Data Security"),
//                           const Text("We use encryption, HTTPS, and access control to protect your data. However, no method is 100% secure."),
//                           const SizedBox(height: 24),
//                           sectionTitle("8. Policy Updates"),
//                           const Text("We may revise this policy periodically. Users will be notified of major changes via email or in-app."),
//                           const Text("Last updated: May 24, 2025", style: TextStyle(color: Colors.grey)),
//                           const SizedBox(height: 24),
//                           sectionTitle("Contact Us"),
//                           const Text("If you have questions about this Privacy Policy, contact:"),
//                           linkText("privacy@socian.app", "mailto:privacy@socian.app"),
//                           linkText("https://socian.app/privacy", "https://socian.app/privacy"),
//                           const Text("Country: Pakistan"),
//                           const SizedBox(height: 24),
//                           sectionTitle("9. Use of PostHog Analytics"),
//                           const Text(
//                               "Socian uses PostHog Analytics to understand how users interact with our app and to improve features, usability, and performance."),
//                           const Text(
//                               "PostHog may collect aggregated, non-personal data such as device type, screen usage patterns, interaction flow, and performance events. "
//                               "No personally identifiable information (PII) is collected unless explicitly stated and consented to."),
//                           const Text("We do not use PostHog for advertising or cross-app tracking."),
//                           const Text("You can learn more here:"),
//                           linkText("https://posthog.com/privacy", "https://posthog.com/privacy"),
//                           const SizedBox(height: 24),
//                           sectionTitle("10. Analytics and Tracking"),
//                           const Text("Socian uses PostHog to collect and analyze app usage data."),
//                           sectionList([
//                             "Device Information: model, OS version, screen size, manufacturer.",
//                             "App Information: app version, build number, session duration, events like \"App Opened\" and \"App Installed\".",
//                             "Interaction Data: taps, scrolls, screen transitions, and navigation (autocapture).",
//                             "Network Data: network type (Wi-Fi/cellular), carrier (not IP address).",
//                             "Session Recordings: Anonymous playback of app usage sessions."
//                           ]),
//                           const Text(
//                               "PostHog does not collect personal identifiers like your name, email, passwords, or form contents. Session recordings are anonymized."),
//                           linkText("PostHog Privacy Policy", "https://posthog.com/docs/privacy"),
//                           const SizedBox(height: 40),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Accept", style: TextStyle(color: Colors.white)),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }

// // Reusable section title
// Widget sectionTitle(String text) {
//   return Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//   );
// }

// // Reusable bullet point
// Widget sectionBullet(String text) {
//   return Padding(
//     padding: const EdgeInsets.only(bottom: 4),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
//         Expanded(child: Text(text)),
//       ],
//     ),
//   );
// }

// // Reusable bullet list
// Widget sectionList(List<String> items) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: items.map(sectionBullet).toList(),
//   );
// }

// // Reusable link
// Widget linkText(String text, String url) {
//   return GestureDetector(
//     onTap: () => launchUrl(Uri.parse(url)),
//     child: Padding(
//       padding: const EdgeInsets.only(top: 4, bottom: 4),
//       child: Text(text, style: const TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline)),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'privacy@socian.app',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget bulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(color: Colors.white)),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 14))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, false); // Did not accept
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Privacy Policy for Socian",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 6),
              const Text("Effective Date: May 24, 2025",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),

              const SizedBox(height: 20),
              const Text(
                "Socian (“we”, “our”, or “us”) is committed to protecting your privacy. "
                "This Privacy Policy outlines how we collect, use, share, and protect your information through the Socian mobile application (“App”).\n\n"
                "This policy complies with Google Play Developer Policies and reflects our responsibilities regarding personal, device, and sensitive user data.",
                style: TextStyle(color: Colors.white),
              ),

              sectionTitle("1. Information We Collect"),
              bulletPoint("a. Personal Information – Name, email (Google Sign-In), profile picture, university/student ID, society memberships, and roles."),
              bulletPoint("b. Device Info – Device model, OS version, IP, and crash logs."),
              bulletPoint("c. Media & File Access – For camera, gallery, and PDF uploads."),
              bulletPoint("d. Location Data – To suggest and manage society-based events and activities."),
              bulletPoint("e. Usage Analytics – Collected through PostHog to improve user experience."),

              sectionTitle("2. How We Use Your Information"),
              bulletPoint("Authenticate users via Google Sign-In"),
              bulletPoint("Manage academic and society-based roles"),
              bulletPoint("Enable post creation and media/document uploads"),
              bulletPoint("Suggest location-based events"),
              bulletPoint("Improve user experience with analytics"),

              sectionTitle("3. Data Sharing and Disclosure"),
              const Text(
                "We do not sell or rent your data. Limited sharing may occur:",
                style: TextStyle(color: Colors.white),
              ),
              bulletPoint("With third-party services (e.g., Firebase, PostHog)"),
              bulletPoint("With other users (limited profile visibility)"),
              bulletPoint("With law enforcement if legally required"),

              sectionTitle("4. Data Retention"),
              const Text(
                "Data is kept as long as your account is active. You can request deletion at any time by contacting us.",
                style: TextStyle(color: Colors.white),
              ),

              sectionTitle("5. Children’s Privacy"),
              const Text(
                "Socian is not intended for children under 13. If such data is found, we will delete it promptly.",
                style: TextStyle(color: Colors.white),
              ),

              sectionTitle("6. Your Rights"),
              bulletPoint("Access, update, or delete your data"),
              bulletPoint("Revoke device permissions (camera, location, etc.)"),
              bulletPoint("Request opt-out from analytics"),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _launchEmail,
                child: const Text(
                  "Email: privacy@socian.app",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline),
                ),
              ),

              sectionTitle("7. Data Security"),
              const Text(
                "We use encryption, HTTPS, and access control to protect your data. However, no method is 100% secure.",
                style: TextStyle(color: Colors.white),
              ),

              sectionTitle("8. Policy Updates"),
              const Text(
                "We may revise this policy periodically. Users will be notified of major changes via email or in-app.",
                style: TextStyle(color: Colors.white),
              ),
              const Text(
                "Last updated: May 24, 2025",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              sectionTitle("Contact Us"),
              const Text("If you have questions about this Privacy Policy, contact:",
                  style: TextStyle(color: Colors.white)),
              GestureDetector(
                onTap: _launchEmail,
                child: const Text("Email: privacy@socian.app",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline)),
              ),
              GestureDetector(
                onTap: () => _launchUrl("https://socian.app/privacy"),
                child: const Text("Website: https://socian.app/privacy",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline)),
              ),
              const Text("Country: Pakistan",
                  style: TextStyle(color: Colors.white)),

              sectionTitle("9. Use of PostHog Analytics"),
              const Text(
                "Socian uses PostHog Analytics to understand how users interact with our app and to improve features, usability, and performance.",
                style: TextStyle(color: Colors.white),
              ),
              const Text(
                "PostHog may collect aggregated, non-personal data such as device type, screen usage patterns, interaction flow, and performance events. No personally identifiable information (PII) is collected unless explicitly stated and consented to.",
                style: TextStyle(color: Colors.white),
              ),
              const Text(
                "We do not use PostHog for advertising or cross-app tracking. Data collected is solely for internal usage analytics and product improvement.",
                style: TextStyle(color: Colors.white),
              ),
              GestureDetector(
                onTap: () => _launchUrl("https://posthog.com/privacy"),
                child: const Text(
                  "Learn more: https://posthog.com/privacy",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline),
                ),
              ),
              const Text(
                "Currently, we only capture anonymous website usage analytics through PostHog to improve web experience. User content remains hidden from PostHog and us.",
                style: TextStyle(color: Colors.white),
              ),

              sectionTitle("10. Analytics and Tracking"),
              bulletPoint("Device Information: model, OS version, screen size, manufacturer."),
              bulletPoint("App Information: app version, build number, session duration, events like 'App Opened' and 'App Installed'."),
              bulletPoint("Interaction Data: taps, scrolls, screen transitions, and navigation (autocapture)."),
              bulletPoint("Network Data: network type (Wi-Fi/cellular), carrier (not IP address)."),
              bulletPoint("Session Recordings: Anonymous playback of app usage sessions (e.g., screen flow, UI interactions)."),
              const Text(
                "What We Don’t Collect: PostHog is configured not to collect personal identifiers such as your name, email address, or input data like passwords or uploaded files. Session recordings are anonymized.",
                style: TextStyle(color: Colors.white),
              ),
              GestureDetector(
                onTap: () => _launchUrl("https://posthog.com/docs/privacy"),
                child: const Text(
                  "PostHog Privacy Policy",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true); // Accepted the policy
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Accept and Continue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}