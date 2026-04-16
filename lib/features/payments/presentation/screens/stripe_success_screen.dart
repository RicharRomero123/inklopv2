import 'package:flutter/material.dart';
import 'package:inklop_v1/core/services/secure_storage_service.dart';
import 'package:inklop_v1/features/auth/presentation/screens/welcome_screen.dart';
import 'package:inklop_v1/features/main/presentation/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> _checkLoginStatus() async {
    final storage = SecureStorageService();
    return await storage.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inklop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),

        // 🚀 AHORA USAMOS LA FUENTE LOCAL
        // Esto aplica Geist a toda la app sin errores de red
        fontFamily: 'Geist',

        // Ajustamos el TextTheme para que herede la fuente local
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Geist', fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontFamily: 'Geist'),
          bodyMedium: TextStyle(fontFamily: 'Geist'),
        ),
      ),
      home: FutureBuilder<String?>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator(color: Colors.black)),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return MainScreen(accessToken: snapshot.data!);
          } else {
            return const WelcomeScreen();
          }
        },
      ),
    );
  }
}