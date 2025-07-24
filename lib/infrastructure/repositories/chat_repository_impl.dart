import 'dart:async';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:live_chat_app/domain/core/failures.dart';
import 'package:live_chat_app/domain/models/chat_conversation.dart';
import 'package:live_chat_app/domain/models/chat_message.dart';
import 'package:live_chat_app/domain/repositories/chat_repository.dart';
import 'package:live_chat_app/infrastructure/core/json_data_reader.dart';

class ChatRepositoryImpl implements ChatRepository {
  List<ChatConversation> _conversations = [];
  Map<String, List<ChatMessage>> _messages = {};

  final _conversationsController =
      StreamController<List<ChatConversation>>.broadcast();
  final _messagesControllers = <String, StreamController<List<ChatMessage>>>{};

  // Random message content for simulation
  final List<String> _randomMessages = [
    'Hey there!',
    'How\'s your day going?',
    'Did you see the news?',
    'What are you up to?',
    'I was thinking about our last conversation...',
    'Can we meet up soon?',
    'That\'s interesting!',
    'I agree with you',
    'Not sure about that',
    'Let me check and get back to you',
  ];

  Timer? _autoMessageTimer;

  ChatRepositoryImpl() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _conversations = await JsonDataReader.loadConversations();
      _messages = await JsonDataReader.loadMessages();
      _conversationsController.add(_conversations);
    } catch (e) {
      // Handle initialization error
      print('Error initializing chat data: $e');
    }
  }

  ChatMessage _generateRandomMessage(String senderId, String receiverId) {
    final random = Random();
    final content = _randomMessages[random.nextInt(_randomMessages.length)];

    return ChatMessage(
      id: 'auto_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}',
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  @override
  void startAutoMessages() {
    _autoMessageTimer?.cancel();
    _autoMessageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      for (var i = 0; i < _conversations.length; i++) {
        if (i % 2 == 0) continue; // Skip even indexed conversations

        final conversation = _conversations[i];
        final message = _generateRandomMessage(
          conversation.participantId,
          'currentUser',
        );

        sendMessage(message);
      }
    });
  }

  @override
  void stopAutoMessages() {
    _autoMessageTimer?.cancel();
    _autoMessageTimer = null;
  }

  @override
  void dispose() {
    stopAutoMessages();
    _conversationsController.close();
    for (final controller in _messagesControllers.values) {
      controller.close();
    }
  }

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
      await Future.delayed(const Duration(milliseconds: 500));

      // Find the conversation by matching participant ID with sender or receiver
      final conversation = _conversations.firstWhere(
        (conv) =>
            conv.participantId == message.receiverId ||
            conv.participantId == message.senderId,
      );

      final conversationId = conversation.id;
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
      await Future.delayed(const Duration(milliseconds: 500));

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

    return _messagesControllers[conversationId]!.stream.map((messages) {
      return Right(messages);
    });
  }

  @override
  Stream<Either<Failure, List<ChatConversation>>> watchConversations() {
    // Emit initial data immediately
    Future.microtask(() {
      _conversationsController.add(_conversations);
    });

    return _conversationsController.stream.map((conversations) {
      return Right(conversations);
    });
  }

  @override
  Future<Either<Failure, Unit>> clearChatHistory(String conversationId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Clear messages for the conversation
      _messages[conversationId] = [];

      // Update conversation to remove last message and reset unread count
      final conversationIndex =
          _conversations.indexWhere((conv) => conv.id == conversationId);

      if (conversationIndex != -1) {
        _conversations[conversationIndex] = ChatConversation(
          lastMessage: null,
          unreadCount: 0,
          id: _conversations[conversationIndex].id,
          participantId: _conversations[conversationIndex].participantId,
          participantName: _conversations[conversationIndex].participantName,
          participantAvatar:
              _conversations[conversationIndex].participantAvatar,
          isOnline: _conversations[conversationIndex].isOnline,
        );
      }

      // Notify listeners
      _conversationsController.add(_conversations);
      _messagesControllers[conversationId]?.add([]);

      return const Right(unit);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }
}
