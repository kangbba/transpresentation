import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';

import '../auth_provider.dart';
import '../chat_provider.dart';
import '../chat_room.dart';
import '../user_model.dart';
import 'room_displayer.dart';

class RoomScreen extends StatelessWidget {

  RoomScreen({super.key, required this.chatRoom});

  final ChatRoom chatRoom;
  final authProvider = AuthProvider.instance;
  final chatProvider = ChatProvider.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(chatRoom.name),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RoomDisplayer(chatRoom: chatRoom,),
        )
      ),
    );
  }

  Future<bool> _onBackPressed() async{
    UserModel user = UserModel.fromFirebaseUser(authProvider.curUser!);
    final result = await chatRoom.exitRoom(user!, );
    if (!result) {
      sayneToast("나가기 실패");
      return false;
    }
    return true;
  }
}
