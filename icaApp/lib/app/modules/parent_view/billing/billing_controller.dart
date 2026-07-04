import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../data/models/plan.dart';
import '../../../data/models/subscription.dart';
import '../../dashboard/dashboard_controller.dart';

class BillingController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;
  final DashboardController _dashboardController =
      Get.find<DashboardController>();

  RxBool isLoading = true.obs;
  RxList<Plan> plans = <Plan>[].obs;
  // Map of studentId -> list of subscriptions
  RxMap<String, List<Subscription>> studentSubscriptions =
      <String, List<Subscription>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBillingData();
  }

  Future<void> fetchBillingData() async {
    try {
      isLoading.value = true;

      // 1. Try drift cache first for plans
      final db = Get.find<AppDatabase>();
      final cachedPlans = await db.getAllPlans();

      if (cachedPlans.isNotEmpty) {
        // Load from cache immediately for snappy UX
        plans.assignAll(cachedPlans.map((cp) => Plan(
              id: cp.id,
              name: cp.name,
              price: cp.price,
              durationType: cp.durationType,
              isActive: cp.isActive,
            )));
      }

      // 2. Fetch fresh plans from Supabase (always refresh)
      final plansRes =
          await _client.from('plans').select('*').eq('is_active', true);

      final List<Plan> loadedPlans = (plansRes as List)
          .map((data) => Plan.fromJson(data as Map<String, dynamic>))
          .toList();
      plans.assignAll(loadedPlans);

      // Cache plans in drift
      await db.upsertPlans(loadedPlans.map((p) {
        int months = 1;
        if (p.durationType == 'quarterly') months = 3;
        if (p.durationType == 'annual') months = 12;
        return CachedPlansCompanion.insert(
          id: p.id,
          name: p.name,
          price: p.price,
          durationMonths: drift.Value(months),
          durationType: drift.Value(p.durationType),
          isActive: drift.Value(p.isActive),
        );
      }).toList());

      // 3. Fetch subscriptions for linked students
      final studentIds =
          _dashboardController.students.map((s) => s.id).toList();
      if (studentIds.isNotEmpty) {
        final subsRes = await _client
            .from('subscriptions')
            .select('*')
            .inFilter('student_id', studentIds)
            .order('end_date', ascending: false);

        final List<Subscription> loadedSubs = (subsRes as List)
            .map((data) =>
                Subscription.fromJson(data as Map<String, dynamic>))
            .toList();

        // Group subscriptions by student
        final Map<String, List<Subscription>> grouped = {};
        for (var id in studentIds) {
          grouped[id] = [];
        }
        for (var sub in loadedSubs) {
          grouped[sub.studentId]?.add(sub);
        }
        studentSubscriptions.assignAll(grouped);
      } else {
        studentSubscriptions.clear();
      }
    } catch (e) {
      Get.snackbar('Error Loading Billing Info', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// MODULE 4: Authenticate with biometrics before proceeding with purchase.
  ///
  /// Returns true if the user is authenticated (or biometrics not available).
  Future<bool> authenticateBeforePurchase() async {
    final available = await BiometricService.isBiometricAvailable();
    if (!available) {
      // Degrade gracefully — allow purchase without biometric gate
      return true;
    }

    return BiometricService.authenticate(
      'Confirm your identity to complete payment',
    );
  }

  Future<void> purchasePlan({
    required String studentId,
    required Plan plan,
  }) async {
    try {
      isLoading.value = true;

      final startDate = DateTime.now();
      DateTime endDate;

      // Calculate end date based on duration type
      if (plan.durationType == 'quarterly') {
        endDate = startDate.add(const Duration(days: 90));
      } else if (plan.durationType == 'annual') {
        endDate = startDate.add(const Duration(days: 365));
      } else {
        endDate = startDate.add(const Duration(days: 30)); // default monthly
      }

      // 1. Insert subscription
      await _client.from('subscriptions').insert({
        'student_id': studentId,
        'plan_id': plan.id,
        'status': 'active',
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      });

      // 2. KNOWN GAP FIX: Write payment record to payments table
      final gatewayRef =
          'SIMULATED_${DateTime.now().millisecondsSinceEpoch}';
      await _client.from('payments').insert({
        'student_id': studentId,
        'plan_id': plan.id,
        'amount': plan.price,
        'status': 'success',
        'gateway_ref': gatewayRef,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 3. Insert billing notification for parent
      final parentId = _dashboardController.parentId.value;
      final studentName = _dashboardController.students
          .firstWhere((s) => s.id == studentId)
          .name;
      if (parentId.isNotEmpty) {
        await _client.from('notifications').insert({
          'target_parent_id': parentId,
          'type': 'billing',
          'title': 'Payment Confirmed',
          'message':
              'Successful purchase of "${plan.name}" for $studentName. Valid until ${endDate.toIso8601String().split('T')[0]}.',
        });
      }

      Get.snackbar('Payment Confirmed',
          'Subscription successfully activated! Gateway ref: $gatewayRef');
      await fetchBillingData(); // Refresh list
      _dashboardController.fetchNotificationCount(parentId);
    } catch (e) {
      Get.snackbar('Error Saving Subscription', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
