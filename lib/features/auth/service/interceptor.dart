import 'package:dio/dio.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:elysia/features/auth/service/auth_service.dart'; // AuthService
import 'package:elysia/utiltities/core/storage.dart'; // TokenStorage
import 'package:elysia/utiltities/navigations/navigation.dart';

class AuthInterceptor extends Interceptor {
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();

  int _retryCount = 0;
  final int _maxRetries = 2;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers["Authorization"] = "Bearer $accessToken";
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _retryCount = 0;
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 403 && _retryCount < _maxRetries) {
      _retryCount++;
      try {
        await _refreshToken();
        final opts = err.requestOptions;
        final accessToken = await _tokenStorage.getAccessToken();
        final dio = Dio();
        final newRequest = await dio.request(
          opts.path,
          options: Options(
            method: opts.method,
            headers: {
              ...opts.headers,
              "Authorization": accessToken != null ? "Bearer $accessToken" : null,
            },
          ),
          data: opts.data,
          queryParameters: opts.queryParameters,
        );
        return handler.resolve(newRequest);
      } catch (refreshError) {
        await _authService.signOut();
        NavigationService.navigateToLogin();
        return handler.reject(err);
      }
    }
    if (_retryCount >= _maxRetries) {
      await _authService.signOut();
      NavigationService.navigateToLogin();
    }
    handler.next(err);
  }

  Future<void> _refreshToken() async {
    try {
      // Use Amplify Cognito to refresh session and get new tokens
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      final tokens = session.userPoolTokensResult.valueOrNull;
      if (tokens?.accessToken != null) {
        // Save new access token in secure storage and update AuthService
        await _authService.saveAccessToken(tokens!.accessToken.raw);
      } else {
        throw Exception("No access token after refresh");
      }
    } catch (e) {
      throw Exception("Refresh token failed: $e");
    }
  }
}
