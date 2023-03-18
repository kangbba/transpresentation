import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'chat_provider.dart';
import 'main_screen.dart';

class ChattingScreen extends StatelessWidget {

  ChattingScreen({super.key, required this.chatRoom});

  final ChatRoom chatRoom;
  final currentUser = AuthProvider.instance.curUserCredential?.user;
  final chatProvider = ChatProvider.instance;
  final TextEditingController _textController = TextEditingController();



  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      await chatProvider.sendMessage('chatRoomId', message, 'senderId');
      _textController.clear();
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(chatRoom.name),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatProvider.getRecentMessages(chatRoom.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ListTile(
                        title: Text(message.text),
                        subtitle: Text(
                            '${message.senderId} - ${message.createdAt}'),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
