import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'polls_controller.dart';

class PollsScreen extends StatelessWidget {
  const PollsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PollsController());

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Batch Polls', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchPolls(),
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

        if (controller.polls.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.poll_outlined, size: 64, color: AppColors.chessGold),
                  const SizedBox(height: 16),
                  const Text('No Active Polls', style: AppTypography.sectionHeader),
                  const SizedBox(height: 8),
                  Text(
                    'No active polls have been posted for your batch. Check back later!',
                    style: AppTypography.body.copyWith(color: AppColors.darkGray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.polls.length,
          itemBuilder: (context, index) {
            final poll = controller.polls[index];
            final pollOpts = controller.options[poll.id] ?? [];
            final totalVotes = controller.votes[poll.id]?.length ?? 0;
            final votedOptionId = controller.userVotes[poll.id];
            final hasVoted = votedOptionId != null;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(poll.question, style: AppTypography.sectionHeader.copyWith(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      'Total votes: $totalVotes • ${hasVoted ? "Response submitted" : "Response pending"}',
                      style: AppTypography.caption,
                    ),
                    const Divider(height: 24),
                    
                    // Render Options
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pollOpts.length,
                      itemBuilder: (context, optIdx) {
                        final opt = pollOpts[optIdx];
                        
                        if (hasVoted) {
                          // Show results mode
                          final pct = controller.getOptionPercentage(poll.id, opt.id);
                          final votesCount = controller.getOptionVotes(poll.id, opt.id);
                          final isUserChoice = votedOptionId == opt.id;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          if (isUserChoice)
                                            const Icon(Icons.check_circle, color: AppColors.successGreen, size: 16)
                                          else
                                            const SizedBox(width: 16),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              opt.optionText,
                                              style: AppTypography.body.copyWith(
                                                fontWeight: isUserChoice ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${(pct * 100).toStringAsFixed(0)}% ($votesCount)',
                                      style: AppTypography.caption.copyWith(
                                        fontWeight: isUserChoice ? FontWeight.bold : FontWeight.normal,
                                        color: isUserChoice ? AppColors.successGreen : AppColors.darkGray,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: AppColors.offWhite,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isUserChoice ? AppColors.successGreen : AppColors.chessGold,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Show interactive voting mode
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: OutlinedButton(
                              onPressed: () => controller.castVote(poll.id, opt.id),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.deepNavy,
                                side: const BorderSide(color: AppColors.lightGray),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                alignment: Alignment.centerLeft,
                              ),
                              child: Text(
                                opt.optionText,
                                style: AppTypography.body.copyWith(color: AppColors.deepNavy),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
