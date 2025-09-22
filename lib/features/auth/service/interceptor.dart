import 'package:dio/dio.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:elysia/features/auth/service/auth_service.dart'; // AuthService
import 'package:elysia/utiltities/core/storage.dart'; // TokenStorage
import 'package:elysia/utiltities/navigations/navigation.dart';

class ApiClient {
  final Dio dio = Dio();
  String? refreshToken;
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();

  int _retryCount = 0;
  final int _maxRetries = 2;

  ApiClient() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Always fetch the latest access token from TokenStorage
        final accessToken = await _tokenStorage.getAccessToken();
        if (accessToken != null) {
          options.headers["Authorization"] = "Bearer $accessToken";
        }
        options.headers['accept'] = 'application/json, text/plain, */*';
        options.headers['origin'] = 'https://elysia-qa.informa.com';
        options.headers['content-type'] = 'application/json';
        return handler.next(options);
      },
      onResponse: (response, handler) {
          final now = DateTime.now();
        _retryCount = 0;
        return handler.next(response);
      },
      onError: (DioError e, handler) async {
        if (e.response?.statusCode == 403 && _retryCount < _maxRetries) {
          _retryCount++;
          try {
            await _refreshToken();
            final opts = e.requestOptions;
            // Get the latest access token after refresh
            final accessToken = await _tokenStorage.getAccessToken();
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
            return handler.reject(e);
          }
        }
        if (_retryCount >= _maxRetries) {
          await _authService.signOut();
          NavigationService.navigateToLogin();
        }
        return handler.next(e);
      },
    ));
  }

  Future<void> _refreshToken() async {
    try {
      // Use Amplify Cognito to refresh session and get new tokens
      final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      final tokens = session.userPoolTokensResult.valueOrNull;
      if (tokens?.accessToken != null) {
        // Save new access token in secure storage and update AuthService
        await _authService.saveAccessToken(tokens!.accessToken.raw);
        // Optionally update refreshToken if needed
        refreshToken = tokens.refreshToken;
      } else {
        throw Exception("No access token after refresh");
      }
    } catch (e) {
      throw Exception("Refresh token failed: $e");
    }
  }
}
