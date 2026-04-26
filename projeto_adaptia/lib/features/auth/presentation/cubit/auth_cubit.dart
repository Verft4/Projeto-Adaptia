// Lógica de estados

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_adaptia/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:projeto_adaptia/features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import 'package:projeto_adaptia/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:projeto_adaptia/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:projeto_adaptia/features/auth/domain/usecases/link_google_account_usecase.dart';
import 'package:projeto_adaptia/features/auth/domain/usecases/logout_usecase.dart';
import 'package:projeto_adaptia/features/auth/domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_google_usecase.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterUsecase registerUsecase;
  final LoginUsecase loginUsecase;
  final LoginGoogleUseCase loginWithGoogleUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final SendPasswordResetEmailUsecase sendPasswordResetEmailUsecase;
  final ResetPasswordUsecase resetPasswordUsecase;
  final UpdateProfileUsecase updateProfileUsecase;
  final DeleteAccountUsecase deleteAccountUsecase;
  final LinkGoogleAccountUsecase linkGoogleAccountUsecase;
  final LogoutUsecase logoutUsecase;

  AuthCubit({
    required this.registerUsecase,
    required this.loginUsecase,
    required this.loginWithGoogleUsecase,
    required this.getCurrentUserUsecase,
    required this.sendPasswordResetEmailUsecase,
    required this.resetPasswordUsecase,
    required this.updateProfileUsecase,
    required this.deleteAccountUsecase,
    required this.linkGoogleAccountUsecase,
    required this.logoutUsecase,
  }) : super(AuthInitial());

  Future<void> loadCurrentUser() async {
    emit(AuthLoading());
    try {
      final user = await getCurrentUserUsecase();
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String nome, // 👈
  }) async {
    emit(AuthLoading());
    try {
      final user = await registerUsecase(
        email: email,
        password: password,
        nome: nome, // 👈
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await loginUsecase(email: email, password: password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final user =
          await loginWithGoogleUsecase(); // O email não é necessário para login com Google
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    emit(AuthLoading());
    try {
      await sendPasswordResetEmailUsecase(email: email);
      emit(PasswordResetEmailSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword({required String newPassword}) async {
    emit(AuthLoading());
    try {
      await resetPasswordUsecase(newPassword: newPassword);
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String nome,
    required String headline,
    required String bio,
    required String avatar,
  }) async {
    emit(AuthLoading());
    try {
      final user = await updateProfileUsecase(
        nome: nome,
        headline: headline,
        bio: bio,
        avatar: avatar,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    emit(AuthLoading());
    try {
      await deleteAccountUsecase();
      emit(AccountDeletedSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await logoutUsecase();
      emit(LoggedOutSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> linkGoogleAccount() async {
    emit(AuthLoading());
    try {
      final user = await linkGoogleAccountUsecase();
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
