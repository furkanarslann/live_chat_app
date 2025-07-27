import 'package:equatable/equatable.dart';

class UserChatPreferences extends Equatable {
  final List<String> pinnedConversations;
  final List<String> archivedConversations;

  const UserChatPreferences({
    this.pinnedConversations = const [],
    this.archivedConversations = const [],
  });

  factory UserChatPreferences.fromMap(Map<String, dynamic> map) {
    return UserChatPreferences(
      pinnedConversations: List<String>.from(map['pinnedConversations'] ?? []),
      archivedConversations:
          List<String>.from(map['archivedConversations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pinnedConversations': pinnedConversations,
      'archivedConversations': archivedConversations,
    };
  }

  bool isPinnedBy(String conversationId) =>
      pinnedConversations.contains(conversationId);

  bool isArchivedBy(String conversationId) =>
      archivedConversations.contains(conversationId);

  UserChatPreferences copyWith({
    List<String>? pinnedConversations,
    List<String>? archivedConversations,
  }) {
    return UserChatPreferences(
      pinnedConversations: pinnedConversations ?? this.pinnedConversations,
      archivedConversations:
          archivedConversations ?? this.archivedConversations,
    );
  }

  @override
  List<Object?> get props => [pinnedConversations, archivedConversations];
}
