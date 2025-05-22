import 'package:socian/core/utils/constants.dart';
import 'package:socian/features/auth/domain/auth_state.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/splashScreen/components/GoogleService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoogleButton extends ConsumerStatefulWidget {
  const GoogleButton({super.key});

  @override
  _GoogleButtonState createState() => _GoogleButtonState();
}

class _GoogleButtonState extends ConsumerState<GoogleButton> {
  final googleSignInProvider =
      StateNotifierProvider<GoogleSignInService, AuthState>(
          (ref) => GoogleSignInService());

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(googleSignInProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: authState.isLoading
            ? null
            : () => ref
                .read(googleSignInProvider.notifier)
                .signInWithGoogle(context),
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          height: 45,
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
          margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color.fromARGB(255, 51, 51, 51).withOpacity(0.88)
                : const Color.fromARGB(255, 244, 244, 244).withOpacity(0.88),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.2)
                  : const Color.fromARGB(255, 187, 187, 187),
              width: 1,
            ),
          ),
          child: authState.isLoading
              ? Center(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      color: isDarkMode ? Colors.white : Colors.black,
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.asset(
                      AppAssets.googleAuth,
                      width: 25,
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        AppConstants.googleAuth,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF121212),
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
