// Salva usuário localmente

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDatasource {
  Future<UserModel> register({required String email, required String password});
  Future<UserModel> login({required String email, required String password});
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const _usersKey = 'registered_users';
  static const _loggedUserKey = 'logged_user';

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Busca usuários já cadastrados
    final usersJson = prefs.getString(_usersKey);
    final List<Map<String, dynamic>> users = usersJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(usersJson))
        : [];

    // Verifica se email já existe
    final alreadyExists = users.any((u) => u['email'] == email);
    if (alreadyExists) {
      throw Exception('E-mail já cadastrado.');
    }

    // Cria novo usuário
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
    );

    // Salva a senha junto (apenas local, em produção NUNCA faça isso sem criptografia)
    users.add({...newUser.toJson(), 'password': password});
    await prefs.setString(_usersKey, jsonEncode(users));

    return newUser;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) throw Exception('Nenhum usuário cadastrado.');

    final List<Map<String, dynamic>> users =
        List<Map<String, dynamic>>.from(jsonDecode(usersJson));

    final userMap = users.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => throw Exception('E-mail ou senha inválidos.'),
    );

    return UserModel.fromJson(userMap);
  }
}