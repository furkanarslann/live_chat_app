import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:live_chat_app/domain/models/user_chat_preferences.dart';

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final bool isOnline;
  final UserChatPreferences chatPreferences;
  final String? photoUrl;
  final DateTime? lastSeen;

  static const String defaultPhotoUrl = 'assets/images/anon-user.png';

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photoUrl,
    this.lastSeen,
    this.isOnline = false,
    this.chatPreferences = const UserChatPreferences(),
  });

  String get fullName => '$firstName $lastName';

  String get displayPhotoUrl => photoUrl ?? defaultPhotoUrl;

  List<String> get archivedConvIds => chatPreferences.archivedConversations;

  factory User.fromMap(Map<String, dynamic> map) {
    final name = map['name'] as String?;
    String firstName = map['firstName'] ?? '';
    String lastName = map['lastName'] ?? '';

    // Handle legacy data where only 'name' field exists
    if (name != null && (firstName.isEmpty || lastName.isEmpty)) {
      final nameParts = name.split(' ');
      firstName = nameParts.first;
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }

    // Handle lastSeen field which can be Timestamp, DateTime, or null
    DateTime? lastSeen;
    final lastSeenData = map['lastSeen'];
    if (lastSeenData != null) {
      if (lastSeenData is Timestamp) {
        lastSeen = lastSeenData.toDate();
      } else if (lastSeenData is DateTime) {
        lastSeen = lastSeenData;
      } else if (lastSeenData is String) {
        lastSeen = DateTime.tryParse(lastSeenData);
      }
    }

    return User(
      id: map['id'],
      firstName: firstName,
      lastName: lastName,
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      lastSeen: lastSeen,
      isOnline: map['isOnline'] ?? false,
      chatPreferences: map['chatPreferences'] != null
          ? UserChatPreferences.fromMap(
              map['chatPreferences'] as Map<String, dynamic>)
          : const UserChatPreferences(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'photoUrl': photoUrl,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'isOnline': isOnline,
      'chatPreferences': chatPreferences.toMap(),
    };
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? photoUrl,
    DateTime? lastSeen,
    bool? isOnline,
    UserChatPreferences? chatPreferences,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      chatPreferences: chatPreferences ?? this.chatPreferences,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      firstName,
      lastName,
      email,
      photoUrl,
      lastSeen,
      isOnline,
      chatPreferences,
    ];
  }
}
