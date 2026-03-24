// Lógica de estados

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_adaptia/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:projeto_adaptia/features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import 'package:projeto_adaptia/features/auth/presentation/pages/reset_password_page.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterUsecase registerUsecase;
  final LoginUsecase loginUsecase;
  final SendPasswordResetEmailUsecase sendPasswordResetEmailUsecase;
  final ResetPasswordUsecase resetPasswordUsecase;

  AuthCubit({required this.registerUsecase, required this.loginUsecase, required this.sendPasswordResetEmailUsecase,
  required this.resetPasswordUsecase,})
    : super(AuthInitial());

  Future<void> register({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await registerUsecase(email: email, password: password);
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
}
