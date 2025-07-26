import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:dartz/dartz.dart';
import '../../domain/core/failures.dart';
import '../../domain/models/user.dart';
import '../../domain/models/user_chat_preferences.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserRepositoryImpl({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<Either<Failure, User>> watchCurrentUser() {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return Stream.value(left(const UnexpectedFailure()));

      return _firestore
          .collection('users')
          .doc(currentUser.uid)
          .snapshots()
          .map((doc) {
        try {
          if (!doc.exists) return left(const UnexpectedFailure());
          return right(User.fromMap(doc.data()!));
        } catch (e) {
          return left(const UnexpectedFailure());
        }
      });
    } catch (e) {
      return Stream.value(left(const UnexpectedFailure()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateChatPreferences(UserChatPreferences preferences) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return left(const UnexpectedFailure());

      await _firestore.collection('users').doc(currentUser.uid).update({
        'chatPreferences': preferences.toMap(),
      });

      return right(unit);
    } catch (e) {
      return left(const UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> togglePinConversation(String conversationId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return left(const UnexpectedFailure());

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data() ?? {};
      
      final preferences = UserChatPreferences.fromMap(userData['chatPreferences'] ?? {});
      final isPinned = preferences.isPinnedBy(conversationId);

      final updatedPreferences = preferences.copyWith(
        pinnedConversations: isPinned
            ? preferences.pinnedConversations.where((id) => id != conversationId).toList()
            : [...preferences.pinnedConversations, conversationId],
      );

      await _firestore.collection('users').doc(currentUser.uid).update({
        'chatPreferences': updatedPreferences.toMap(),
      });

      return right(unit);
    } catch (e) {
      print('Error toggling pin: $e');
      return left(const UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleArchiveConversation(String conversationId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return left(const UnexpectedFailure());

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data() ?? {};
      
      final preferences = UserChatPreferences.fromMap(userData['chatPreferences'] ?? {});
      final isArchived = preferences.isArchivedBy(conversationId);

      final updatedPreferences = preferences.copyWith(
        archivedConversations: isArchived
            ? preferences.archivedConversations.where((id) => id != conversationId).toList()
            : [...preferences.archivedConversations, conversationId],
        // Unpin when archiving
        pinnedConversations: preferences.pinnedConversations.where((id) => id != conversationId).toList(),
      );

      await _firestore.collection('users').doc(currentUser.uid).update({
        'chatPreferences': updatedPreferences.toMap(),
      });

      return right(unit);
    } catch (e) {
      print('Error toggling archive: $e');
      return left(const UnexpectedFailure());
    }
  }
} 