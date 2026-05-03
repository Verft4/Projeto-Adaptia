import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LinkGoogleAccountUsecase {
  final AuthRepository repository;

  const LinkGoogleAccountUsecase({required this.repository});

  Future<UserEntity> call() {
    return repository.linkGoogleAccount();
  }
}
