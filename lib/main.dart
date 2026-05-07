import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  final storage = LocalStorageService();
  await storage.init();

  // Start Sync Service
  SyncService().startSyncTimer();
  
  runApp(
    const ProviderScope(
      child: MealPApp(),
    ),
  );
}

class MealPApp extends StatelessWidget {
  const MealPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const MainNavigationScreen(),
      },
    );
  }
}
