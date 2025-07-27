import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'chat_message.dart';
import '../auth/user.dart';

class ChatConversation extends Equatable {
  final String id;
  final List<String> participants;
  final ChatMessage? lastMessage;
  final DateTime? createdAt;

  const ChatConversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.createdAt,
  });

  // Helper methods to work with user preferences
  bool isPinnedBy(User user) =>
      user.chatPreferences.pinnedConversations.contains(id);
  bool isArchivedBy(User user) =>
      user.chatPreferences.archivedConversations.contains(id);

  String getParticipantId(User currentUser) {
    return participants.firstWhere(
      (id) => id != currentUser.id,
      orElse: () => throw Exception('No other participant found'),
    );
  }

  factory ChatConversation.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatConversation(
      id: id ?? map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] != null
          ? ChatMessage.fromMap(map['lastMessage'] as Map<String, dynamic>)
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage?.toMap(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  ChatConversation copyWith({
    String? id,
    List<String>? participants,
    ChatMessage? lastMessage,
    DateTime? createdAt,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, participants, lastMessage, createdAt];
}
