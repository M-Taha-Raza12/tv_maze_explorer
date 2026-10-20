import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_exceptions.dart';

/// Network client wrapper around [Dio] for calling the TVMaze API.
class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                responseType: ResponseType.json,
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  /// Performs a GET request with unified error handling.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (dioError) {
      throw _handleDioError(dioError);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.cancel) {
      return const ApiException('Request was cancelled.');
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.error is SocketException) {
      return const NetworkException(
        'Unable to connect to TVMaze. Please verify your internet connection.',
      );
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 404) {
      return const NotFoundException('Requested TV show or resource not found.');
    }
    if (statusCode != null && statusCode >= 500) {
      return ServerException('TVMaze server is currently unavailable (HTTP $statusCode).');
    }

    return ApiException(
      error.response?.statusMessage ?? error.message ?? 'An unexpected network error occurred.',
      statusCode,
    );
  }
}
