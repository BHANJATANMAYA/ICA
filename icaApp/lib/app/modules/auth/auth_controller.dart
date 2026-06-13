import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;

  RxBool isLoading = false.obs;
  Rxn<User> currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _client.auth.currentUser;
    // Listen to auth state changes
    _client.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      final current = Get.currentRoute;
      if (data.session == null) {
        // Only redirect to login if we are not already on login/signup and not in startup sequence
        if (current.isNotEmpty && current != '/' && current != AppRoutes.login) {
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        // Redirect to dashboard if we are on login/signup or startup
        if (current == AppRoutes.login || current == '/' || current == '') {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      }
    });
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
