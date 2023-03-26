import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transpresentation/auth_provider.dart';
import 'package:transpresentation/room_screens/room_screen.dart';
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
    return WillPopScope(
      onWillPop: () async {
        // 뒤로 가기 버튼이 눌렸을 때의 동작을 작성합니다.
        return false; // 뒤로 가기 버튼을 무시합니다.
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading : false,
          title: Text('Chat Rooms'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                UserModel userModel = UserModel.fromFirebaseUser(_authProvider.curUser!);
                sayneLoadingDialog(context, "방 생성중");
                final chatRoom = await _chatProvider.createChatRoom(
                    'ChatRoom_${DateTime.now().millisecondsSinceEpoch}',
                    userModel
                );
                Navigator.pop(context);
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
                    final isJoined = _authProvider.curUser == null ? false : await chatRoom.joinRoom(userModel);
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
      ),
    );
  }
}