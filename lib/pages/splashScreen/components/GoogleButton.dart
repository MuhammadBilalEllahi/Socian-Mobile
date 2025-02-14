import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/domain/auth_state.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/pages/splashScreen/components/GoogleService.dart';
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


        ref.listen<AuthState>(authProvider, (previous, next) {
    if (next.user != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  });

    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        // onTap: () {
        //   // Navigator.pushNamed(context, AppRoutes.authScreen);
        //   GoogleSignInService.signInWithGoogle(context);
        // },
//         onTap: () {
//   ref.read(googleSignInProvider.notifier).signInWithGoogle(context);
// },

onTap: authState.isLoading
            ? null
            : () => ref.read(googleSignInProvider.notifier).signInWithGoogle(context),
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          height: 45,
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
          margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 244, 244, 244)
                .withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(4),
          ),
          
          child:  authState.isLoading ?   const Center(
            
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
            color: Colors.black87,
            strokeWidth: 2.0,
          ),
            )) : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                AppAssets.googleAuth,
                width: 25,
                height: 25,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  AppConstants.googleAuth,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF121212),
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
