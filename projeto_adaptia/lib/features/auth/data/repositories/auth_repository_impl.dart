import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/firebase.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;
  final AuthService authService;

  const AuthRepositoryImpl({
    required this.datasource,
    required this.authService,
  });

  @override
  Future<UserEntity> getCurrentUser() async {
    return await datasource.getUsuarioAtual();
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final error = await authService.login(email: email, password: password);
    if (error != null) throw Exception(error);
    return await datasource.getUsuarioAtual();
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String nome,
  }) async {
    final error = await authService.registrar(
      email: email,
      password: password,
      nome: nome,
    );
    if (error != null) throw Exception(error);
    return await datasource.getUsuarioAtual();
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    final error = await authService.loginComGoogle();
    if (error != null) throw Exception(error);
    return await datasource.getUsuarioAtual();
  }

  @override
  Future<UserEntity> updateProfile({
    required String nome,
    required String headline,
    required String bio,
    required String avatar,
  }) async {
    return await datasource.atualizarPerfil(
      nome: nome,
      headline: headline,
      bio: bio,
      avatar: avatar,
    );
  }

  @override
  Future<void> deleteAccount() async {
    await datasource.deletarConta();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      authService.sendPasswordResetEmail(email: email);

  @override
  Future<void> resetPassword({required String newPassword}) =>
      authService.resetPassword(newPassword: newPassword);
}
