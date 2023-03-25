import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../chat_provider.dart';
import '../chat_room.dart';

class RoomDisplayer extends StatelessWidget {
  const RoomDisplayer({required this.chatRoom, Key? key}) : super(key: key);

  final ChatRoom chatRoom;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: chatRoom,
      child: Consumer<ChatRoom>(
        builder: (context, chatRoom, _) {
          return StreamBuilder<List<dynamic>>(
            stream: chatRoom.membersStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final members = snapshot.data!;
              return ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  final uid = member['uid'];
                  final email = member['email'];
                  final photoURL = member['photoURL'] as String?;

                  final isHost = chatRoom.host.uid == uid;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: photoURL != null
                          ? NetworkImage(photoURL) as ImageProvider<Object>
                          : const AssetImage('assets/images/default_icon.png'),
                    ),
                    title: Text(email),
                    subtitle: Text(uid),
                    trailing:
                    isHost ? const Text('Host', style: TextStyle(color: Colors.red)) : null,
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
