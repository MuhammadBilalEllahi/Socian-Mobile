import 'dart:convert';

import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final defaultHeaders = {"x-platform": "app"};

      // Merge default headers with any provided custom headers
      final mergedHeaders = {...defaultHeaders, if (headers != null) ...headers};

      final response = await _dio.post(
        endpoint,
        data: jsonEncode(data),
        options: Options(headers: mergedHeaders),
      );
      print("its $response");
 print("\n and its ${response.data}");
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

      // Merge default headers with any provided custom headers
      final mergedHeaders = {...defaultHeaders, if (headers != null) ...headers};

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: mergedHeaders),
      );

      return response.data as T ;
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
  return get<Map<String, dynamic>>(endpoint, headers: headers, queryParameters: queryParameters);
}

Future<List<dynamic>> getList(
  String endpoint, {
  Map<String, String>? headers,
  Map<String, dynamic>? queryParameters,
}) async {
  return get<List<dynamic>>(endpoint, headers: headers, queryParameters: queryParameters);
}


// Future<Map<String, dynamic>> getMap(
//   String endpoint, {
//   Map<String, String>? headers,
//   Map<String, dynamic>? queryParameters,
// }) async {
//   try {
//     final response = await get(endpoint, headers: headers, queryParameters: queryParameters);
//     // ignore: unnecessary_cast
//     return response as Map<String, dynamic>;
//   } catch (e) {
//     throw ApiException.fromDioError(e);
//   }
// }

// Future<List<dynamic>> getList(
//   String endpoint, {
//   Map<String, String>? headers,
//   Map<String, dynamic>? queryParameters,
// }) async {
//   try {
//     final response = await get(endpoint, headers: headers, queryParameters: queryParameters);
//     print("DATA$response");
//     return response as List<dynamic>;
//   } catch (e) {
//     throw ApiException.fromDioError(e);
//   }
// }


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



