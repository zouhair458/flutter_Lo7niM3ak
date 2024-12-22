import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/ChatService.dart';
import 'ChatPage.dart';

class MyConversationsPage extends StatefulWidget {
  final int userId;

  const MyConversationsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MyConversationsPageState createState() => _MyConversationsPageState();
}

class _MyConversationsPageState extends State<MyConversationsPage> {
  final ChatService _chatService = ChatService();
  List<User> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() => _isLoading = true);

    try {
      final conversations =
          await _chatService.getConversationsByReservations(widget.userId);

      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load conversations: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? const Center(
                  child: Text(
                    'No conversations found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'My Conversations',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            final user = _conversations[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child:
                                      Icon(Icons.person, color: Colors.white),
                                ),
                                title:
                                    Text('${user.firstName} ${user.lastName}'),
                                subtitle: Text(user.email),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        senderId: widget.userId,
                                        receiverId: user.id,
                                        receiverName:
                                            '${user.firstName} ${user.lastName}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
