import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:transpresentation/classes/auth_provider.dart';

import '../classes/chat_room.dart';
import '../classes/user_model.dart';
import '../room_screens/profile_circle.dart';
import '../room_screens/room_screen.dart';

class RoomSelectingPage extends StatefulWidget {
  const RoomSelectingPage({Key? key}) : super(key: key);

  @override
  State<RoomSelectingPage> createState() => _RoomSelectingPageState();
}

class _RoomSelectingPageState extends State<RoomSelectingPage> {
  final _authProvider = AuthProvider.instance;
  // CachedQueryFirebaseFirestore 인스턴스 생성
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(


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
            return Slidable(
              key: Key(chatRoom.id),
              child: ListTile(
                title: Text(chatRoom.name),
                leading: ProfileCircle(userModel: chatRoom.host),
                subtitle: Text(chatRoom.host.email),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomScreen(chatRoomToLoad: chatRoom,),
                    ),
                  );
                },
              ),
              endActionPane: ActionPane(
                extentRatio: 0.2,
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      chatRoom.exitRoom(UserModel.fromFirebaseUser(_authProvider.curUser!));
                    },
                    backgroundColor: Colors.red,
                    icon: Icons.delete,
                    label: '삭제',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
