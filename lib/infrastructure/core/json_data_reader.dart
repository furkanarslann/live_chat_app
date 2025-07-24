import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/chat_conversation.dart';
import '../../domain/models/chat_message.dart';

class JsonDataReader {
  static Future<Map<String, dynamic>> _readJsonFile(String path) async {
    final jsonString = await rootBundle.loadString(path);
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  static Future<List<ChatConversation>> loadConversations() async {
    final data = await _readJsonFile('assets/data/conversations.json');
    final List<dynamic> conversationsJson = data['conversations'];
    
    return conversationsJson.map((json) {
      final lastMessageJson = json['lastMessage'];
      final lastMessage = lastMessageJson != null
          ? ChatMessage(
              id: lastMessageJson['id'],
              senderId: lastMessageJson['senderId'],
              receiverId: lastMessageJson['receiverId'],
              content: lastMessageJson['content'],
              timestamp: DateTime.parse(lastMessageJson['timestamp']),
              isRead: lastMessageJson['isRead'] ?? false,
            )
          : null;

      return ChatConversation(
        id: json['id'],
        participantId: json['participantId'],
        participantName: json['participantName'],
        participantAvatar: json['participantAvatar'],
        unreadCount: json['unreadCount'],
        isOnline: json['isOnline'],
        lastMessage: lastMessage,
      );
    }).toList();
  }

  static Future<Map<String, List<ChatMessage>>> loadMessages() async {
    final data = await _readJsonFile('assets/data/messages.json');
    final Map<String, dynamic> messagesJson = data['messages'];
    
    return messagesJson.map(
      (key, value) => MapEntry(
        key,
        (value as List)
            .map((messageJson) => ChatMessage(
                  id: messageJson['id'],
                  senderId: messageJson['senderId'],
                  receiverId: messageJson['receiverId'],
                  content: messageJson['content'],
                  timestamp: DateTime.parse(messageJson['timestamp']),
                  isRead: messageJson['isRead'] ?? false,
                ))
            .toList(),
      ),
    );
  }
} 