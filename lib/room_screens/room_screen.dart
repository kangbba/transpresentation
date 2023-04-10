import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/helper/colors.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import 'package:transpresentation/room_screens/presenter_page.dart';
import 'package:transpresentation/room_screens/profile_circle.dart';

import '../classes/auth_provider.dart';
import '../classes/chat_provider.dart';
import '../classes/chat_room.dart';
import '../classes/language_select_control.dart';
import '../classes/user_model.dart';
import '../helper/sayne_separator.dart';
import '../screens/language_select_screen.dart';
import 'audience_page.dart';
import '../screens/room_displayer.dart';
class RoomScreen extends StatefulWidget {
  RoomScreen({Key? key, required this.chatRoomToLoad}) : super(key: key);
  ChatRoom chatRoomToLoad;
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _authProvider = AuthProvider.instance;
  final _chatProvider = ChatProvider.instance;
  final LanguageSelectControl _languageSelectControl = LanguageSelectControl.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ChatRoom? chatRoom;
  bool isRoomDisplayerOpen = false;
  Stream<UserModel>? _hostStream;
  initializeChatRoom() async {
    UserModel userModel = UserModel.fromFirebaseUser(_authProvider.curUser!);

    //참가 처리
    final isJoined = await widget.chatRoomToLoad!.joinRoom(userModel);
    sayneToast("방 로드 ${isJoined ? "성공" : "실패"}");
    chatRoom = isJoined ? widget.chatRoomToLoad : null;
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

    setState(() {

    });

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
        ListenableProvider<LanguageSelectControl>(
          create: (_) => _languageSelectControl,
        ),
      ],
      child: Consumer2<List<dynamic>, UserModel>(
        builder: (_, membersSnapshot, hostUserModel, __) {
          if (membersSnapshot.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: ColorManager.color_standard,
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
                backgroundColor: ColorManager.color_standard,
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
                      height: 80,
                      child: Column(
                        children:
                        [
                          _memberListTile(context, hostUserModel, curUserModel.uid, hostUserModel.uid, ),
                          const SayneSeparator(color: Colors.black54, height: 0.3, top: 0, bottom: 0),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Container(
                        child :isCurUserHost
                          ? PresenterPage(chatRoom: chatRoom!, languageSelectControl: _languageSelectControl,)
                          : AudiencePage(chatRoom: chatRoom!)!,
                      )
                    ),

                    SizedBox(
                      height: 80,
                      child: Column(
                        children: [
                          const SayneSeparator(color: Colors.black54, height: 0.3, top: 0, bottom: 16),
                          languageSelectScreenBtn(isCurUserHost),
                        ],
                      ),
                    )
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
                    SayneSeparator(color: Colors.black, height: 0, top: 8, bottom: 8),
                    Text(chatRoom!.name, style: TextStyle(fontSize: 16),),
                    SayneSeparator(color: Colors.black, height: 0.2, top: 8, bottom: 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(children: const [
                        Icon(Icons.people, color: Colors.black45,),
                        Text(" 참여자" ,style: TextStyle(fontSize: 15),
                        )]
                      ),
                    ),
                    SizedBox(height: 8,),
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
  Scaffold loading() {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: ColorManager.color_standard,
      ),

      body: Center(
        child: Text(''),
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
      leading: ProfileCircle(userModel: userModel, radius: 20,),
      title: Text('<발표자> ${userModel.displayName}', style: TextStyle(color: Colors.black, fontSize: 17),),
      subtitle: Text((email)),
      trailing: Text(isCurUser ? " (나)" : ""),
    );
  }
  _onPressedExitRoom(BuildContext context) async{
    bool? confirmation = await sayneAskDialog(context, "", "이 채팅방에서 나가시겠습니까?");
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

  Widget languageSelectScreenBtn(bool isHost) {
    return Consumer<LanguageSelectControl>(
      builder: (context, languageSelectControl, child) {
        return Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {
              late LanguageSelectScreen myLanguageSelectScreen =
              LanguageSelectScreen(
                isHost: isHost,
                languageSelectControl: languageSelectControl,
              );
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16.0),
                      child: myLanguageSelectScreen,
                    ),
                  );
                },
              );
              setState(() {
              });
            },
            child: SizedBox(
              height: 60,
              child: Column(
                children: [
                  Text("   ${languageSelectControl.myLanguageItem.menuDisplayStr} 으로 ${isHost ? '발표 하는 중' : '보는중'}"),
                  SizedBox(height: 10,),
                  Text( "   번역 언어 변경하기   ", textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
