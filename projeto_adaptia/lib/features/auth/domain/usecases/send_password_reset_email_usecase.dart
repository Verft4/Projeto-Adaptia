// lib/features/auth/domain/usecases/send_password_reset_email_usecase.dart

import 'package:projeto_adaptia/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordResetEmailUsecase {
  final AuthRepository repository;

  const SendPasswordResetEmailUsecase({required this.repository});

  Future<void> call({required String email}) {
    return repository.sendPasswordResetEmail(email: email);
  }
}