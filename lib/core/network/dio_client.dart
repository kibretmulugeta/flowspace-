/// Production Dio HTTP Client for FlowSpace
/// Configured with authentication interceptors, timeouts, token refresh, and user-friendly error mapping.
library;

import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../errors/failures.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;

  DioClient({
    Dio? customDio,
    SecureStorageService? secureStorage,
  }) : _secureStorage = secureStorage ?? SecureStorageService() {
    _dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: AppConfig.current.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
          ),
        );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach Authorization Bearer token if present
          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Handle 401 token expiration and attempt refresh
          if (error.response?.statusCode == 401) {
            final refreshToken = await _secureStorage.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                // Request a refreshed token
                final refreshResponse = await _dio.post(
                  '/auth/refresh',
                  data: {'refresh_token': refreshToken},
                  options: Options(headers: {}),
                );
                final newAccessToken = refreshResponse.data['access_token'] as String?;
                if (newAccessToken != null) {
                  await _secureStorage.saveTokens(accessToken: newAccessToken);
                  // Retry the original failed request with the new token
                  final clonedRequest = error.requestOptions;
                  clonedRequest.headers['Authorization'] = 'Bearer $newAccessToken';
                  final retryResponse = await _dio.fetch(clonedRequest);
                  return handler.resolve(retryResponse);
                }
              } catch (_) {
                await _secureStorage.clearSession();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Maps DioException to domain Failure with friendly messaging (no raw stack traces)
  Failure mapDioErrorToFailure(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkFailure(
        "You're offline. Your changes will sync when you're back online.",
      );
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return const AuthFailure(
        "Your session has expired. Please sign in again.",
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return const ServerFailure(
        "We couldn't connect to FlowSpace. Please try again.",
      );
    }

    final message = error.response?.data is Map
        ? (error.response?.data['detail'] ?? error.response?.data['message'] ?? 'An error occurred')
        : 'An unexpected error occurred. Please try again.';

    return ServerFailure(message.toString());
  }

  // --- HTTP Verbs ---

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }
}
