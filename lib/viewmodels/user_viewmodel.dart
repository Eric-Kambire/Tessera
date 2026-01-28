import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService _apiService;

  UserViewModel(this._apiService);

  bool _isLoading = false;
  List<User> _userList = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<User> get userList => _userList;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userList = await _apiService.fetchUsers();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
