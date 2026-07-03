import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'checkin_controller.dart';

class CheckinScreen extends StatefulWidget {
  final bool forceManual;

  const CheckinScreen({super.key, this.forceManual = false});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen>
    with SingleTickerProviderStateMixin {
  late final CheckinController _controller;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(CheckinController());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    Get.delete<CheckinController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        title: const Text(
          'Attendance Check-In',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final status = _controller.status.value;
        final isProcessing = status == CheckinStatus.requesting ||
            status == CheckinStatus.locating ||
            status == CheckinStatus.syncing;
        final isSuccess = status == CheckinStatus.success;
        final isFailed = status == CheckinStatus.failed;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Academy info card
                _AcademyInfoCard(),
                const SizedBox(height: 32),

                // Status indicator
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated check-in button / status display
                        ScaleTransition(
                          scale: isProcessing ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                          child: _StatusCircle(
                            status: status,
                            geofenceVerified: _controller.geofenceVerified.value,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Status message
                        if (_controller.statusMessage.value.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? AppColors.successGreen.withValues(alpha: 0.1)
                                  : isFailed
                                      ? AppColors.alertRed.withValues(alpha: 0.1)
                                      : AppColors.deepNavy.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _controller.statusMessage.value,
                              style: AppTypography.body.copyWith(
                                color: isSuccess
                                    ? AppColors.successGreen
                                    : isFailed
                                        ? AppColors.alertRed
                                        : AppColors.darkGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Distance info
                        if (_controller.distanceFromAcademy.value > 0 &&
                            !_controller.geofenceVerified.value)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_off_outlined,
                                    size: 16, color: AppColors.alertRed),
                                const SizedBox(width: 6),
                                Text(
                                  '${_controller.distanceFromAcademy.value.toStringAsFixed(0)}m from academy (max 200m)',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.alertRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                if (!isProcessing) ...[
                  if (status == CheckinStatus.idle ||
                      status == CheckinStatus.failed) ...[
                    ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => _controller.checkIn(
                                forceManual: widget.forceManual,
                              ),
                      icon: const Icon(Icons.where_to_vote_rounded,
                          color: Colors.white),
                      label: Text(
                        widget.forceManual
                            ? 'Manual Check-In'
                            : 'Check In',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.chessGold,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                    ),
                    if (!widget.forceManual) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          _controller.isManualMode.value = true;
                          _controller.checkIn(forceManual: true);
                        },
                        child: Text(
                          'Use Manual Check-in Instead',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                    ],
                  ],
                  if (isSuccess) ...[
                    ElevatedButton.icon(
                      onPressed: () => Get.back(),
                      icon:
                          const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        'Done',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ],

                if (isProcessing) ...[
                  const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.chessGold),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _AcademyInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.chessGold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppColors.chessGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Indian Chess Academy',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Parul University, Vadodara',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.chessGold.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '200m geofence',
                        style: TextStyle(
                          color: AppColors.chessGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '22.2678°N, 73.1433°E',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  final CheckinStatus status;
  final bool geofenceVerified;

  const _StatusCircle({required this.status, required this.geofenceVerified});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;
    IconData icon;
    String label;

    switch (status) {
      case CheckinStatus.idle:
        bgColor = AppColors.deepNavy.withValues(alpha: 0.08);
        iconColor = AppColors.chessGold;
        icon = Icons.where_to_vote_outlined;
        label = 'Ready to Check In';
        break;
      case CheckinStatus.requesting:
      case CheckinStatus.locating:
        bgColor = AppColors.chessGold.withValues(alpha: 0.1);
        iconColor = AppColors.chessGold;
        icon = Icons.my_location_rounded;
        label = 'Locating...';
        break;
      case CheckinStatus.syncing:
        bgColor = AppColors.deepNavy.withValues(alpha: 0.08);
        iconColor = AppColors.deepNavy;
        icon = Icons.cloud_upload_outlined;
        label = 'Saving...';
        break;
      case CheckinStatus.success:
        bgColor = AppColors.successGreen.withValues(alpha: 0.1);
        iconColor = AppColors.successGreen;
        icon = geofenceVerified
            ? Icons.verified_rounded
            : Icons.check_circle_outline_rounded;
        label = geofenceVerified ? 'Geofence Verified ✓' : 'Manual Check-in';
        break;
      case CheckinStatus.failed:
        bgColor = AppColors.alertRed.withValues(alpha: 0.1);
        iconColor = AppColors.alertRed;
        icon = Icons.error_outline_rounded;
        label = 'Check-in Failed';
        break;
    }

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(icon, size: 52, color: iconColor),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: AppTypography.body.copyWith(
            color: iconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
