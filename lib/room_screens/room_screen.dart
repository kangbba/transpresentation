import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import 'package:transpresentation/room_screens/presenter_screen.dart';
import 'package:transpresentation/screens/selecting_room_screen.dart';

import '../classes/auth_provider.dart';
import '../classes/chat_provider.dart';
import '../classes/chat_room.dart';
import '../classes/user_model.dart';
import 'audience_screen.dart';
import '../screens/room_displayer.dart';
class RoomScreen extends StatefulWidget {
  RoomScreen({super.key, required this.chatRoom});

  final ChatRoom chatRoom;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _authProvider = AuthProvider.instance;
  final _chatProvider = ChatProvider.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
          Navigator.of(context).pop();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.chatRoom.name),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () => _onPressedExitRoom(context),
            ),
          ],
        ),
        endDrawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                Text("대화상대", textAlign: TextAlign.start,),
                Expanded(child: RoomDisplayer(chatRoom: widget.chatRoom)),
              ],
            ),
          ),
        ),
        body: MultiProvider(
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
              if (membersSnapshot.isEmpty || hostSnapshot == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final hostUserModel = hostSnapshot!;
                final curUserModel = UserModel.fromFirebaseUser(_authProvider.curUser!);
                final isCurUserHost = hostUserModel.uid == curUserModel.uid;
                return Column(
                  children: [
                    SizedBox(
                        height : 50, child: Align(alignment: Alignment.centerLeft, child: Text("발표자"))),
                    _memberListTile(context, hostUserModel, curUserModel.uid, hostUserModel.uid),
                    Expanded(child:  isCurUserHost ? PresenterScreen(chatRoom: widget.chatRoom,) : AudienceScreen(chatRoom: widget.chatRoom)),
                    SizedBox(
                      height: 50,
                      child: ListTile(
                        leading: Icon(Icons.account_box_sharp),
                        title: Text("청취자 ${membersSnapshot.length - 1}명"),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
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
      leading: CircleAvatar(
        backgroundImage: photoURL != null
            ? NetworkImage(photoURL) as ImageProvider<Object>
            : const AssetImage('assets/images/default_icon.png'),
      ),
      title: Text(email.split('@')[0] + (isCurUser ? " (나)" : "")),
      subtitle: Text(email),
    );
  }
  _onPressedExitRoom(BuildContext context) async{
    UserModel user = UserModel.fromFirebaseUser(_authProvider.curUser!);
    Navigator.pop(context);
    final result = await widget.chatRoom.exitRoom(user!);
    final roomId = widget.chatRoom.id;
    final roomName = widget.chatRoom.name;
    // Show a confirmation dialog to the user
  }

}
