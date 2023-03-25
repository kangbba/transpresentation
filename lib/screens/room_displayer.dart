import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../chat_room.dart';
import '../user_model.dart';

class RoomDisplayer extends StatefulWidget {
  const RoomDisplayer({required this.chatRoom, Key? key}) : super(key: key);

  final ChatRoom chatRoom;

  @override
  State<RoomDisplayer> createState() => _RoomDisplayerState();
}

class _RoomDisplayerState extends State<RoomDisplayer> {
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

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final UserModel userModel = UserModel.fromMap(member);

              final uid = userModel.uid;
              final displayName = userModel.displayName;
              final email = userModel.email;
              final photoURL = userModel.photoURL;
              final isHost = uid == hostSnapshot.uid;
              // //
              // final uid = member['uid'];
              // final displayName = member['displayName'];
              // final email = member['email'];
              // final photoURL = member['photoURL'] as String?;
              // final isHost = uid == hostSnapshot.uid;

              return ListTile(
                onTap: (){
                //  onTapListTile(context);
                },
                leading: CircleAvatar(
                  backgroundImage: photoURL != null
                      ? NetworkImage(photoURL) as ImageProvider<Object>
                      : const AssetImage('assets/images/default_icon.png'),
                ),
                title: Text(email),
                subtitle: Text(uid),
                trailing: isHost
                    ? const Text(
                  '발표자',
                  style: TextStyle(color: Colors.red),
                )


                    : null,
              );
            },
          );
        },
      ),
    );
  }
  // void onTapListTile(BuildContext context, UserModel user) async {
  //
  //   bool success = await widget.chatRoom.setHost(user);
  //   if (success) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('새 호스트로 설정되었습니다.')),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('새 호스트 설정에 실패했습니다.')),
  //     );
  //   }
  // }



}