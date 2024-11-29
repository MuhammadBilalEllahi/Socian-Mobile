class AuthState {
  final String? token;
  final String? error;
  final bool isLoading;
  final Map<String, dynamic>? user;

  const AuthState({
    this.token,
    this.error,
    this.isLoading = false,
    this.user,
  });


  AuthState copyWith({
    String? token,
    String? error,
    bool? isLoading,
    Map<String, dynamic>? user,
  }) {
    print("user inn state $user");
    return AuthState(
      token: token ?? this.token,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
    );
  }
}

// // class AuthState {
// //   final bool isLoading;
// //   final String? errorMessage;
// //   final Map<String, dynamic>? user;

// //   AuthState({
// //     this.isLoading = false,
// //     this.errorMessage,
// //     this.user,
// //   });

// //   AuthState copyWith({
// //     bool? isLoading,
// //     String? errorMessage,
// //     Map<String, dynamic>? user,
// //   }) {
// //     return AuthState(
// //       isLoading: isLoading ?? this.isLoading,
// //       errorMessage: errorMessage ?? this.errorMessage,
// //       user: user ?? this.user,
// //     );
// //   }
// // }

// class AuthState {
//   final String? token;
//   final String? error;
//   final bool isLoading;
//   final Map<String, dynamic>? user;

//   const AuthState({
//     this.token,
//     this.error,
//     this.isLoading = false,
//     this.user,
//   });

//   // Helper method for creating a new instance with updated values
//   AuthState copyWith({
//     String? token,
//     String? error,
//     bool? isLoading,
//     Map<String, dynamic>? user,
//   }) {
//     return AuthState(
//       token: token ?? this.token,
//       error: error ?? this.error,
//       isLoading: isLoading ?? this.isLoading,
//       user: user ?? this.user,
//     );
//   }
// }
