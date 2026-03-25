import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'core/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: dotenv.env['AIzaSyBqAIVUkXXaMqL50v75TTvYAihrxWTRVsE'] ?? '',
      appId: dotenv.env['453007687926:android:b44fd8872469dc02b42cd7'] ?? '',
      messagingSenderId: dotenv.env['453007687926'] ?? '',
      projectId: dotenv.env['adaptia-3d7aa'] ?? '',
      storageBucket: dotenv.env['adaptia-3d7aa.firebasestorage.app'] ?? '',
  ),);
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
