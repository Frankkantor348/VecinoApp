import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
import 'utils/app_theme.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Verificar si hay sesión activa
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getString('token') != null;
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const VecinoApp(),
    ),
  );
}

class VecinoApp extends StatelessWidget {
  const VecinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'VecinoApp',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const LoginScreen(),
        );
      },
    );
  }
}