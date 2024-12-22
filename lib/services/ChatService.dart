import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Message.dart';
import '../models/user_model.dart';

class ChatService {
  static const String baseUrl = 'http://10.10.2.119:8080/api/chat';
  final Map<String, String> headers = {'Content-Type': 'application/json'};

  // Fetch user details by ID
  Future<User> getUserById(int userId) async {
    final url = '$baseUrl/users/$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch user details');
      }
    } catch (error) {
      throw Exception('Error fetching user details: $error');
    }
  }


  // Send a message
  Future<Message> sendMessage(
      int senderId, int receiverId, String content) async {
    final String url = '$baseUrl/send';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return Message.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to send message. Status Code: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error while sending message: $error');
    }
  }

  // Fetch conversations
  Future<List<User>> getConversationsByReservations(int userId) async {
    final String url = '$baseUrl/my-conversations/$userId';
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((data) => User.fromJson(data))
            .toList();
      } else {
        throw Exception('Failed to fetch conversations: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error fetching conversations: $error');
    }
  }

  // Fetch conversation messages
  Future<List<Message>> getConversation(int senderId, int receiverId) async {
    final String url =
        '$baseUrl/conversation?userId1=$senderId&userId2=$receiverId';
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((data) => Message.fromJson(data))
            .toList();
      } else {
        throw Exception('Failed to fetch conversation: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error fetching conversation: $error');
    }
  }
}
