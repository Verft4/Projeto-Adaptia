// Regra de cadastro

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;

  const RegisterUsecase({required this.repository});

  Future<UserEntity> call({required String email, required String password}) {
    return repository.register(email: email, password: password);
  }
}

/* 
O método call é especial no Dart — ele permite usar a classe como se fosse uma função:
registerUsecase(email: ..., password: ...). É uma convenção nos usecases.
*/