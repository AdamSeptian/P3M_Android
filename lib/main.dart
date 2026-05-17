// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'utils/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/berita_provider.dart';
import 'providers/agenda_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const P3MApp());
}

class P3MApp extends StatelessWidget {
  const P3MApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider akan langsung mengecek token di local storage saat inisialisasi
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => BeritaProvider()),
        ChangeNotifierProvider(create: (_) => AgendaProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => KategoriProvider()),
        ChangeNotifierProvider(create: (_) => TagProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // Kita tidak perlu mendefinisikan rute statis '/login' di sini jika sudah 
        // menggunakan manajemen state dinamis pada properti 'home'
        home: Consumer<AuthProvider>(
          builder: (_, auth, __) {
            // Tampilkan loading saat aplikasi baru dibuka & sedang mengecek token
            if (auth.status == AuthStatus.unknown) {
              return const Scaffold(
                backgroundColor: AppColors.primary,
                body: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }
            
            // Jika token ada & valid, arahkan ke MainShell (Dashboard)
            if (auth.status == AuthStatus.authenticated) {
              return const MainShell();
            }
            
            // Jika tidak ada token / sesi habis, arahkan ke Login
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}