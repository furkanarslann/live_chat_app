import 'package:equatable/equatable.dart';
import 'chat_message.dart';

class ChatConversation extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;
  final bool isArchived;
  final ChatMessage? lastMessage;

  const ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
    this.isArchived = false,
    this.lastMessage,
  });

  factory ChatConversation.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatConversation(
      id: id ?? map['id'] ?? '',
      participantId: map['participantId'] ?? '',
      participantName: map['participantName'] ?? '',
      participantAvatar: map['participantAvatar'] ?? '',
      unreadCount: map['unreadCount'] ?? 0,
      isOnline: map['isOnline'] ?? false,
      isPinned: map['isPinned'] ?? false,
      isArchived: map['isArchived'] ?? false,
      lastMessage: map['lastMessage'] != null 
          ? ChatMessage.fromMap(map['lastMessage'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'participantName': participantName,
      'participantAvatar': participantAvatar,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'participants': ['currentUser', participantId],
      'lastMessage': lastMessage?.toMap(),
    };
  }

  ChatConversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    int? unreadCount,
    bool? isOnline,
    bool? isPinned,
    bool? isArchived,
    ChatMessage? lastMessage,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        participantId,
        participantName,
        participantAvatar,
        unreadCount,
        isOnline,
        isPinned,
        isArchived,
        lastMessage,
      ];
}
