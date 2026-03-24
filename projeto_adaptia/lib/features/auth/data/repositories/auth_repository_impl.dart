// Implementação concreta

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/firebase.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource datasource; 
  final AuthService authService;         

  const AuthRepositoryImpl({
    required this.datasource,
    required this.authService,
  });

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final error = await authService.login(email: email, password: password);
    
    if (error != null) {
      
      throw Exception(error);
    }

    
    return await datasource.login(email: email, password: password);
  }
  

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
  }) async {
    
    final error = await authService.registrar(email: email, password: password);
    
    if (error != null) {
      throw Exception(error);
    }

    
    return await datasource.register(email: email, password: password);
  }
  @override
  Future<UserEntity> loginWithGoogle() async {
    // 1. Chama o Firebase Auth
    final error = await authService.loginComGoogle();
    
    if (error != null) {
      throw Exception(error);
    }

    // 2. Pega os dados do usuário logado no Firebase
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null || firebaseUser.email == null) {
      throw Exception('Erro ao recuperar os dados do Google.');
    }

    // 3. Sincroniza/Loga no banco local
    return await datasource.loginWithGoogle(email: firebaseUser.email!);
  }
  @override
    Future<void> sendPasswordResetEmail({required String email}) {
      return datasource.sendPasswordResetEmail(email: email);
    }

    @override
    Future<void> resetPassword({required String newPassword}) {
      return datasource.resetPassword(newPassword: newPassword);
    }
  
}

 