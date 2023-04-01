import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import 'package:transpresentation/room_screens/presenter_page.dart';
import 'package:transpresentation/room_screens/profile_circle.dart';
import 'package:transpresentation/screens/main_screen.dart';
import 'package:transpresentation/screens/room_selecting_page.dart';

import '../classes/auth_provider.dart';
import '../classes/chat_provider.dart';
import '../classes/chat_room.dart';
import '../classes/user_model.dart';
import '../helper/sayne_separator.dart';
import 'audience_page.dart';
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
                  onPressed: () => onBackPressed(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
              endDrawer: roomDrawer(context),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                      child: Align(alignment: Alignment.centerLeft, child: Text("  발표자", textAlign: TextAlign.left, style: TextStyle(fontSize: 16),)),
                    ),
                    _memberListTile(
                      context,
                      hostUserModel,
                      curUserModel.uid,
                      hostUserModel.uid,
                    ),
                    const SayneSeparator(color: Colors.black54, height: 0.3, top: 0, bottom: 0),
                    Expanded(
                      child: isCurUserHost
                          ? PresenterPage(chatRoom: chatRoom!)
                          : AudiencePage(chatRoom: chatRoom!),
                    ),
                    const SayneSeparator(color: Colors.black54, height: 0, top: 0, bottom: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget roomDrawer(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // 스크롤 가능한 리스트뷰 내용
                    SizedBox(height: 40, child: ListTile(leading: Text(" 참여자" ,style: TextStyle(fontSize: 15),))),
                    RoomDisplayer(chatRoom: chatRoom!),
                    SayneSeparator(color: Colors.black54, height: 0.3, top: 8, bottom: 8),
                    // ...
                  ],
                ),
              ),
            ),
            // 고정된 ListTile
            ListTile(
              tileColor: Colors.black12,
              leading: Icon(Icons.exit_to_app),
              title: Text("Exit Room"),
              onTap: () => _onPressedExitRoom(context),
            ),
          ],
        ),
      ),
    );
  }


  void onBackPressed(BuildContext context){
    Navigator.pop(context);

  }

  InkWell roomDisplayerBtn(BuildContext context) {
    return InkWell(
                  child: Icon(Icons.person, color: Colors.cyan, size: 30,),
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


  Widget _memberListTile(BuildContext context, UserModel userModel, String curUserUid, String hostUserUid) {
    final uid = userModel.uid;
    final displayName = userModel.displayName;

    final isCurUser = userModel.uid == curUserUid;
    final isCurUserHost = curUserUid == hostUserUid;
    final isHost = userModel.uid == hostUserUid;
    final email = userModel.email;
    final photoURL = userModel.photoURL;
    return ListTile(
      leading: ProfileCircle(userModel: userModel,),
      title: Text('${userModel.displayName}'),
      subtitle: Text((email)),
      trailing: Text(isCurUser ? " (나)" : ""),
    );
  }
  _onPressedExitRoom(BuildContext context) async{
    bool? confirmation = await sayneConfirmDialog(context, "", "이 채팅방에서 나가시겠습니까?");
    UserModel user = UserModel.fromFirebaseUser(_authProvider.curUser!);
    final result = await chatRoom!.exitRoom(user!);
    final roomId = chatRoom!.id;
    final roomName = chatRoom!.name;
    // Show a confirmation dialog to the user
    if(confirmation == true){
      await chatRoom!.exitRoom(user);
      onBackPressed(context);
    }
  }

}
