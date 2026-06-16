import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../data/models/poll.dart';
import '../../../data/models/poll_option.dart';
import '../../../data/models/poll_vote.dart';
import '../../dashboard/dashboard_controller.dart';

class PollsController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;
  final DashboardController _dashboardController = Get.find<DashboardController>();

  RxBool isLoading = true.obs;
  
  RxList<Poll> polls = <Poll>[].obs;
  // Map of pollId -> list of PollOptions
  RxMap<String, List<PollOption>> options = <String, List<PollOption>>{}.obs;
  // Map of pollId -> list of PollVotes
  RxMap<String, List<PollVote>> votes = <String, List<PollVote>>{}.obs;
  // Map of pollId -> voter's chosen optionId
  RxMap<String, String> userVotes = <String, String>{}.obs;

  RealtimeChannel? _votesChannel;

  @override
  void onInit() {
    super.onInit();
    fetchPolls();
    subscribeToVotes();

    ever(_dashboardController.selectedStudent, (_) {
      fetchPolls();
      subscribeToVotes();
    });
  }

  @override
  void onClose() {
    _votesChannel?.unsubscribe();
    super.onClose();
  }

  Future<void> fetchPolls() async {
    final student = _dashboardController.selectedStudent.value;
    final parentId = _dashboardController.parentId.value;
    
    if (student == null || student.batchId == null || parentId.isEmpty) {
      polls.clear();
      options.clear();
      votes.clear();
      userVotes.clear();
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;

      // 1. Fetch polls for this batch
      final pollsRes = await _client
          .from('polls')
          .select('*')
          .eq('batch_id', student.batchId!)
          .order('created_at', ascending: false);

      final List<Poll> loadedPolls = (pollsRes as List)
          .map((data) => Poll.fromJson(data as Map<String, dynamic>))
          .toList();

      if (loadedPolls.isEmpty) {
        polls.clear();
        options.clear();
        votes.clear();
        userVotes.clear();
        return;
      }

      final List<String> pollIds = loadedPolls.map((p) => p.id).toList();

      // 2. Fetch options for these polls
      final optionsRes = await _client
          .from('poll_options')
          .select('*')
          .inFilter('poll_id', pollIds);

      final List<PollOption> loadedOptions = (optionsRes as List)
          .map((data) => PollOption.fromJson(data as Map<String, dynamic>))
          .toList();

      // 3. Fetch votes for these polls
      final votesRes = await _client
          .from('poll_votes')
          .select('*')
          .inFilter('poll_id', pollIds);

      final List<PollVote> loadedVotes = (votesRes as List)
          .map((data) => PollVote.fromJson(data as Map<String, dynamic>))
          .toList();

      // Group options and votes
      final Map<String, List<PollOption>> optMap = {};
      final Map<String, List<PollVote>> voteMap = {};
      final Map<String, String> userVoteMap = {};

      for (var pId in pollIds) {
        optMap[pId] = [];
        voteMap[pId] = [];
      }

      for (var opt in loadedOptions) {
        optMap[opt.pollId]?.add(opt);
      }

      for (var vote in loadedVotes) {
        voteMap[vote.pollId]?.add(vote);
        // Check if this vote belongs to the logged-in parent
        if (vote.voterId == parentId) {
          userVoteMap[vote.pollId] = vote.optionId;
        }
      }

      polls.assignAll(loadedPolls);
      options.assignAll(optMap);
      votes.assignAll(voteMap);
      userVotes.assignAll(userVoteMap);
    } catch (e) {
      Get.snackbar('Error Loading Polls', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void subscribeToVotes() {
    _votesChannel?.unsubscribe();
    final student = _dashboardController.selectedStudent.value;
    if (student == null || student.batchId == null) return;

    // Listen to changes on poll_votes table
    _votesChannel = _client
        .channel('public:poll_votes:batch=${student.batchId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'poll_votes',
          callback: (payload) {
            // Reload votes to compute percentages
            _reloadVotesOnly();
          },
        )
        .subscribe();
  }

  Future<void> _reloadVotesOnly() async {
    final parentId = _dashboardController.parentId.value;
    if (polls.isEmpty || parentId.isEmpty) return;
    
    try {
      final pollIds = polls.map((p) => p.id).toList();
      
      final votesRes = await _client
          .from('poll_votes')
          .select('*')
          .inFilter('poll_id', pollIds);

      final List<PollVote> loadedVotes = (votesRes as List)
          .map((data) => PollVote.fromJson(data as Map<String, dynamic>))
          .toList();

      final Map<String, List<PollVote>> voteMap = {};
      final Map<String, String> userVoteMap = {};

      for (var pId in pollIds) {
        voteMap[pId] = [];
      }

      for (var vote in loadedVotes) {
        voteMap[vote.pollId]?.add(vote);
        if (vote.voterId == parentId) {
          userVoteMap[vote.pollId] = vote.optionId;
        }
      }

      votes.assignAll(voteMap);
      userVotes.assignAll(userVoteMap);
    } catch (_) {}
  }

  Future<void> castVote(String pollId, String optionId) async {
    final parentId = _dashboardController.parentId.value;
    if (parentId.isEmpty) return;

    // Check if already voted
    if (userVotes.containsKey(pollId)) {
      Get.snackbar('Already Voted', 'You have already submitted a vote for this poll.');
      return;
    }

    try {
      await _client.from('poll_votes').insert({
        'poll_id': pollId,
        'option_id': optionId,
        'voter_id': parentId,
      });

      Get.snackbar('Vote Submitted', 'Your response has been registered!');
      
      // Update local state temporarily, full state is synced via postgres changes subscription
      await _reloadVotesOnly();
    } catch (e) {
      Get.snackbar('Error Voting', e.toString());
    }
  }

  int getOptionVotes(String pollId, String optionId) {
    final list = votes[pollId] ?? [];
    return list.where((v) => v.optionId == optionId).length;
  }

  double getOptionPercentage(String pollId, String optionId) {
    final list = votes[pollId] ?? [];
    if (list.isEmpty) return 0.0;
    
    final optVotes = getOptionVotes(pollId, optionId);
    return optVotes / list.length;
  }
}
