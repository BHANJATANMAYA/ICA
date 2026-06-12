import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/core/supabase/supabase_client.dart';
import 'app/core/theme/colors.dart';
import 'app/modules/error/error_boundary.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase client
  await AppSupabase.init();
  
  // Set custom global error widget boundary
  ErrorWidget.builder = (details) {
    return ErrorBoundary(errorDetails: details);
  };
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Indian Chess Academy',
      debugShowCheckedModeBanner: false,
      
      // Theme matching Brand Book specs
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.offWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.deepNavy,
          primary: AppColors.deepNavy,
          secondary: AppColors.chessGold,
          surface: AppColors.white,
          error: AppColors.alertRed,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.deepNavy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.chessGold,
          unselectedItemColor: Colors.grey,
        ),
      ),
      
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
