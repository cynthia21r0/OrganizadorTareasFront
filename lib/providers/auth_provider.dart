import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  UserModel? _currentUser;
  List<UserModel> _familyMembers = [];
  bool isLoading = false;
  String? errorMessage;
  String? lastInviteCode;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get familyMembers => _familyMembers;
  bool get isLoggedIn => _currentUser != null;

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

  /// Permite cambiar de cuenta localmente (flujo "Cambiar cuenta" del diseño)
  void switchAccount(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _repo.logout();
    notifyListeners();
  }
}
