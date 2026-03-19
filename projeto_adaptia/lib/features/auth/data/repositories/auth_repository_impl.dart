// Implementação concreta

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource datasource;

  const AuthRepositoryImpl({required this.datasource});

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
  }) {
    return datasource.register(email: email, password: password);
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) {
    return datasource.login(email: email, password: password);
  }
}