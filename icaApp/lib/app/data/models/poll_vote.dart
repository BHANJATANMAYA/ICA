class PollVote {
  final String id;
  final String pollId;
  final String optionId;
  final String voterId;

  PollVote({
    required this.id,
    required this.pollId,
    required this.optionId,
    required this.voterId,
  });

  factory PollVote.fromJson(Map<String, dynamic> json) {
    return PollVote(
      id: json['id'] as String,
      pollId: json['poll_id'] as String,
      optionId: json['option_id'] as String,
      voterId: json['voter_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poll_id': pollId,
      'option_id': optionId,
      'voter_id': voterId,
    };
  }
}
