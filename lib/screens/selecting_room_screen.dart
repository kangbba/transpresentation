
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transpresentation/auth_provider.dart';
import 'package:transpresentation/screens/room_screen.dart';
import '../chat_provider.dart';
import '../helper/sayne_dialogs.dart';
import 'chatting_screen.dart';

class SelectingRoomScreen extends StatefulWidget {
  @override
  _SelectingRoomScreenState createState() => _SelectingRoomScreenState();
}

class _SelectingRoomScreenState extends State<SelectingRoomScreen> {
  final _chatProvider = ChatProvider.instance;
  final _authProvider = AuthProvider.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final chatRoomRef = await _chatProvider.createChatRoom(
                'ChatRoom_${DateTime.now().millisecondsSinceEpoch}',
              );
              final chatRoom = ChatRoom.fromReference(chatRoomRef);
              final isJoined = _authProvider.curUser == null ? false : await chatRoom.joinRoom(_authProvider.curUser!.email!);

              sayneToast("방 참가 ${isJoined ? "성공" : "실패"}");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomScreen(chatRoom: ChatRoom.fromReference(chatRoomRef)),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final chatRooms = snapshot.data!.docs.map((doc) => ChatRoom.fromSnapshot(doc)).toList();

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];

              return ListTile(
                title: Text(chatRoom.name),
                subtitle: Text(chatRoom.createdAt.toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomScreen(chatRoom: chatRoom,),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
