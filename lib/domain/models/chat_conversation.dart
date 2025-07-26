import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'chat_message.dart';
import 'user.dart';

class ChatConversation extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final ChatMessage? lastMessage;
  final List<String> participants;
  final DateTime? createdAt;

  const ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    required this.participants,
    this.lastMessage,
    this.createdAt,
  });

  // Helper methods to work with user preferences
  bool isPinnedBy(User user) => user.chatPreferences.pinnedConversations.contains(id);
  bool isArchivedBy(User user) => user.chatPreferences.archivedConversations.contains(id);
  int getUnreadCountFor(User user) => user.chatPreferences.unreadCounts[id] ?? 0;

  factory ChatConversation.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatConversation(
      id: id ?? map['id'] ?? '',
      participantId: map['participantId'] ?? '',
      participantName: map['participantName'] ?? '',
      participantAvatar: map['participantAvatar'] ?? '',
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
      'participantId': participantId,
      'participantName': participantName,
      'participantAvatar': participantAvatar,
      'participants': participants,
      'lastMessage': lastMessage?.toMap(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  ChatConversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    List<String>? participants,
    ChatMessage? lastMessage,
    DateTime? createdAt,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        participantId,
        participantName,
        participantAvatar,
        participants,
        lastMessage,
        createdAt,
      ];
}
