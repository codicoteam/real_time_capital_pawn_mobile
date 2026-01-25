import 'package:shared_preferences/shared_preferences.dart';
import 'logs.dart';

class CacheUtils {
  static const _onboardingCacheKey = 'hasSeenOnboarding';
  static const _tokenKey = 'token';
  static const _userIdKey = 'userId'; // Add this constant

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
      final token = prefs.getString(_tokenKey) ?? '';
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
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      DevLogs.logError('Error saving token to cache: $e');
    }
  }

  static Future<void> clearCachedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      DevLogs.logError('Error clearing token cache: $e');
    }
  }

  // Add this method to get user ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      DevLogs.logInfo('User ID from cache: $userId');
      return userId;
    } catch (e) {
      DevLogs.logError('Error getting user ID: $e');
      return null;
    }
  }

  // Add this method to store user ID
  static Future<void> storeUserId({required String userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      DevLogs.logSuccess('Saved user ID $userId to cache');
      await prefs.setString(_userIdKey, userId);
    } catch (e) {
      DevLogs.logError('Error saving user ID to cache: $e');
    }
  }

  // Add this method to clear user ID
  static Future<void> clearCachedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
    } catch (e) {
      DevLogs.logError('Error clearing user ID cache: $e');
    }
  }

  // Optional: Add a method to clear all user data (useful for logout)
  static Future<void> clearAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      DevLogs.logSuccess('Cleared all user data from cache');
    } catch (e) {
      DevLogs.logError('Error clearing all user data: $e');
    }
  }
}
