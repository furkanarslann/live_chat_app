import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:dartz/dartz.dart';
import 'package:live_chat_app/domain/core/failures.dart';
import 'package:live_chat_app/domain/chat/chat_conversation.dart';
import 'package:live_chat_app/domain/chat/chat_message.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import 'package:live_chat_app/domain/chat/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Collection references
  CollectionReference get _conversationsRef {
    return _firestore.collection('conversations');
  }

  CollectionReference get _messagesRef {
    return _firestore.collection('messages');
  }

  CollectionReference get _usersRef => _firestore.collection('users');

  Future<User?> _getConversationParticipant(String participantId) async {
    try {
      final doc = await _usersRef.doc(participantId).get();
      if (doc.exists) {
        return User.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Batch load participants for multiple conversations efficiently
  /// Uses Firestore's whereIn with batching to handle the 10-item limit
  @override
  Future<Map<String, User>> getConversationParticipants(
    List<String> participantIds,
  ) async {
    final Map<String, User> userMap = {};

    // Batch by 10 due to Firestore's whereIn limit
    for (var i = 0; i < participantIds.length; i += 10) {
      final batch = participantIds.skip(i).take(10).toList();
      try {
        final userSnap =
            await _usersRef.where(FieldPath.documentId, whereIn: batch).get();

        for (final doc in userSnap.docs) {
          userMap[doc.id] = User.fromMap(
            doc.data() as Map<String, dynamic>,
            id: doc.id,
          );
        }
      } catch (e) {
        // If whereIn fails (e.g., empty array), fall back to individual requests
        for (final participantId in batch) {
          final user = await _getConversationParticipant(participantId);
          if (user != null) {
            userMap[participantId] = user;
          }
        }
      }
    }

    return userMap;
  }

  // Get current user ID or throw error if not authenticated
  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw const UnexpectedFailure();
    return user.uid;
  }

  @override
  Future<Either<Failure, List<ChatConversation>>> getConversations() async {
    try {
      final snapshot = await _conversationsRef
          .where('participants', arrayContains: _currentUserId)
          .get();

      final conversations = snapshot.docs
          .map((doc) => ChatConversation.fromMap(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();

      return Right(conversations);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String conversationId,
  ) async {
    try {
      final snapshot = await _messagesRef
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: false)
          .get();

      final messages = snapshot.docs
          .map((doc) => ChatMessage.fromMap(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();

      return Right(messages);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String content,
    required String participantId,
    required String conversationId,
  }) async {
    try {
      final currentUserId = _currentUserId;

      final message = ChatMessage(
        id: '', // Firebase will generate this when added.
        senderId: currentUserId,
        receiverId: participantId,
        content: content,
        timestamp: DateTime.now(),
      );

      // Add message to Firestore
      final messageRef = await _messagesRef.add({
        'conversationId': conversationId,
        ...message.toMap(),
      });

      // Check if conversation exists, if not create it
      final conversationDoc = await _conversationsRef.doc(conversationId).get();

      if (!conversationDoc.exists) {
        // Create the conversation with the first message
        final conversation = ChatConversation(
          id: conversationId,
          participants: [currentUserId, participantId],
          lastMessage: message.copyWith(id: messageRef.id),
          createdAt: DateTime.now(),
        );

        await _conversationsRef.doc(conversationId).set(conversation.toMap());
      } else {
        // Update existing conversation's last message
        await _conversationsRef.doc(conversationId).update({
          'lastMessage': {
            ...message.toMap(),
            'id': messageRef.id,
          },
        });
      }

      return const Right(unit);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  /// Mark multiple messages as read (only for receiver)
  @override
  Future<Either<Failure, Unit>> markMessagesAsRead(
    List<String> messageIds,
  ) async {
    try {
      final currentUserId = _currentUserId;

      // Get all messages to validate receiver permissions
      final messagesSnapshot = await _messagesRef
          .where(FieldPath.documentId, whereIn: messageIds)
          .get();

      final batch = _firestore.batch();
      final validMessageIds = <String>[];
      final conversationIds = <String>{};

      for (final doc in messagesSnapshot.docs) {
        final messageData = doc.data() as Map<String, dynamic>;
        final receiverId = messageData['receiverId'] as String;
        final conversationId = messageData['conversationId'] as String?;

        // Only include messages where current user is the receiver
        if (receiverId == currentUserId) {
          batch.update(doc.reference, {'isRead': true});
          validMessageIds.add(doc.id);
          if (conversationId != null) {
            conversationIds.add(conversationId);
          }
        }
      }

      // Update the lastMessage in each affected conversation with the current read status
      for (final conversationId in conversationIds) {
        final lastMessageSnapshot = await _messagesRef
            .where('conversationId', isEqualTo: conversationId)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (lastMessageSnapshot.docs.isNotEmpty) {
          final lastMessageDoc = lastMessageSnapshot.docs.first;
          final lastMessageData = lastMessageDoc.data() as Map<String, dynamic>;

          // Update the lastMessage in the conversation with the current read status
          batch.update(_conversationsRef.doc(conversationId), {
            'lastMessage': {
              ...lastMessageData,
              'isRead': true,
            },
          });
        }
      }

      if (validMessageIds.isNotEmpty) {
        await batch.commit();
      }

      return const Right(unit);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  /// Mark all unread messages in a conversation as read (only for receiver)
  @override
  Future<Either<Failure, Unit>> markConversationMessagesAsRead(
    String conversationId,
  ) async {
    try {
      final currentUserId = _currentUserId;

      // Get all unread messages in the conversation where current user is receiver
      final messagesSnapshot = await _messagesRef
          .where('conversationId', isEqualTo: conversationId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      if (messagesSnapshot.docs.isEmpty) {
        return const Right(unit);
      }

      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Update the lastMessage in the conversation with the new read status
      final lastMessageSnapshot = await _messagesRef
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (lastMessageSnapshot.docs.isNotEmpty) {
        final lastMessageDoc = lastMessageSnapshot.docs.first;
        final lastMessageData = lastMessageDoc.data() as Map<String, dynamic>;

        // Update the lastMessage in the conversation with the current read status
        batch.update(_conversationsRef.doc(conversationId), {
          'lastMessage': {
            ...lastMessageData,
            'isRead': true,
          },
        });
      }

      await batch.commit();
      return const Right(unit);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Stream<Either<Failure, List<ChatMessage>>> watchMessages(
    String conversationId,
  ) {
    return _messagesRef
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      try {
        final messages = snapshot.docs
            .map((doc) => ChatMessage.fromMap(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ))
            .toList();
        return Right(messages);
      } catch (e) {
        return const Left(UnexpectedFailure());
      }
    });
  }

  @override
  Stream<Either<Failure, List<ChatConversation>>> watchConversations() {
    try {
      final currentUserId = _currentUserId;
      return _conversationsRef
          .where('participants', arrayContains: currentUserId)
          .snapshots()
          .asyncMap((snapshot) async {
        final conversations = snapshot.docs
            .map((doc) => ChatConversation.fromMap(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ))
            .toList();

        return Right(conversations);
      });
    } catch (e) {
      return Stream.value(const Left(UnexpectedFailure()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearConversationChatHistory(
      String conversationId) async {
    try {
      // Delete all messages in the conversation
      final messagesSnapshot = await _messagesRef
          .where('conversationId', isEqualTo: conversationId)
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Update conversation to remove last message
      batch.update(_conversationsRef.doc(conversationId), {
        'lastMessage': null,
      });

      await batch.commit();
      return const Right(unit);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteConversation(
    String conversationId,
  ) async {
    try {
      await _messagesRef
          .where('conversationId', isEqualTo: conversationId)
          .get()
          .then((snapshot) {
        final batch = _firestore.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        return batch.commit();
      });

      await _conversationsRef.doc(conversationId).delete();
      return const Right(unit);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Map<String, int>> getUnreadMessagesCount() async {
    try {
      final currentUserId = _currentUserId;

      // Get all unread messages where current user is the receiver
      final messagesSnapshot = await _messagesRef
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final unreadCountMap = <String, int>{};

      // Group messages by conversationId and count them
      for (final doc in messagesSnapshot.docs) {
        final messageData = doc.data() as Map<String, dynamic>;
        final conversationId = messageData['conversationId'] as String?;

        if (conversationId != null) {
          unreadCountMap[conversationId] =
              (unreadCountMap[conversationId] ?? 0) + 1;
        }
      }

      return unreadCountMap;
    } catch (e) {
      // Return empty map on error
      return <String, int>{};
    }
  }
}
