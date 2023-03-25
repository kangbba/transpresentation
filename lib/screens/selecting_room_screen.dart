import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transpresentation/auth_provider.dart';
import 'package:transpresentation/screens/room_screen.dart';
import '../chat_provider.dart';
import '../chat_room.dart';
import '../helper/sayne_dialogs.dart';
import '../user_model.dart';
import 'changing_nickname_screen.dart';
import 'chatting_screen.dart';

class SelectingRoomScreen extends StatefulWidget {
  @override
  _SelectingRoomScreenState createState() => _SelectingRoomScreenState();
}

class _SelectingRoomScreenState extends State<SelectingRoomScreen> {
  final _chatProvider = ChatProvider.instance;
  final _authProvider = AuthProvider.instance;

  void _showChangeNicknameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ChangingNicknameScreen(),
        );
      },
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              UserModel userModel = UserModel.fromFirebaseUser(_authProvider.curUser!);
              final chatRoomRef = await _chatProvider.createChatRoom(
                'ChatRoom_${DateTime.now().millisecondsSinceEpoch}', userModel);

              final chatRoomSnapshot = await chatRoomRef.get();
              final chatRoom = ChatRoom.fromSnapshot(chatRoomSnapshot);

// ChatRoom.setHost 메서드를 호출하여 방의 호스트를 설정합니다.
              final isHostSet = await chatRoom.setHost(UserModel.fromFirebaseUser(_authProvider.curUser!));
              sayneToast("${_authProvider.curUser!.email} 의 방 만들기 ${isHostSet ? "성공" : "실패"}");

              if (isHostSet) {
                // 호스트 설정이 성공한 경우에만 참가를 시도합니다.
                final isJoined = _authProvider.curUser == null ? false : await chatRoom.joinRoom(userModel);
                sayneToast("${_authProvider.curUser!.email} 의 방 참가 ${isJoined ? "성공" : "실패"}");
              }


              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomScreen(chatRoom: chatRoom),
                ),
              );

            },
          ),
          IconButton(

            icon: Icon(Icons.edit),
            onPressed: () {
              _showChangeNicknameDialog();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chatRooms').snapshots(),
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

              UserModel userModel = UserModel.fromFirebaseUser(_authProvider.curUser!);
              return ListTile(
                title: Text(chatRoom.name),
                subtitle: Text(chatRoom.createdAt.toString()),
                onTap: () async{
                  final isJoined = _authProvider.curUser == null ? false : await chatRoom.joinRoom(UserModel.fromFirebaseUser(_authProvider.curUser!));
                  sayneToast("${_authProvider.curUser!.email} 의 방 참가 ${isJoined ? "성공" : "실패"}");

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