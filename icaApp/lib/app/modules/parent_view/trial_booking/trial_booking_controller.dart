import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/colors.dart';
import '../../../data/models/batch.dart';

class TrialBookingController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;

  RxBool isLoading = false.obs;
  RxList<Batch> batches = <Batch>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBatches();
  }

  Future<void> fetchBatches() async {
    try {
      isLoading.value = true;
      final response = await _client.from('batches').select('*');
      final List<Batch> loaded = (response as List)
          .map((data) => Batch.fromJson(data as Map<String, dynamic>))
          .toList();
      batches.assignAll(loaded);
    } catch (e) {
      Get.snackbar('Error Loading Batches', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bookTrial({
    required String name,
    required String? phone,
    required String? email,
    String? preferredBatchId,
  }) async {
    try {
      isLoading.value = true;
      
      await _client.from('trial_requests').insert({
        'name': name,
        'contact_phone': phone,
        'contact_email': email,
        'preferred_batch_id': preferredBatchId,
        'status': 'new',
      });
      
      Get.defaultDialog(
        title: 'Booking Confirmed!',
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.successGreen),
        middleText: 'Your trial class request for $name has been recorded. Our coaching staff will contact you shortly.',
        textConfirm: 'Great',
        confirmTextColor: Colors.white,
        buttonColor: AppColors.chessGold,
        onConfirm: () {
          Get.back(); // close dialog
          Get.back(); // go back to dashboard
        },
      );
    } catch (e) {
      Get.snackbar('Error Booking Trial', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
