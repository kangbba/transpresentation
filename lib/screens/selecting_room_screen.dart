import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transpresentation/classes/auth_provider.dart';
import 'package:transpresentation/room_screens/room_screen.dart';
import '../classes/chat_provider.dart';
import '../classes/chat_room.dart';
import '../helper/sayne_dialogs.dart';
import '../classes/user_model.dart';
import '../room_screens/profile_circle.dart';
import 'changing_nickname_screen.dart';
import '../testing/chatting_screen.dart';

class SelectingRoomScreen extends StatefulWidget {
  @override
  _SelectingRoomScreenState createState() => _SelectingRoomScreenState();
}

class _SelectingRoomScreenState extends State<SelectingRoomScreen> {
  final _chatProvider = ChatProvider.instance;
  final _authProvider = AuthProvider.instance;

  void _showChangeNicknameDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ChangingNicknameScreen(),
        );
      },
      barrierDismissible: false,
    );
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomScreen(chatRoomToLoad: null,),
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
            if (!snapshot.hasData) {
              return Container();
            }

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

            final chatRooms = snapshot.data!.docs.map((doc) => ChatRoom.fromFirebaseSnapshot(doc)).toList();
            return ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];
                return ListTile(
                  title: Text(chatRoom.name),
                  leading: ProfileCircle(userModel: chatRoom.host),
                  subtitle: Text(chatRoom.host.email),
                  onTap: () async{
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomScreen(chatRoomToLoad: chatRoom,),
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