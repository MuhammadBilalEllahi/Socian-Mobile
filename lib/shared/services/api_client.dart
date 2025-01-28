import 'dart:convert';

import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
      // connectTimeout: const Duration(seconds: 5), // Updated to Duration
      // receiveTimeout: const Duration(seconds: 5), //NO NEED FOR NOW
        ));

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final defaultHeaders = {"x-platform": "app"};
          final token = await SecureStorageService.instance.getToken();


      // Merge default headers with any provided custom headers
      final mergedHeaders = {...defaultHeaders, 
      if (token != null) "Authorization": "Bearer $token",
      if (headers != null) ...headers};



      final response = await _dio.post(
        endpoint,
        data: jsonEncode(data),
        options: Options(headers: mergedHeaders),
      );
//       print("its $response");
//  print("\n and its ${response.data}");
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
      // print("Ae $endpoint");
      final defaultHeaders = {"x-platform": "app"};
          final token = await SecureStorageService.instance.getToken();

      // Merge default headers with any provided custom headers
      final mergedHeaders = {...defaultHeaders,
            if (token != null) "Authorization": "Bearer $token",
       if (headers != null) ...headers};

// print("A /${_dio.httpClientAdapter}");
// print("Ah $mergedHeaders");
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: mergedHeaders),
      );
      
      // print(endpoint);
      // print("$response");

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
  // print("Ar $endpoint ");
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



