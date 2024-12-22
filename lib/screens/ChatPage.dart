import 'package:flutter/material.dart';
import '../models/Message.dart';
import '../services/ChatService.dart';

class ChatPage extends StatefulWidget {
  final int senderId; // Sender ID
  final int receiverId; // Receiver ID
  final String receiverName; // Receiver Name

  const ChatPage({
    Key? key,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);

    try {
      final messages = await _chatService.getConversation(
        widget.senderId,
        widget.receiverId,
      );

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      // Scroll to the bottom after messages are loaded
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $error')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    try {
      final newMessage = await _chatService.sendMessage(
        widget.senderId,
        widget.receiverId,
        content,
      );

      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
      });

      // Scroll to the bottom to show the latest message
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $error')),
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
      body: Column(
        children: [
          // Title for the chat
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Chat ${widget.receiverName}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'No messages yet.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isSentByUser =
                              message.senderId == widget.senderId;

                          return Align(
                            alignment: isSentByUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: isSentByUser
                                    ? Colors.blue[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(message.content),
                            ),
                          );
                        },
                      ),
          ),
          // Message input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
