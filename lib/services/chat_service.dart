import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/chat_model.dart';

class ChatService {
  static const String _tokenKey = 'auth_token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Create or get a private chat with another user
  Future<Chat?> createOrGetPrivateChat(int otherUserId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No auth token found');
        return null;
      }

      final response = await http.post(
        Uri.parse(ApiConstants.chatUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'type': 'private',
          'participant_ids': [otherUserId],
        }),
      );

      print('Create chat response: ${response.statusCode}');
      print('Create chat body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['chat'] != null) {
          return Chat.fromJson(data['chat']);
        }
      }

      return null;
    } catch (e) {
      print('Error creating chat: $e');
      return null;
    }
  }

  /// Get all chats for the current user
  Future<List<Chat>> getChats({int limit = 50, int offset = 0}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No auth token found');
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.chatUrl}?limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Get chats response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['chats'] != null) {
          return (data['chats'] as List)
              .map((chat) => Chat.fromJson(chat))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error getting chats: $e');
      return [];
    }
  }

  /// Get a specific chat by ID
  Future<Chat?> getChatById(int chatId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse(ApiConstants.chatDetailUrl(chatId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Get chat response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['chat'] != null) {
          return Chat.fromJson(data['chat']);
        }
      }

      return null;
    } catch (e) {
      print('Error getting chat: $e');
      return null;
    }
  }

  /// Get messages for a chat
  Future<List<Message>> getMessages(int chatId, {int limit = 50, int offset = 0}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No auth token found');
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.chatMessagesUrl(chatId)}?limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Get messages response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['messages'] != null) {
          return (data['messages'] as List)
              .map((msg) => Message.fromJson(msg))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  /// Send a text message
  Future<Message?> sendTextMessage(int chatId, String content) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No auth token found');
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.chatMessagesUrl(chatId)),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['content'] = content;
      request.fields['message_type'] = 'text';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Send message response: ${response.statusCode}');
      print('Send message body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return Message.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  /// Send a photo message
  Future<Message?> sendPhotoMessage(int chatId, List<String> photoPaths, {String? caption}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No auth token found');
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.chatMessagesUrl(chatId)),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['message_type'] = 'photo';
      if (caption != null && caption.isNotEmpty) {
        request.fields['content'] = caption;
      }

      // Add photo files
      for (final photoPath in photoPaths) {
        request.files.add(await http.MultipartFile.fromPath('media', photoPath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Send photo message response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return Message.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      print('Error sending photo message: $e');
      return null;
    }
  }

  /// Mark all messages in a chat as seen
  Future<bool> markMessagesAsSeen(int chatId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No auth token found');
        return false;
      }

      final response = await http.put(
        Uri.parse(ApiConstants.chatMessagesSeenUrl(chatId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Mark messages seen response: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking messages as seen: $e');
      return false;
    }
  }
}
