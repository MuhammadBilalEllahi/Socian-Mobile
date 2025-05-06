import 'dart:convert';

import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
            ));

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final defaultHeaders = {"x-platform": "app"};
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
        "Content-Type": "multipart/form-data",
      };

      final token = await SecureStorageService.instance.getToken();

      final mergedHeaders = {
        ...defaultHeaders,
        if (token != null) "Authorization": "Bearer $token",
        if (headers != null) ...headers,
      };

      FormData formData = FormData.fromMap(data);

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
        "Content-Type": "multipart/form-data",
      };

      final token = await SecureStorageService.instance.getToken();

      final mergedHeaders = {
        ...defaultHeaders,
        if (token != null) "Authorization": "Bearer $token",
        if (headers != null) ...headers,
      };

      FormData formData = FormData.fromMap(data);

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

  Future<T> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final defaultHeaders = {"x-platform": "app"};
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
      print("Error in DIO GET $e");
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
    final defaultHeaders = {"x-platform": "app"};
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
    final defaultHeaders = {"x-platform": "app"};
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
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  static ApiException fromDioError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.badResponse:
          return ApiException(
              "Error: ${error.response?.statusCode} - ${error.response?.data}");
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

  ExternalApiClient({Dio? dio}) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
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
      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: headers),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
