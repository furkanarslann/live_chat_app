import 'package:equatable/equatable.dart';
import 'chat_message.dart';

class ChatConversation extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final bool isOnline;

  const ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [
        id,
        participantId,
        participantName,
        participantAvatar,
        lastMessage,
        unreadCount,
        isOnline,
      ];

  ChatConversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    ChatMessage? lastMessage,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }
} 