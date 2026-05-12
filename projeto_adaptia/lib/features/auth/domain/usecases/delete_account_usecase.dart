import '../repositories/auth_repository.dart';

class DeleteAccountUsecase {
  final AuthRepository repository;

  const DeleteAccountUsecase({required this.repository});

  Future<void> call() {
    return repository.deleteAccount();
  }
}
