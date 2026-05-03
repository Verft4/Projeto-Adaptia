// configuração do GoRouter

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/layouts/auth_layout.dart';
import '../../features/auth/presentation/layouts/dashboard_layout.dart';
import '../../features/auth/presentation/layouts/onboarding_layout.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/onboarding/onboarding.dart';
import '../../features/auth/presentation/pages/auth/register_page.dart';
import '../../features/auth/presentation/pages/auth/login_page.dart';
import '../../features/auth/presentation/pages/auth/forgot_password_page.dart';
import '../../features/auth/presentation/pages/auth/reset_password_page.dart';
import '../../features/auth/presentation/pages/dashboard/home_page.dart';
import '../../features/auth/presentation/pages/dashboard/classes_page.dart';
import '../../features/auth/presentation/pages/dashboard/ai_page.dart';
import '../../features/auth/presentation/pages/dashboard/groups_page.dart';
import '../../features/auth/presentation/pages/dashboard/profile_page.dart';
import 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Splash Screen
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),

    // Onboarding Flow
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingLayout(
        child: OnboardingPage(),
      ),
    ),

    // Auth Flow
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => AuthLayout(
        child: BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const LoginPage(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => AuthLayout(
        child: BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const RegisterPage(),
        ),
      )
    ),
     GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => AuthLayout(
        child: BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const ForgotPasswordPage(),
        ),
      )
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) => AuthLayout(
        child: BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const ResetPasswordPage(),
        ),
      )
    ),

    // Dashboard Flow
    ShellRoute(
      builder: (context, state, child) => BlocProvider(
        create: (_) => sl<AuthCubit>()..loadCurrentUser(),
        child: DashboardLayout(
          location: state.fullPath ?? '',
          child: child,
        ),
      ),
      routes: [
        GoRoute(
          path: AppRoutes.root,
          redirect: (context, state) => AppRoutes.dashboardHome,
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          redirect: (context, state) => AppRoutes.dashboardHome,
        ),
        GoRoute(
          path: AppRoutes.dashboardHome,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.dashboardClasses,
          builder: (context, state) => const ClassesPage(),
        ),
        GoRoute(
          path: AppRoutes.dashboardAI,
          builder: (context, state) => const AIPage(),
        ),
        GoRoute(
          path: AppRoutes.dashboardGroups,
          builder: (context, state) => const GroupsPage(),
        ),
        GoRoute(
          path: AppRoutes.dashboardProfile,
          builder: (context, state) => const ProfilePage(),
        )
      ],
    )
  ],
);
