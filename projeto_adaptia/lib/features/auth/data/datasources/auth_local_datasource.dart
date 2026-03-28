// Salva usuário localmente

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDatasource {
  Future<UserModel> register({required String email, required String password});
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> loginWithGoogle({required String email});
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> resetPassword({required String newPassword});
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const _usersKey = 'registered_users';

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
  @override
Future<UserModel> loginWithGoogle({required String email}) async {
  final prefs = await SharedPreferences.getInstance();
  final usersJson = prefs.getString(_usersKey);
  
  final List<Map<String, dynamic>> users = usersJson != null
      ? List<Map<String, dynamic>>.from(jsonDecode(usersJson))
      : [];

  // Procura o usuário. Retorna null se não encontrar, em vez de dar erro.
  final existingUserMap = users.where((u) => u['email'] == email).firstOrNull;

  if (existingUserMap != null) {
    // Usuário encontrado! Retorna os dados dele.
    return UserModel.fromJson(existingUserMap);
  } else {
    // Usuário NÃO encontrado. Cadastra no banco local automaticamente.
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
    );
    
    // Salva com uma "senha" dummy para não quebrar a tipagem local
    users.add({...newUser.toJson(), 'password': 'google_oauth_user'});
    await prefs.setString(_usersKey, jsonEncode(users));
    
    return newUser;
    
    
  }
}
@override
  Future<void> sendPasswordResetEmail({required String email}) async {
    // TODO: substituir pela chamada real do Firebase
    // Firebase: await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    
    // Mock: simula um delay de rede e confirma
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> resetPassword({required String newPassword}) async {    
    // TODO: substituir pela chamada real do Firebase
    // Firebase: await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
    
    // Mock: simula um delay de rede e confirma
    await Future.delayed(const Duration(seconds: 1));
  }

}

