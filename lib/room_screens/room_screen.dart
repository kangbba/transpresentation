import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import 'package:transpresentation/room_screens/presenter_screen.dart';
import 'package:transpresentation/room_screens/profile_circle.dart';
import 'package:transpresentation/screens/selecting_room_screen.dart';

import '../classes/auth_provider.dart';
import '../classes/chat_provider.dart';
import '../classes/chat_room.dart';
import '../classes/user_model.dart';
import 'audience_screen.dart';
import '../screens/room_displayer.dart';
class RoomScreen extends StatefulWidget {
  RoomScreen({Key? key, required this.chatRoomToLoad}) : super(key: key);
  ChatRoom? chatRoomToLoad;
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _authProvider = AuthProvider.instance;
  final _chatProvider = ChatProvider.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ChatRoom? chatRoom;
  bool isRoomDisplayerOpen = false;
  Stream<UserModel>? _hostStream;

  initializeChatRoom() async {
    UserModel userModel = UserModel.fromFirebaseUser(_authProvider.curUser!);

    if(widget.chatRoomToLoad == null)
    {
      print("새로운 방 생성");
      chatRoom = await _chatProvider.createChatRoom(
          '',
          userModel
      );
    }
    else{
      print("기존 방 입장");
      final isJoined = await widget.chatRoomToLoad!.joinRoom(userModel);
      sayneToast("방 로드 ${isJoined ? "성공" : "실패"}");
      chatRoom = isJoined ? widget.chatRoomToLoad : null;
    }
    setState(() {

    });
    // chatRoom이 null이면 이전 화면으로 돌아갑니다.
    if (chatRoom == null) {
        await sayneConfirmDialog(context, "" , "방 로드 실패");
       Navigator.pop(context);
    }
    else{
      _hostStream = chatRoom!.hostStream();
    }


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeChatRoom();
  }
  @override
  Widget build(BuildContext context) {
    if (chatRoom == null) {
      return loading();
    }
    return MultiProvider(
      providers: [
        StreamProvider<List<dynamic>>(
          create: (_) => chatRoom!.membersStream,
          initialData: [],
        ),
        StreamProvider<UserModel>(
          create: (_) => _hostStream,
          initialData: chatRoom!.host,
        ),
      ],
      child: Consumer2<List<dynamic>, UserModel>(
        builder: (_, membersSnapshot, hostUserModel, __) {
          if (membersSnapshot.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: Text(chatRoom!.name),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          UserModel curUserModel = UserModel.fromFirebaseUser(_authProvider.curUser!);
          final isCurUserHost = hostUserModel.uid == curUserModel.uid;

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
                title: Text(chatRoom!.name),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () => _onPressedExitRoom(context),
                  ),
                ],
              ),
              body: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("발표자"),
                    ),
                  ),
                  _memberListTile(
                    context,
                    hostUserModel,
                    curUserModel.uid,
                    hostUserModel.uid,
                  ),
                  Expanded(
                    child: isCurUserHost
                        ? PresenterScreen(chatRoom: chatRoom!)
                        : AudienceScreen(chatRoom: chatRoom!),
                  ),
                  SizedBox(
                    height: 100,
                    child: roomDisplayerBtn(context),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InkWell roomDisplayerBtn(BuildContext context) {
    return InkWell(
                  child: Icon(Icons.account_box_sharp),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 400,
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                width: 60,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              RoomDisplayer(chatRoom: chatRoom!),
                            ],
                          ),
                        );
                      },
                    );
                  });
  }

  Scaffold loading() {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방'),
      ),
      body: Center(
        child: Text('채팅방을 불러오는 중입니다.'),
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
      leading: ProfileCircle(userModel: userModel,),
      title: Text(email.split('@')[0] + (isCurUser ? " (나)" : "")),
      subtitle: Text(email),
    );
  }
  _onPressedExitRoom(BuildContext context) async{
    UserModel user = UserModel.fromFirebaseUser(_authProvider.curUser!);
    Navigator.pop(context);
    final result = await chatRoom!.exitRoom(user!);
    final roomId = chatRoom!.id;
    final roomName = chatRoom!.name;
    // Show a confirmation dialog to the user
  }

}
