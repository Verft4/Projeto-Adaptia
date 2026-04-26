// Interface (contrato)

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> getCurrentUser();

  Future<UserEntity> register({
    required String email,
    required String password,
    required String nome, // 👈
  });

  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> loginWithGoogle();
  Future<UserEntity> updateProfile({
    required String nome,
    required String headline,
    required String bio,
    required String avatar,
  });
  Future<void> logout();
  Future<void> deleteAccount();
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> resetPassword({required String newPassword});
}
