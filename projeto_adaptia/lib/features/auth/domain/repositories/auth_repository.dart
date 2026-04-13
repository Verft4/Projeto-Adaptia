// Interface (contrato)

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String email,
    required String password,
    required String nome, // 👈
  });

  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> loginWithGoogle();
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> resetPassword({required String newPassword});
}
