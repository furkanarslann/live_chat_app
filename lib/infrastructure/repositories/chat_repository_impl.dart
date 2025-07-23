import 'dart:async';
import 'dart:math';
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
    ChatConversation(
      id: '3',
      participantId: 'user3',
      participantName: 'Alex Johnson',
      participantAvatar: 'https://i.pravatar.cc/150?img=3',
      unreadCount: 5,
      isOnline: true,
      lastMessage: ChatMessage(
        id: 'msg_alex1',
        senderId: 'user3',
        receiverId: 'currentUser',
        content: 'Did you review the project proposal?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ),
    ChatConversation(
      id: '4',
      participantId: 'user4',
      participantName: 'Sarah Wilson',
      participantAvatar: 'https://i.pravatar.cc/150?img=4',
      unreadCount: 0,
      isOnline: true,
      lastMessage: ChatMessage(
        id: 'msg_sarah1',
        senderId: 'currentUser',
        receiverId: 'user4',
        content: 'The design looks perfect! 👍',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ),
    ChatConversation(
      id: '5',
      participantId: 'user5',
      participantName: 'Mike Brown',
      participantAvatar: 'https://i.pravatar.cc/150?img=5',
      unreadCount: 1,
      isOnline: false,
      lastMessage: ChatMessage(
        id: 'msg_mike1',
        senderId: 'user5',
        receiverId: 'currentUser',
        content: 'Are we still on for lunch?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ),
    ChatConversation(
      id: '6',
      participantId: 'user6',
      participantName: 'Emma Davis',
      participantAvatar: 'https://i.pravatar.cc/150?img=6',
      unreadCount: 3,
      isOnline: true,
      lastMessage: ChatMessage(
        id: 'msg_emma1',
        senderId: 'user6',
        receiverId: 'currentUser',
        content: 'Check out this new feature I just pushed! 🚀',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
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
    '3': [
      ChatMessage(
        id: 'msg_alex1',
        senderId: 'user3',
        receiverId: 'currentUser',
        content: 'Hey, can we discuss the project timeline?',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ChatMessage(
        id: 'msg_alex2',
        senderId: 'currentUser',
        receiverId: 'user3',
        content: 'Sure, I\'ll prepare the schedule.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      ChatMessage(
        id: 'msg_alex3',
        senderId: 'user3',
        receiverId: 'currentUser',
        content: 'Great! I\'ve sent you the requirements.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        id: 'msg_alex4',
        senderId: 'user3',
        receiverId: 'currentUser',
        content: 'Did you review the project proposal?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ],
    '4': [
      ChatMessage(
        id: 'msg_sarah1',
        senderId: 'user4',
        receiverId: 'currentUser',
        content: 'Here\'s the latest UI design',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ChatMessage(
        id: 'msg_sarah2',
        senderId: 'user4',
        receiverId: 'currentUser',
        content: 'I made some changes to the color scheme',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ChatMessage(
        id: 'msg_sarah3',
        senderId: 'currentUser',
        receiverId: 'user4',
        content: 'The design looks perfect! 👍',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
    '5': [
      ChatMessage(
        id: 'msg_mike1',
        senderId: 'user5',
        receiverId: 'currentUser',
        content: 'Are we still on for lunch?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ],
    '6': [
      ChatMessage(
        id: 'msg_emma1',
        senderId: 'user6',
        receiverId: 'currentUser',
        content: 'I just finished implementing the new API',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        id: 'msg_emma2',
        senderId: 'user6',
        receiverId: 'currentUser',
        content: 'The tests are all passing',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ChatMessage(
        id: 'msg_emma3',
        senderId: 'user6',
        receiverId: 'currentUser',
        content: 'Check out this new feature I just pushed! 🚀',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ],
  };

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
