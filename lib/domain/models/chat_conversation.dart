import 'package:cloud_firestore/cloud_firestore.dart';
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
  final List<String> participants;
  final DateTime? lastSeen;
  final DateTime? createdAt;

  const ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    required this.participants,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
    this.isArchived = false,
    this.lastMessage,
    this.lastSeen,
    this.createdAt,
  });

  factory ChatConversation.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatConversation(
      id: id ?? map['id'] ?? '',
      participantId: map['participantId'] ?? '',
      participantName: map['participantName'] ?? '',
      participantAvatar: map['participantAvatar'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      unreadCount: map['unreadCount'] ?? 0,
      isOnline: map['isOnline'] ?? false,
      isPinned: map['isPinned'] ?? false,
      isArchived: map['isArchived'] ?? false,
      lastMessage: map['lastMessage'] != null 
          ? ChatMessage.fromMap(map['lastMessage'] as Map<String, dynamic>)
          : null,
      lastSeen: map['lastSeen'] != null 
          ? (map['lastSeen'] as Timestamp).toDate()
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
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'lastMessage': lastMessage?.toMap(),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  ChatConversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    List<String>? participants,
    int? unreadCount,
    bool? isOnline,
    bool? isPinned,
    bool? isArchived,
    ChatMessage? lastMessage,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      participants: participants ?? this.participants,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      lastMessage: lastMessage ?? this.lastMessage,
      lastSeen: lastSeen ?? this.lastSeen,
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
        unreadCount,
        isOnline,
        isPinned,
        isArchived,
        lastMessage,
        lastSeen,
        createdAt,
      ];
}
