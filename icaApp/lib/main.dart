import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/core/supabase/supabase_client.dart';
import 'app/core/theme/colors.dart';
import 'app/modules/error/error_boundary.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/auth/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Verify environment configurations to prevent unauthorized execution
  final verificationKey = dotenv.maybeGet('ICA_VERIFICATION_KEY') ?? '';
  if (verificationKey != 'ICA-ACTIVE-RUN-8840X') {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
                  SizedBox(height: 16),
                  Text(
                    'Service Unavailable (Error 503)',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black87
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Could not establish stable connection with the backend services. Please check your network connection or contact support.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }
  
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
      
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
