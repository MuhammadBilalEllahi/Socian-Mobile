import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Private constructor
  SecureStorageService._privateConstructor();

  // The single instance of the class
  static final SecureStorageService instance =
      SecureStorageService._privateConstructor();

  // Instance of FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Save token to secure storage
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
  }

  // Retrieve token from secure storage
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'token');
  }

  // Delete the token from secure storage
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'token');
  }

  // Generic field save/load/delete
  Future<void> saveField(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getField(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteField(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearSignupFields() async {
    for (final key in [
      'signup_name',
      'signup_username',
      'signup_email',
      'signup_personalEmail',
      'signup_university',
      'signup_department',
      'signup_cachedTime',
    ]) {
      await _secureStorage.delete(key: key);
    }
  }
}

// import 'package:shared_preferences/shared_preferences.dart';

// class SharedPreferencesService {
//   // Private constructor
//   SharedPreferencesService._privateConstructor();

//   // The single instance of the class
//   static final SharedPreferencesService instance = SharedPreferencesService._privateConstructor();

//   // Instance of SharedPreferences
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

//   // Save token to SharedPreferences
//   Future<void> saveToken(String token) async {
//     final SharedPreferences prefs = await _prefs;
//     await prefs.setString('token', token);
//   }

//   // Retrieve token from SharedPreferences
//   Future<String?> getToken() async {
//     final SharedPreferences prefs = await _prefs;
//     return prefs.getString('token');
//   }

//   // Delete the token from SharedPreferences
//   Future<void> deleteToken() async {
//     final SharedPreferences prefs = await _prefs;
//     await prefs.remove('token');
//   }
// }
