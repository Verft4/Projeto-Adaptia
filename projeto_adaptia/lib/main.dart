import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'core/routes/app_router.dart';

void main() {
  setupDependencies(); // registra tudo antes do app abrir
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Projeto Adaptia',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
