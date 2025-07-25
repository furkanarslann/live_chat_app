import 'package:equatable/equatable.dart';
import 'chat_message.dart';

class ChatConversation extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final int unreadCount;
  final bool isOnline;
  final ChatMessage? lastMessage;
  final bool isPinned;
  final bool isArchived;

  const ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    required this.unreadCount,
    required this.isOnline,
    this.lastMessage,
    this.isPinned = false,
    this.isArchived = false,
  });

  @override
  List<Object?> get props => [
        id,
        participantId,
        participantName,
        participantAvatar,
        unreadCount,
        isOnline,
        lastMessage,
        isPinned,
        isArchived,
      ];

  ChatConversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    int? unreadCount,
    bool? isOnline,
    ChatMessage? lastMessage,
    bool? isPinned,
    bool? isArchived,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastMessage: lastMessage ?? this.lastMessage,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
