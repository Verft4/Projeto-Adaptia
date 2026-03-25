// lib/features/auth/domain/usecases/reset_password_usecase.dart

import 'package:projeto_adaptia/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository repository;

  const ResetPasswordUsecase({required this.repository});

  Future<void> call({required String newPassword}) {
    return repository.resetPassword(newPassword: newPassword);
  }
}