import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../routes/app_routes.dart';
import 'dashboard_controller.dart';

// Import our feature screens directly to embed or navigate to them
import '../parent_view/profiles/profiles_screen.dart';
import '../parent_view/attendance/attendance_screen.dart';
import '../parent_view/billing/billing_screen.dart';
import '../parent_view/trial_booking/trial_booking_screen.dart';
import '../student_view/schedule/schedule_screen.dart';
import '../student_view/study_materials/study_materials_screen.dart';
import '../student_view/assignments/assignments_screen.dart';
import '../student_view/group_chat/group_chat_screen.dart';
import '../student_view/polls/polls_screen.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          backgroundColor: AppColors.offWhite,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.chessGold),
            ),
          ),
        );
      }

      final isParent = controller.isParentView.value;

      return Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: AppColors.deepNavy,
          elevation: 0,
          title: Row(
            children: [
              // Logo/Chess Icon
              Image.asset(
                'assets/images/logo.png',
                height: 28,
                width: 28,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.emoji_events, color: AppColors.chessGold, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isParent
                      ? 'Parent: ${controller.parentName.value}'
                      : 'Student: ${controller.selectedStudent.value?.name ?? "No Student"}',
                  style: AppTypography.screenTitle.copyWith(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            // Student Context Picker (Only visible in Student View if multiple students exist)
            if (!isParent && controller.students.length > 1)
              IconButton(
                icon: const Icon(
                  Icons.people_alt_outlined,
                  color: AppColors.chessGold,
                ),
                tooltip: 'Switch Student Profile',
                onPressed: () => _showStudentPicker(context),
              ),

            // Notification Bell with live count
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.white,
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.notifications),
                ),
                if (controller.notificationCount.value > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.alertRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${controller.notificationCount.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),

            // Logout Button
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.white),
              onPressed: () => controller.logout(),
            ),
          ],
        ),
        body: Column(
          children: [
            // AppBar Context Switcher Custom Panel
            _buildAppBarContextSwitcher(),

            // Main Dashboard Body
            Expanded(
              child: isParent
                  ? _buildParentDashboard(context)
                  : _buildStudentDashboard(context),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentTabIndex.value,
          onTap: (index) {
            controller.switchView(index == 0);
          },
          selectedItemColor: AppColors.chessGold,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
          backgroundColor: AppColors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.supervisor_account),
              label: 'Parent View',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Student View',
            ),
          ],
        ),
      );
    });
  }

  // Beautiful toggle bar below app bar
  Widget _buildAppBarContextSwitcher() {
    final isParent = controller.isParentView.value;
    return Container(
      color: AppColors.deepNavy,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _SwitcherButton(
              title: 'Parent Panel',
              isActive: isParent,
              onTap: () => controller.switchView(true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SwitcherButton(
              title: 'Student Panel',
              isActive: !isParent,
              onTap: () => controller.switchView(false),
            ),
          ),
        ],
      ),
    );
  }

  // Parent Dashboard
  Widget _buildParentDashboard(BuildContext context) {
    if (controller.parentId.isEmpty) {
      return const Center(child: Text('Loading parent profile...'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Overview
          const Text('Academy Dashboard', style: AppTypography.sectionHeader),
          const SizedBox(height: 12),

          // Action grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _DashboardCard(
                title: 'Linked Students',
                subtitle: '${controller.students.length} Profiles',
                icon: Icons.people_alt,
                onTap: () => Get.to(() => const ProfilesScreen()),
              ),
              _DashboardCard(
                title: 'Attendance',
                subtitle: 'Ledger Rollups',
                icon: Icons.calendar_month,
                onTap: () => Get.to(() => const AttendanceScreen()),
              ),
              _DashboardCard(
                title: 'Subscriptions',
                subtitle: 'Plans & Billing',
                icon: Icons.credit_card,
                onTap: () => Get.to(() => const BillingScreen()),
              ),
              _DashboardCard(
                title: 'Book Trial Class',
                subtitle: 'Request Class',
                icon: Icons.play_lesson,
                onTap: () => Get.to(() => const TrialBookingScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Student Dashboard
  Widget _buildStudentDashboard(BuildContext context) {
    if (controller.students.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school_outlined,
                size: 64,
                color: AppColors.chessGold,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Student Profiles Found',
                style: AppTypography.sectionHeader,
              ),
              const SizedBox(height: 12),
              Text(
                'Please add a student profile from the Parent View first to access student features.',
                style: AppTypography.body.copyWith(color: AppColors.darkGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => controller.switchView(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.chessGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Go to Parent View'),
              ),
            ],
          ),
        ),
      );
    }

    final activeStudent = controller.selectedStudent.value;
    if (activeStudent == null) {
      return const Center(child: Text('Please select a student.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student details header card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.deepNavy,
                    radius: 28,
                    child: Text(
                      activeStudent.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeStudent.name,
                          style: AppTypography.sectionHeader,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.chessGold,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                activeStudent.level,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Rating: ${activeStudent.chessRating}',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (activeStudent.platformId != null &&
                            activeStudent.platformId!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Username: ${activeStudent.platformId}',
                            style: AppTypography.caption,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Student Portal', style: AppTypography.sectionHeader),
          const SizedBox(height: 12),

          // Student tools grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _DashboardCard(
                title: 'Class Schedule',
                subtitle: 'Schedules & Live Sync',
                icon: Icons.calendar_today,
                onTap: () => Get.to(() => const ScheduleScreen()),
              ),
              _DashboardCard(
                title: 'Study Materials',
                subtitle: 'PDFs & Game Links',
                icon: Icons.menu_book,
                onTap: () => Get.to(() => const StudyMaterialsScreen()),
              ),
              _DashboardCard(
                title: 'Assignments',
                subtitle: 'Homework Upload',
                icon: Icons.assignment,
                onTap: () => Get.to(() => const AssignmentsScreen()),
              ),
              _DashboardCard(
                title: 'Group Chat',
                subtitle: 'Batch Chat Rooms',
                icon: Icons.chat,
                onTap: () => Get.to(() => const GroupChatScreen()),
              ),
              _DashboardCard(
                title: 'Polls',
                subtitle: 'Vote & Live Results',
                icon: Icons.poll,
                onTap: () => Get.to(() => const PollsScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Student bottom sheet selector
  void _showStudentPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Student Profile',
              style: AppTypography.sectionHeader,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.students.length,
                itemBuilder: (context, index) {
                  final student = controller.students[index];
                  final isSelected =
                      controller.selectedStudent.value?.id == student.id;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? AppColors.chessGold
                          : AppColors.deepNavy,
                      child: Text(
                        student.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      student.name,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${student.level} • Rating: ${student.chessRating}',
                      style: AppTypography.caption,
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.chessGold,
                          )
                        : null,
                    onTap: () => controller.selectStudent(student),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// Helper Widget: Switcher Button
class _SwitcherButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _SwitcherButton({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 38,
        decoration: BoxDecoration(
          color: isActive ? AppColors.chessGold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.chessGold
                : AppColors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppTypography.caption.copyWith(
            color: AppColors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Helper Widget: Action Cards
class _DashboardCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  double _elevation = 2.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _elevation = 4.0),
      onTapUp: (_) => setState(() => _elevation = 2.0),
      onTapCancel: () => setState(() => _elevation = 2.0),
      onTap: widget.onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.white,
        elevation: _elevation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(widget.icon, color: AppColors.chessGold, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
