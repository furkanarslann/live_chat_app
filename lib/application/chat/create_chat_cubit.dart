import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/core/failures.dart';
import '../../domain/models/user.dart';
import '../../domain/models/chat_conversation.dart';
import 'create_chat_state.dart';

class CreateChatCubit extends Cubit<CreateChatState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription? _usersSubscription;

  CreateChatCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const CreateChatState()) {
    _watchUsers();
  }

  void _watchUsers() {
    _usersSubscription?.cancel();

    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      emit(state.copyWith(
        failureOrUsersOpt: some(left(const UnexpectedFailure())),
      ));
      return;
    }

    _usersSubscription = _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.id != currentUserId)
            .map((doc) => User.fromMap(
                  doc.data(),
                  id: doc.id,
                ))
            .toList())
        .listen(
          (users) => emit(state.copyWith(
            failureOrUsersOpt: some(right(users)),
          )),
          onError: (error) => emit(state.copyWith(
            failureOrUsersOpt: some(left(const UnexpectedFailure())),
          )),
        );
  }

  void searchQueryChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<Option<ChatConversation>> createChat(User user) async {
    try {
      emit(state.copyWith(isLoading: true));

      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        emit(state.copyWith(
          isLoading: false,
          failureOrSuccessOpt: some(left(const UnexpectedFailure())),
        ));
        return none();
      }

      final ids = [currentUserId, user.id]..sort();
      final conversationId = ids.join('_');

      // Check if conversation already exists
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!conversationDoc.exists) {
        // Create new conversation with current participant information
        final conversation = ChatConversation(
          id: conversationId,
          participantId: user.id,
          participantName: user.fullName,
          participantAvatar: user.displayPhotoUrl,
          participants: [currentUserId, user.id],
        );

        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .set(conversation.toMap());

        emit(state.copyWith(
          isLoading: false,
          failureOrSuccessOpt: some(right(unit)),
        ));

        return some(conversation);
      } else {
        // Return existing conversation with updated participant information
        final existingConversation = ChatConversation.fromMap(
          conversationDoc.data()!,
          id: conversationDoc.id,
        );

        // Update the conversation with current participant information
        final updatedConversation = existingConversation.copyWith(
          participantName: user.fullName,
          participantAvatar: user.displayPhotoUrl,
        );

        // Update the conversation document with current participant info
        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .update({
          'participantName': user.fullName,
          'participantAvatar': user.displayPhotoUrl,
        });

        emit(state.copyWith(
          isLoading: false,
          failureOrSuccessOpt: some(right(unit)),
        ));

        return some(updatedConversation);
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        failureOrSuccessOpt: some(left(const UnexpectedFailure())),
      ));
      return none();
    }
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }
}
