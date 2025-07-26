import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:live_chat_app/domain/core/failures.dart';
import 'package:live_chat_app/domain/models/chat_conversation.dart';
import 'package:live_chat_app/domain/models/chat_message.dart';
import 'package:live_chat_app/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Collection references
  CollectionReference get _conversationsRef =>
      _firestore.collection('conversations');

  CollectionReference get _messagesRef => _firestore.collection('messages');

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

      // Update conversation's last message
      await _conversationsRef.doc(conversationId).update({
        'lastMessage': {
          ...message.toMap(),
          'id': messageRef.id,
        },
        'unreadCount': FieldValue.increment(
          message.senderId == currentUserId ? 0 : 1,
        ),
      });

      return const Right(unit);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markMessageAsRead(String messageId) async {
    try {
      await _messagesRef.doc(messageId).update({'isRead': true});
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
          .map((snapshot) {
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
  Future<Either<Failure, Unit>> clearChatHistory(String conversationId) async {
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
        'unreadCount': 0,
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
}
