import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? photoUrl;
  final DateTime? lastSeen;
  final bool isOnline;

  static const String defaultPhotoUrl = 'assets/images/anon-user.png';

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photoUrl,
    this.lastSeen,
    this.isOnline = false,
  });

  String get fullName => '$firstName $lastName';

  String get displayPhotoUrl => photoUrl ?? defaultPhotoUrl;

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
    };
  }

  @override
  List<Object?> get props {
    return [id, firstName, lastName, email, photoUrl, lastSeen, isOnline];
  }
}
