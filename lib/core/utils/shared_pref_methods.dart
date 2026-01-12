import 'package:shared_preferences/shared_preferences.dart';
import 'logs.dart';

class CacheUtils {
  static const _onboardingCacheKey = 'hasSeenOnboarding';

  static Future<bool> checkOnBoardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCacheKey) ?? false;
    } catch (e) {
      DevLogs.logError('Error checking onboarding status: $e');
      return false;
    }
  }

  static Future<bool> updateOnboardingStatus(bool status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCacheKey, status);
      return prefs.getBool(_onboardingCacheKey) ?? false;
    } catch (e) {
      DevLogs.logError('Error updating onboarding status: $e');
      return false;
    }
  }

  static Future<String?> checkToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? '';
      DevLogs.logSuccess('token available == $token');
      return token;
    } catch (e) {
      DevLogs.logError('Error checking token: $e');
      return null;
    }
  }

  static Future<void> storeToken({required String token}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      DevLogs.logSuccess('Saved $token to cache');
      await prefs.setString("token", token);
    } catch (e) {
      DevLogs.logError('Error saving token to cache: $e');
    }
  }

  static Future<void> clearCachedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
    } catch (e) {
      DevLogs.logError('Error clearing token cache: $e');
    }
  }
}
