import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/classes/auth_provider.dart';

import '../classes/chat_room.dart';
import '../classes/user_model.dart';

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
        StreamProvider<UserModel?>(
          create: (_) => widget.chatRoom.hostStream,
          initialData: null,
        ),
        StreamProvider<List<dynamic>>(
          create: (_) => widget.chatRoom.membersStream,
          initialData: [],
        ),
      ],
      child: Consumer2<UserModel?, List<dynamic>>(
        builder: (_, hostSnapshot, membersSnapshot, __) {
// 예외 처리
          if (membersSnapshot.isEmpty || hostSnapshot == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final members = membersSnapshot;
          final curUserModel = UserModel.fromFirebaseUser( _authProvider.curUser!);
          final curUserUid = curUserModel.uid;
          final hostUserUid = hostSnapshot.uid;
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final UserModel userModel = UserModel.fromMap(member);

              // //
              // final uid = member['uid'];
              // final displayName = member['displayName'];
              // final email = member['email'];
              // final photoURL = member['photoURL'] as String?;
              // final isHost = uid == hostSnapshot.uid;

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
              leading: CircleAvatar(
                backgroundImage: photoURL != null
                    ? NetworkImage(photoURL) as ImageProvider<Object>
                    : const AssetImage('assets/images/default_icon.png'),
              ),
              title: Text(email.split('@')[0] + (isCurUser ? " (나)" : "")),
              subtitle: Text(email),
              trailing: isHost
                  ? const Text(
                '발표자',
                style: TextStyle(color: Colors.red),
              )  : null,
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

    bool success = await widget.chatRoom.setHost(user);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 호스트로 설정되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 호스트 설정에 실패했습니다.')),
      );
    }
  }



}