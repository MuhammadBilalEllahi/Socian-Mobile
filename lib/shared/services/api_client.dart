// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:html' as html;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:socian/shared/services/secure_storage_service.dart';
import 'package:socian/shared/utils/constants.dart';
import 'package:socian/shared/utils/platform/file/io_checker.dart';
import 'package:universal_io/io.dart';

class ApiClient {
  final Dio _dio;

  String? _deviceId;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
            )) {
    if (!kIsWeb) {
      _initDeviceId();
    }
  }

  Future<void> _initDeviceId() async {
    if (kIsWeb) {
      _deviceId = "web";
      return;
    }

    // First try to get stored device ID
    _deviceId = await SecureStorageService.instance.getDeviceId();

// If no stored device ID, generate a new one
    if (_deviceId == null || _deviceId!.isEmpty) {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id ?? 'unknown';
        log('androidInfo.id: ${androidInfo.id}');
        if (_deviceId != 'unknown') {
          SecureStorageService.instance.saveDeviceId(_deviceId!);
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor ?? 'unknown';
        if (_deviceId != 'unknown') {
          SecureStorageService.instance.saveDeviceId(_deviceId!);
        }
      } else {
        _deviceId = 'unknown';
      }
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final defaultHeaders = {
        "x-platform": "app",
        if (_deviceId != null) "x-device-id": _deviceId!,
      };
      final token = await SecureStorageService.instance.getToken();

      final mergedHeaders = {
        ...defaultHeaders,
        if (token != null) "Authorization": "Bearer $token",
        if (headers != null) ...headers
      };

      final response = await _dio.post(
        endpoint,
        data: jsonEncode(data),
        options: Options(headers: mergedHeaders),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> postFormData(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final defaultHeaders = {
        "x-platform": "app",
        if (_deviceId != null) "x-device-id": _deviceId!,
        "Content-Type": "multipart/form-data",
      };

      final token = await SecureStorageService.instance.getToken();

      final mergedHeaders = {
        ...defaultHeaders,
        if (token != null) "Authorization": "Bearer $token",
        if (headers != null) ...headers,
      };

      // Convert File objects to MultipartFile objects
      final processedData = await _processFormData(data);
      FormData formData = FormData.fromMap(processedData);

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: mergedHeaders),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> putFormData(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final defaultHeaders = {
        "x-platform": "app",
        if (_deviceId != null) "x-device-id": _deviceId!,
        "Content-Type": "multipart/form-data",
      };

      final token = await SecureStorageService.instance.getToken();

      final mergedHeaders = {
        ...defaultHeaders,
        if (token != null) "Authorization": "Bearer $token",
        if (headers != null) ...headers,
      };

      // Convert File objects to MultipartFile objects
      final processedData = await _processFormData(data);
      FormData formData = FormData.fromMap(processedData);

      final response = await _dio.put(
        endpoint,
        data: formData,
        options: Options(headers: mergedHeaders),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> _processFormData(
      Map<String, dynamic> data) async {
    final processedData = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (kIsWeb) {
        if (value is html.File) {
          final reader = html.FileReader();
          final completer = Completer<Uint8List>();
          reader.readAsArrayBuffer(value);
          reader.onLoadEnd.listen((event) {
            completer.complete(reader.result as Uint8List);
          });
          final bytes = await completer.future;

          processedData[key] = MultipartFile.fromBytes(
            bytes,
            filename: value.name,
            contentType: MediaType.parse(value.type),
          );
        } else {
          processedData[key] = value;
        }
      } else {
        if (IoChecker.isFile(value)) {
          processedData[key] = await MultipartFile.fromFile(
            value.path,
            filename: value.path.split('/').last,
          );
        } else if (IoChecker.isListOfFiles(value)) {
          final multipartFiles = <MultipartFile>[];
          for (final file in value) {
            multipartFiles.add(await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ));
          }
          processedData[key] = multipartFiles;
        } else {
          processedData[key] = value;
        }
      }
    }

    return processedData;
  }

  // Helper method to process form data and convert File objects to MultipartFile
  // Future<Map<String, dynamic>> _processFormData(
  //     Map<String, dynamic> data) async {
  //   final processedData = <String, dynamic>{};

  //   for (final entry in data.entries) {
  //     final key = entry.key;
  //     final value = entry.value;
  //     if (!kIsWeb) {
  //       if (value is File) {
  //         // Convert single File to MultipartFile
  //         processedData[key] = await MultipartFile.fromFile(
  //           value.path,
  //           filename: value.path.split('/').last,
  //         );
  //       } else if (value is List<File>) {
  //         // Convert List<File> to List<MultipartFile>
  //         final multipartFiles = <MultipartFile>[];
  //         for (final file in value) {
  //           multipartFiles.add(await MultipartFile.fromFile(
  //             file.path,
  //             filename: file.path.split('/').last,
  //           ));
  //         }
  //         processedData[key] = multipartFiles;
  //       } else {
  //         // Keep other values as is
  //         processedData[key] = value;
  //       }
  //     }
  //   }

  //   return processedData;
  // }

  Future<T> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final defaultHeaders = {
        "x-platform": "app",
        if (_deviceId != null) "x-device-id": _deviceId!,
      };
      final token = await SecureStorageService.instance.getToken();

      final mergedHeaders = {
        ...defaultHeaders,
        if (token != null) "Authorization": "Bearer $token",
        if (headers != null) ...headers
      };

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: mergedHeaders),
      );

      return response.data as T;
    } catch (e) {
      debugPrint("Error in DIO GET $e");
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getMap(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return get<Map<String, dynamic>>(endpoint,
        headers: headers, queryParameters: queryParameters);
  }

  Future<List<dynamic>> getList(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return get<List<dynamic>>(endpoint,
        headers: headers, queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final defaultHeaders = {
      "x-platform": "app",
      if (_deviceId != null) "x-device-id": _deviceId!,
    };
    final token = await SecureStorageService.instance.getToken();

    final mergedHeaders = {
      ...defaultHeaders,
      if (token != null) "Authorization": "Bearer $token",
      if (headers != null) ...headers
    };

    final response = await _dio.delete(endpoint,
        options: Options(headers: mergedHeaders),
        queryParameters: queryParameters);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic>? data, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final defaultHeaders = {
      "x-platform": "app",
      if (_deviceId != null) "x-device-id": _deviceId!,
    };
    final token = await SecureStorageService.instance.getToken();

    final mergedHeaders = {
      ...defaultHeaders,
      if (token != null) "Authorization": "Bearer $token",
      if (headers != null) ...headers
    };
    final response = await _dio.patch(endpoint,
        data: data,
        options: Options(headers: mergedHeaders),
        queryParameters: queryParameters);
    return response.data as Map<String, dynamic>;
  }

  Future<String> getCurrentUserId() async {
    try {
      final response = await getMap('/api/user/me');
      final userId = response['_id'] as String?;
      if (userId == null) {
        throw ApiException('User ID not found in response');
      }
      return userId;
    } catch (e) {
      throw ApiException('Failed to fetch current user ID: $e');
    }
  }

  // Add this method to your ApiClient class
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final defaultHeaders = {
        "x-platform": "app",
        if (_deviceId != null) "x-device-id": _deviceId!,
      };
      final token = await SecureStorageService.instance.getToken();

      final mergedHeaders = {
        ...defaultHeaders,
        if (token != null) "Authorization": "Bearer $token",
        if (headers != null) ...headers,
      };

      final response = await _dio.put(
        endpoint,
        data: jsonEncode(data),
        options: Options(headers: mergedHeaders),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  static ApiException fromDioError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      String readableMessage = "Unexpected error";
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        readableMessage = data['error'].toString();
      } else if (data is String) {
        readableMessage = data;
      }

      switch (error.type) {
        case DioExceptionType.badResponse:
          return ApiException(" $readableMessage");
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException("Connection timeout");
        case DioExceptionType.cancel:
          return ApiException("Request was cancelled");
        default:
          return ApiException("Unexpected error: ${error.message}");
      }
    }
    return ApiException("Unexpected error: $error");
  }

  @override
  String toString() => message;
}

class ExternalApiClient {
  final Dio _dio;
  String? _deviceId;

  ExternalApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
            )) {
    if (!kIsWeb) {
      _initDeviceId();
    }
  }
  Future<void> _initDeviceId() async {
    // First try to get stored device ID
    _deviceId = await SecureStorageService.instance.getDeviceId();

    if (!kIsWeb) {
      // If no stored device ID, generate a new one
      if (_deviceId == null || _deviceId!.isEmpty) {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          _deviceId = androidInfo.id ?? 'unknown';
          log('androidInfo.id: ${androidInfo.id}');
          if (_deviceId != 'unknown') {
            SecureStorageService.instance.saveDeviceId(_deviceId!);
          }
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          _deviceId = iosInfo.identifierForVendor ?? 'unknown';
          if (_deviceId != 'unknown') {
            SecureStorageService.instance.saveDeviceId(_deviceId!);
          }
        } else {
          _deviceId = 'unknown';
        }
      }
    }
  }

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final defaultHeaders = {
        "x-platform": "app",
        if (_deviceId != null) "x-device-id": _deviceId!,
      };

      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: {
          ...defaultHeaders,
          if (headers != null) ...headers,
        }),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final defaultHeaders = {
        "x-platform": "app",
        if (_deviceId != null) "x-device-id": _deviceId!,
      };

      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: {
          ...defaultHeaders,
          if (headers != null) ...headers,
        }),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
