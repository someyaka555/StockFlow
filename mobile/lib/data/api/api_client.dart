import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class ApiClient {
  static final ApiClient _i = ApiClient._();
  factory ApiClient() => _i;
  ApiClient._();

  Dio? _dio;
  String? _lastBase;

  Dio get dio {
    final base = AppConstants.apiBaseUrl;
    if (_dio == null || _lastBase != base) {
      _lastBase = base;
      _dio = Dio(BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ));
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (e, handler) {
          final msg = _extract(e);
          handler.next(DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            message: msg,
            error: msg,
          ));
        },
      ));
    }
    return _dio!;
  }

  String _extract(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'];
    return e.message ?? 'Terjadi kesalahan jaringan';
  }
}