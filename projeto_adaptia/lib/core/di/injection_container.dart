import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/data/datasources/firebase.dart';
import '../../features/auth/domain/usecases/login_google_usecase.dart';


final sl = GetIt.instance;

void setupDependencies() {
  // ─── Datasources ───────────────────────────────────────
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(),
  );
  sl.registerLazySingleton<AuthService>(() => AuthService());

  // ─── Repositories ──────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(datasource: sl(), authService: sl())
    ,
  );

  // ─── Usecases ──────────────────────────────────────────
  sl.registerLazySingleton(() => RegisterUsecase(repository: sl()));
  sl.registerLazySingleton(() => LoginUsecase(repository: sl()));
  sl.registerLazySingleton(() => LoginGoogleUseCase(repository: sl()));

  // ─── Cubits ────────────────────────────────────────────
  // factory: cria uma nova instância toda vez que for solicitado
  sl.registerFactory(
    () => AuthCubit(
      registerUsecase: sl(),
      loginUsecase: sl(),
      loginWithGoogleUsecase: sl(),
    ),
  );
}

/*
registerLazySingleton: cria a instância só quando for usada pela primeira vez,
e reutiliza depois. Ideal para repositórios e usecases.
registerFactory — cria uma instância nova toda vez.
Ideal para Cubits, pois cada tela deve ter seu próprio estado limpo.
 */