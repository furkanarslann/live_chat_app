import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../domain/core/failures.dart';
import '../../domain/models/chat_conversation.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final _conversations = <ChatConversation>[
    ChatConversation(
      id: '1',
      participantId: 'user1',
      participantName: 'John Doe',
      participantAvatar: 'https://i.pravatar.cc/150?img=1',
      unreadCount: 2,
      isOnline: true,
      lastMessage: ChatMessage(
        id: 'msg1',
        senderId: 'user1',
        receiverId: 'currentUser',
        content: 'Hey, how are you?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ),
    ChatConversation(
      id: '2',
      participantId: 'user2',
      participantName: 'Jane Smith',
      participantAvatar: 'https://i.pravatar.cc/150?img=2',
      unreadCount: 0,
      isOnline: false,
      lastMessage: ChatMessage(
        id: 'msg2',
        senderId: 'currentUser',
        receiverId: 'user2',
        content: 'See you tomorrow!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ),
  ];

  final _messages = <String, List<ChatMessage>>{
    '1': [
      ChatMessage(
        id: 'msg1',
        senderId: 'user1',
        receiverId: 'currentUser',
        content: 'Hey, how are you?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        id: 'msg2',
        senderId: 'currentUser',
        receiverId: 'user1',
        content: 'I\'m good, thanks! How about you?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ],
    '2': [
      ChatMessage(
        id: 'msg3',
        senderId: 'user2',
        receiverId: 'currentUser',
        content: 'Are we still meeting tomorrow?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        id: 'msg4',
        senderId: 'currentUser',
        receiverId: 'user2',
        content: 'See you tomorrow!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  };

  final _conversationsController =
      StreamController<List<ChatConversation>>.broadcast();
  final _messagesControllers = <String, StreamController<List<ChatMessage>>>{};

  @override
  Future<Either<Failure, List<ChatConversation>>> getConversations() async {
    try {
      return Right(_conversations);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
      String conversationId) async {
    try {
      final messages = _messages[conversationId] ?? [];
      return Right(messages);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendMessage(ChatMessage message) async {
    try {
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate network delay

      final conversationId = _conversations
          .firstWhere((conv) =>
              conv.participantId == message.receiverId ||
              conv.participantId == message.senderId)
          .id;

      _messages[conversationId] = [...?_messages[conversationId], message];

      // Update last message in conversation
      final conversationIndex =
          _conversations.indexWhere((conv) => conv.id == conversationId);
      if (conversationIndex != -1) {
        _conversations[conversationIndex] =
            _conversations[conversationIndex].copyWith(
          lastMessage: message,
          unreadCount: message.senderId == 'currentUser'
              ? 0
              : _conversations[conversationIndex].unreadCount + 1,
        );
      }

      // Notify listeners
      _conversationsController.add(_conversations);
      _messagesControllers[conversationId]
          ?.add(_messages[conversationId] ?? []);

      return const Right(unit);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markMessageAsRead(String messageId) async {
    try {
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate network delay

      for (final entry in _messages.entries) {
        final messageIndex =
            entry.value.indexWhere((msg) => msg.id == messageId);
        if (messageIndex != -1) {
          final message = entry.value[messageIndex];
          entry.value[messageIndex] = message.copyWith(isRead: true);

          // Update conversation unread count
          final conversationIndex =
              _conversations.indexWhere((conv) => conv.id == entry.key);
          if (conversationIndex != -1) {
            _conversations[conversationIndex] =
                _conversations[conversationIndex].copyWith(
              unreadCount: _conversations[conversationIndex].unreadCount - 1,
            );
          }

          // Notify listeners
          _conversationsController.add(_conversations);
          _messagesControllers[entry.key]?.add(entry.value);
          break;
        }
      }

      return const Right(unit);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Stream<Either<Failure, List<ChatMessage>>> watchMessages(
      String conversationId) {
    _messagesControllers[conversationId] ??=
        StreamController<List<ChatMessage>>.broadcast();

    // Emit initial data immediately
    Future.microtask(() {
      final messages = _messages[conversationId] ?? [];
      _messagesControllers[conversationId]?.add(messages);
    });

    return _messagesControllers[conversationId]!.stream.map(Right.new);
  }

  @override
  Stream<Either<Failure, List<ChatConversation>>> watchConversations() {
    // Emit initial data immediately
    Future.microtask(() {
      _conversationsController.add(_conversations);
    });

    return _conversationsController.stream.map(Right.new);
  }
}
