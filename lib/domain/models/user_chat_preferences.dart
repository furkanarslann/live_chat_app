import 'package:equatable/equatable.dart';

class UserChatPreferences extends Equatable {
  final List<String> pinnedConversations;
  final List<String> archivedConversations;
  final Map<String, int> unreadCounts;

  const UserChatPreferences({
    this.pinnedConversations = const [],
    this.archivedConversations = const [],
    this.unreadCounts = const {},
  });

  factory UserChatPreferences.fromMap(Map<String, dynamic> map) {
    return UserChatPreferences(
      pinnedConversations: List<String>.from(map['pinnedConversations'] ?? []),
      archivedConversations: List<String>.from(map['archivedConversations'] ?? []),
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pinnedConversations': pinnedConversations,
      'archivedConversations': archivedConversations,
      'unreadCounts': unreadCounts,
    };
  }

  bool isPinnedBy(String conversationId) => 
      pinnedConversations.contains(conversationId);

  bool isArchivedBy(String conversationId) => 
      archivedConversations.contains(conversationId);

  int getUnreadCount(String conversationId) => 
      unreadCounts[conversationId] ?? 0;

  UserChatPreferences copyWith({
    List<String>? pinnedConversations,
    List<String>? archivedConversations,
    Map<String, int>? unreadCounts,
  }) {
    return UserChatPreferences(
      pinnedConversations: pinnedConversations ?? this.pinnedConversations,
      archivedConversations: archivedConversations ?? this.archivedConversations,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }

  @override
  List<Object?> get props => [
        pinnedConversations,
        archivedConversations,
        unreadCounts,
      ];
}
