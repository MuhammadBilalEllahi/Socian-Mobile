class AuthState {
  final String? token;
  final String? error;
  final bool isLoading;
  final Map<String, dynamic>? user;
  final String? role;
  final String? superRole;

  const AuthState({
    this.token,
    this.error,
    this.isLoading = false,
    this.user,
    this.role,
    this.superRole,
  });

  factory AuthState.initial() {
    return const AuthState(
      token: null,
      error: null,
      isLoading: false,
      user: null,
      role: null,
      superRole: null,
    );
  }

  AuthState copyWith({
    String? token,
    String? error,
    bool? isLoading,
    Map<String, dynamic>? user,
    String? role,
    String? superRole,
  }) {
    return AuthState(
      token: token ?? this.token,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      role: role ?? this.role,
      superRole: superRole ?? this.superRole,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.token == token &&
        other.error == error &&
        other.isLoading == isLoading &&
        other.role == role &&
        other.superRole == superRole &&
        mapEquals(other.user, user);
  }

  @override
  int get hashCode {
    return Object.hash(token, error, isLoading, role, superRole, user);
  }
}

bool mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (var key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
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
