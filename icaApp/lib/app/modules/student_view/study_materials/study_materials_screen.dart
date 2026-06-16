import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'study_materials_controller.dart';

class StudyMaterialsScreen extends StatelessWidget {
  const StudyMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudyMaterialsController());

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Study Materials', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchMaterials(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.chessGold),
            ),
          );
        }

        if (controller.materials.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_books_outlined, size: 64, color: AppColors.chessGold),
                  const SizedBox(height: 16),
                  const Text('No Study Materials', style: AppTypography.sectionHeader),
                  const SizedBox(height: 8),
                  Text(
                    'Your coach hasn\'t shared any study materials or worksheets for this batch yet.',
                    style: AppTypography.body.copyWith(color: AppColors.darkGray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.materials.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.materials[index];
            final hasFile = item.fileUrl != null && item.fileUrl!.isNotEmpty;
            final hasLink = item.linkUrl != null && item.linkUrl!.isNotEmpty;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.chessGold,
                          radius: 18,
                          child: Icon(Icons.menu_book, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppTypography.sectionHeader.copyWith(fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasLink ? 'External Link / Study' : 'PDF Document',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (hasLink)
                          ElevatedButton.icon(
                            onPressed: () => _launchURL(item.linkUrl!),
                            icon: const Icon(Icons.open_in_new, size: 16, color: Colors.white),
                            label: const Text('Open Lichess / Study', style: TextStyle(color: Colors.white, fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.chessGold,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        if (hasFile && !hasLink)
                          ElevatedButton.icon(
                            onPressed: () => _launchURL(item.fileUrl!),
                            icon: const Icon(Icons.download, size: 16, color: Colors.white),
                            label: const Text('Download PDF', style: TextStyle(color: Colors.white, fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.deepNavy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Link Error', 'Could not launch $urlString');
      }
    } catch (e) {
      Get.snackbar('Link Error', 'Invalid URL: $urlString');
    }
  }
}
