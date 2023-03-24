import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';
import '../chat_provider.dart';

class ChattingScreen extends StatelessWidget {

  ChattingScreen({super.key, required this.chatRoom});

  final ChatRoom chatRoom;
  final authProvider = AuthProvider.instance;
  final chatProvider = ChatProvider.instance;
  final TextEditingController _textController = TextEditingController();



  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      await chatProvider.sendMessage(chatRoom.id, message, authProvider.curUserCredential!);
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
                      return messageListTile(message, message.senderId == authProvider.curUserCredential!.user!.uid);
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

  Widget messageListTile(Message message, bool isMine) {
    return Padding(
      padding: const EdgeInsets.only(right: 32.0),
      child: ListTile(
        subtitle: Text('${message.senderEmail}'),
        title: Text(message.text),
        trailing: Text(
            '${message.createdAt.toString().split(' ')[1].split(':')[0]}'+
            ':${message.createdAt.toString().split(' ')[1].split(':')[1]}'),
        // subtitle: Text(
        //     '${message.senderId} - ${message.createdAt}'),
      ),
    );
  }
}
