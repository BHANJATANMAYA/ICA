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
      if (data.session == null) {
        if (Get.currentRoute != AppRoutes.login && Get.currentRoute != AppRoutes.signup) {
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        if (Get.currentRoute == AppRoutes.login || Get.currentRoute == AppRoutes.signup) {
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

  Future<void> signup(String email, String password, String name, String? phone) async {
    try {
      isLoading.value = true;
      // SignUp
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      
      final user = response.user;
      if (user != null) {
        // Insert into public.parents
        await _client.from('parents').insert({
          'auth_user_id': user.id,
          'name': name,
          'email': email,
          'phone': phone,
        });
        Get.snackbar('Success', 'Signup successful! Please confirm your email.');
        Get.offAllNamed(AppRoutes.login);
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
