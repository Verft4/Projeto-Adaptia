import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginGoogleUseCase {
  final AuthRepository repository;

  const LoginGoogleUseCase({required this.repository});

  Future<UserEntity> call() async {
    return await repository.loginWithGoogle();
  }
}