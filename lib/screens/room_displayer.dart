import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/classes/auth_provider.dart';

import '../classes/chat_room.dart';
import '../classes/user_model.dart';
import '../room_screens/profile_circle.dart';

class RoomDisplayer extends StatefulWidget {
  const RoomDisplayer({required this.chatRoom, Key? key}) : super(key: key);

  final ChatRoom chatRoom;

  @override
  State<RoomDisplayer> createState() => _RoomDisplayerState();
}

class _RoomDisplayerState extends State<RoomDisplayer> {
  AuthProvider _authProvider = AuthProvider.instance;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<dynamic>>(
          create: (_) => widget.chatRoom.membersStream,
          initialData: [],
        ),
      ],
      child: Consumer<List<dynamic>>(
        builder: (_, membersSnapshot, __) {
// 예외 처리
          if (membersSnapshot.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final members = membersSnapshot;
          final curUserModel = UserModel.fromFirebaseUser( _authProvider.curUser!);
          final curUserUid = curUserModel.uid;
          final hostUserUid = widget.chatRoom.host.uid;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final UserModel userModel = UserModel.fromMap(member);
              return _memberListTile(context, userModel, curUserUid, hostUserUid);
            },
          );
        },
      ),
    );
  }

  ListTile _memberListTile(BuildContext context, UserModel userModel, String curUserUid, String hostUserUid) {
    final uid = userModel.uid;
    final displayName = userModel.displayName;
    final isMe = userModel.uid == curUserUid;
    final isCurUser = userModel.uid == curUserUid;
    final isCurUserHost = curUserUid == hostUserUid;
    final isHost = userModel.uid == hostUserUid;
    final email = userModel.email;
    final photoURL = userModel.photoURL;
    return ListTile(
              onTap: (){
                if(!isCurUser) {
                  showContextMenu(context, userModel, isCurUserHost && !isCurUser);
                }
              },
              leading: Column(
                children: [
                  ProfileCircle(userModel: userModel),
                ],
              ),
              title:  Text(displayName + (isMe ? " (나)" : "")),
              subtitle: Text(email),
              trailing: isHost ? Text("발표자") : null,
            );
  }
  void showContextMenu(BuildContext context, UserModel user, bool useManagementFunction) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final List<PopupMenuEntry<String>> menuItems = [
      if (useManagementFunction)
        PopupMenuItem(
          value: 'setHost',
          child: Text('호스트 위임하기'),
        ),

      PopupMenuItem<String>(
        value: 'whisper',
        child: const Text('귓속말'),
      ),
    ];

    // Show the context menu and wait for a selection.
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        const Rect.fromLTWH(0, 0, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: menuItems,
    ).then((String? value) {
      // Handle the selected menu item.
      if (value == 'setHost') {
        onTapListTile(context, user);
      }
    });
  }
  void onTapListTile(BuildContext context, UserModel user) async {
     widget.chatRoom.setHost(user);
  }



}
