import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/berita_provider.dart';
import 'providers/agenda_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';

void main() => runApp(const P3MApp());

class P3MApp extends StatelessWidget {
  const P3MApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
        home: Consumer<AuthProvider>(
          builder: (_, auth, __) {
            if (auth.status == AuthStatus.unknown) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (auth.status == AuthStatus.authenticated) return const MainShell();
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}