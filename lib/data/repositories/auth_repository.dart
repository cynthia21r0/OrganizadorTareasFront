import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class RegisterResult {
  final UserModel user;
  final String familyName;
  final String inviteCode;
  RegisterResult({
    required this.user,
    required this.familyName,
    required this.inviteCode,
  });
}

class AuthRepository {
  final _dio = ApiClient.instance.dio;

  Future<RegisterResult> register({
    required String name,
    required String email,
    required String password,
    required FamilyRole role,
    String? familyName,
    String? inviteCode,
  }) async {
    final res = await _dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role.name,
        if (familyName != null) 'familyName': familyName,
        if (inviteCode != null) 'inviteCode': inviteCode,
      },
    );
    return RegisterResult(
      user: UserModel.fromJson(res.data['user']),
      familyName: res.data['family']['name'] as String,
      inviteCode: res.data['family']['inviteCode'] as String,
    );
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    ApiClient.instance.token = res.data['accessToken'] as String;
    return UserModel.fromJson(res.data['user']);
  }

  Future<List<UserModel>> getAllUsers() async {
    final res = await _dio.get('/users');
    return (res.data as List).map((m) => UserModel.fromJson(m)).toList();
  }

  Future<UserModel> updateProfilePicture(String base64Image) async {
    final res = await _dio.patch(
      '/users/me/profile-picture',
      data: {'profilePicture': base64Image},
    );
    return UserModel.fromJson(res.data);
  }

  Future<UserModel> fetchCurrentUser() async {
    final res = await _dio.get('/users/me');
    return UserModel.fromJson(res.data);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? password,
    String? currentPassword,
  }) async {
    final res = await _dio.patch(
      '/users/me',
      data: {
        if (name != null && name.isNotEmpty) 'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
        if (currentPassword != null && currentPassword.isNotEmpty)
          'currentPassword': currentPassword,
      },
    );
    return UserModel.fromJson(res.data);
  }

  void logout() => ApiClient.instance.token = null;
}
