// Interface (contrato)

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String email,
    required String password,
  });

  Future<UserEntity> login({required String email, required String password});

  // ─── Recuperação de senha ──────────────────────────
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> resetPassword({required String newPassword});
}
