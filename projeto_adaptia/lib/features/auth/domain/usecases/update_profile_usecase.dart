import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUsecase {
  final AuthRepository repository;

  const UpdateProfileUsecase({required this.repository});

  Future<UserEntity> call({
    required String nome,
    required String headline,
    required String bio,
    required String avatar,
  }) {
    return repository.updateProfile(
      nome: nome,
      headline: headline,
      bio: bio,
      avatar: avatar,
    );
  }
}
