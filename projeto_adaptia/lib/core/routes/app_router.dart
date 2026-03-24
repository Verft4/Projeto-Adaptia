// configuração do GoRouter

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';

// TODO: substituir pelo dashboard real quando for criado
import 'package:flutter/material.dart' show Scaffold, Center, Text;

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.register,
      builder:
          (context, state) => BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const RegisterPage(),
          ),
    ),
     GoRoute(
      path: AppRoutes.forgotPassword,
      builder:
          (context, state) => BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const ForgotPasswordPage(),
          ),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder:
          (context, state) => BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const ResetPasswordPage(),
          ),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder:
          (context, state) => BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const LoginPage(),
          ),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder:
          (context, state) =>
              const Scaffold(body: Center(child: Text('Dashboard 🚀'))),
    ),
  ],
);
