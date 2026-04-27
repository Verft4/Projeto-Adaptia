import '../repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository repository;

  const LogoutUsecase({required this.repository});

  Future<void> call() {
    return repository.logout();
  }
}
