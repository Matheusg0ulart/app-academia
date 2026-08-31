// lib/models/ai_message.dart

class AiMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? source;

  const AiMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.source,
  });

  factory AiMessage.user(String text) {
    return AiMessage(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      text:      text,
      isUser:    true,
      timestamp: DateTime.now(),
    );
  }

  factory AiMessage.assistant(String text, {String? source}) {
    return AiMessage(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      text:      text,
      isUser:    false,
      timestamp: DateTime.now(),
      source:    source,
    );
  }
}

