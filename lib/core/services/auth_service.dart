import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

import '../config/app_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api;

  AuthService(this._api);

  // Send OTP to phone number
  Future<Map<String, dynamic>> sendOtp({
    required String phone,
    required String purpose, // 'login' or 'registration'
    String? sponsorPhone,
  }) async {
    final response = await _api.post(
      AppConfig.sendOtpEndpoint,
      data: {
        'phone': phone,
        'purpose': purpose,
        if (sponsorPhone != null) 'sponsor_phone': sponsorPhone,
      },
    );

    return response.data;
  }

  // Verify OTP and login/register
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    String? deviceToken,
  }) async {
    final deviceInfo = await _getDeviceInfo();

    final response = await _api.post(
      AppConfig.verifyOtpEndpoint,
      data: {
        'phone': phone,
        'otp': otp,
        'device_token': deviceToken,
        'platform': deviceInfo['platform'],
        'app_version': deviceInfo['app_version'],
      },
    );

    if (response.data['success'] == true) {
      final token = response.data['data']['token'];
      await _api.setToken(token);
    }

    return response.data;
  }

  // Register new user
  Future<User> register({
    required String phone,
    required String displayName,
    required DateTime birthdate,
    required String gender,
    required String sponsorPhone,
  }) async {
    final response = await _api.post(
      AppConfig.registerEndpoint,
      data: {
        'phone': phone,
        'display_name': displayName,
        'birthdate': birthdate.toIso8601String().split('T')[0],
        'gender': gender,
        'sponsor_phone': sponsorPhone,
      },
    );

    return User.fromJson(response.data['data']['user']);
  }

  // Get current user
  Future<User> getCurrentUser() async {
    final response = await _api.get(AppConfig.meEndpoint);
    return User.fromJson(response.data['data']);
  }

  // Logout
  Future<void> logout() async {
    await _api.post(AppConfig.logoutEndpoint);
    await _api.clearToken();
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _api.getToken();
    return token != null && token.isNotEmpty;
  }

  // Get device information
  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String platform = '';
    if (Platform.isAndroid) {
      platform = 'android';
    } else if (Platform.isIOS) {
      platform = 'ios';
    }

    return {
      'platform': platform,
      'app_version': packageInfo.version,
    };
  }
}
