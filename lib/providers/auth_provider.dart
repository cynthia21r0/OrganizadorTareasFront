import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  final _secureStorage = SecureStorageService.instance;

  UserModel? _currentUser;
  List<UserModel> _familyMembers = [];
  bool isLoading = false;
  bool isCheckingSession = true;
  String? errorMessage;
  String? lastInviteCode;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get familyMembers => _familyMembers;
  bool get isLoggedIn => _currentUser != null;

  Future<void> tryAutoLogin() async {
    isCheckingSession = true;
    notifyListeners();

    try {
      final savedToken = await _secureStorage.readToken();
      if (savedToken == null) {
        isCheckingSession = false;
        notifyListeners();
        return;
      }

      ApiClient.instance.token = savedToken;
      final user = await _repo.fetchCurrentUser();
      _currentUser = user;
      await refreshFamilyMembers();
    } catch (_) {
      ApiClient.instance.token = null;
      await _secureStorage.deleteToken();
      _currentUser = null;
    } finally {
      isCheckingSession = false;
      notifyListeners();
    }
  }

   Future<bool> register({
    required String name,
    required String email,
    required String password,
    required FamilyRole role,
    String? familyName,
    String? inviteCode,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _repo.register(
        name: name,
        email: email,
        password: password,
        role: role,
        familyName: familyName,
        inviteCode: inviteCode,
      );
      lastInviteCode = result.inviteCode;
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

    Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final user = await _repo.login(email: email, password: password);
      _currentUser = user;

      final token = ApiClient.instance.token;
      if (token != null) {
        await _secureStorage.saveToken(token);
      }

      await refreshFamilyMembers();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshFamilyMembers() async {
    _familyMembers = await _repo.getAllUsers();
    notifyListeners();
  }

  Future<void> updateProfilePicture(String base64Image) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = await _repo.updateProfilePicture(base64Image);

      _currentUser = updatedUser;

      final index = _familyMembers.indexWhere((m) => m.id == updatedUser.id);
      if (index != -1) {
        _familyMembers[index] = updatedUser;
      }

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  void switchAccount(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _repo.logout();
    await _secureStorage.deleteToken();
    notifyListeners();
  }
}
