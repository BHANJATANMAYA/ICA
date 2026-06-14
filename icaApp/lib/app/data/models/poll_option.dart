class PollOption {
  final String id;
  final String pollId;
  final String optionText;

  PollOption({
    required this.id,
    required this.pollId,
    required this.optionText,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] as String,
      pollId: json['poll_id'] as String,
      optionText: json['option_text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poll_id': pollId,
      'option_text': optionText,
    };
  }
}
