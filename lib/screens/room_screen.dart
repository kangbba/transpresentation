import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';
import '../chat_provider.dart';
import 'room_displayer.dart';

class RoomScreen extends StatelessWidget {

  RoomScreen({super.key, required this.chatRoom});

  final ChatRoom chatRoom;
  final authProvider = AuthProvider.instance;
  final chatProvider = ChatProvider.instance;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(chatRoom.name),
      ),
      body: Column(
        children: [
          RoomDisplayer(chatRoom: chatRoom,),
          // other widgets
        ],
      ),
    );
  }
}
