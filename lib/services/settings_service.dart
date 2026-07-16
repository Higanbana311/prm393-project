import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// Lưu các tuỳ chọn cục bộ của người dùng (chế độ tối, thông báo, lịch sử tìm kiếm).
class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _keyDarkMode = 'settings_dark_mode';
  static const _keyNotifications = 'settings_notifications';
  static const _keyRecentSearches = 'settings_recent_searches';
  static const _maxRecent = 8;

  /// Chế độ tối là tuỳ chọn riêng của từng tài khoản nên khoá lưu phải kèm user id.
  /// Khách chưa đăng nhập dùng chung khoá 'guest'.
  Future<String> _darkModeKey() async {
    final userId = await AuthService.instance.getUserId();
    return '${_keyDarkMode}_${userId ?? 'guest'}';
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(await _darkModeKey()) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(await _darkModeKey(), value);
  }

  Future<bool> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifications) ?? true;
  }

  Future<void> setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
  }

  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyRecentSearches) ?? [];
  }

  /// Thêm một từ khoá vào đầu lịch sử (bỏ trùng, giới hạn số lượng).
  Future<List<String>> addRecentSearch(String term) async {
    final t = term.trim();
    if (t.isEmpty) return getRecentSearches();
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRecentSearches) ?? [];
    list.removeWhere((e) => e.toLowerCase() == t.toLowerCase());
    list.insert(0, t);
    if (list.length > _maxRecent) list.removeRange(_maxRecent, list.length);
    await prefs.setStringList(_keyRecentSearches, list);
    return list;
  }

  Future<List<String>> removeRecentSearch(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRecentSearches) ?? [];
    list.removeWhere((e) => e.toLowerCase() == term.toLowerCase());
    await prefs.setStringList(_keyRecentSearches, list);
    return list;
  }
}
