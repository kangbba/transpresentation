import 'package:flutter/material.dart';

import '../chat_provider.dart';

class RoomDisplayer extends StatefulWidget {
  final ChatRoom chatRoom;

  const RoomDisplayer({required this.chatRoom, Key? key}) : super(key: key);

  @override
  State<RoomDisplayer> createState() => _RoomDisplayerState();
}

class _RoomDisplayerState extends State<RoomDisplayer> {
  late Stream<List<dynamic>> _membersStream;

  @override
  void initState() {
    super.initState();
    _membersStream = widget.chatRoom.membersStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: _membersStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final members = snapshot.data!;

        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index] as Map<String, dynamic>;
            final userEmail = member['userEmail'] as String;


            return ListTile(
              title: Text(userEmail),
            );
          },
        );
      },
    );
  }
}
