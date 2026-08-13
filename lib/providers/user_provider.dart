import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _userName = '';
  String _profileEmoji = '😀';
  bool _isFirstLaunch = true;
  bool _isLoading = true;

  String get userName => _userName;
  String get profileEmoji => _profileEmoji;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isLoading => _isLoading;

  UserProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? '';
    _profileEmoji = prefs.getString('profileEmoji') ?? '😀';
    _isFirstLaunch = _userName.isEmpty;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    _isFirstLaunch = false;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
  }

  Future<void> setProfileEmoji(String emoji) async {
    _profileEmoji = emoji;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileEmoji', emoji);
  }
}
