import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/custom_widget/sayne_dialogs.dart';
import 'package:transpresentation/helper/colors.dart';
import 'package:transpresentation/managers/network_checking_service.dart';
import 'package:transpresentation/screen_pages/room_selecting_page.dart';

import '../managers/auth_provider.dart';
import '../managers/chat_provider.dart';
import '../classes/chat_room.dart';
import '../screen_pages/translation_page.dart';
import 'room_screen.dart';
import '../screen_pages/room_title_setting_page.dart';
import '../screen_pages/my_friends_page.dart';
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}
enum MainScreenTab {
  friends,
  chats,
  translation,
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{

  NetworkCheckingService networkCheckingService = NetworkCheckingService();
  final _chatProvider = ChatProvider.instance;
  final _authProvider = AuthProvider.instance;
  MainScreenTab _currentTab = MainScreenTab.chats;
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  final List<Widget> _widgetOptions = <Widget>[    MyFriendsPage(), RoomSelectingPage(), TranslationPage() ];

  void _onTabSelected(MainScreenTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }


  @override
  void initState() {
    // TODO: implement initState

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset(0.0, 0.0),
      end: Offset(1.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    super.initState();
    // 변경된 부분
    _currentTab = MainScreenTab.chats;
    // Create an instance of the InternetConnectionStatusService

  }
  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String  tabTitle;
    switch(_currentTab){
      case MainScreenTab.friends:
        tabTitle = "Friends";
        break;
      case MainScreenTab.chats:
        tabTitle = "Classrooms";
        break;
      case MainScreenTab.translation:
        tabTitle = "Translation";
        break;
    }
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: ColorManager.color_standard,
          title: Text(tabTitle),
          actions: [
            if (_currentTab == MainScreenTab.chats)
              IconButton(
                icon: Image.asset('assets/new_chat.png', color: Colors.white,),
                onPressed: () async {
                  onPressedCreateChatRoomBtn();
                },
              ),
          ],
        ),
        body: Column(
          children: [
            StreamBuilder<bool>(
              stream: networkCheckingService.getInternetAvailabilityStream(),
              builder: (context, snapshot) {
                if(snapshot.data == null || snapshot.data! == false){
                  return SizedBox(
                    height: 50,
                    child: Container(
                      color: Colors.black12,
                      child: Center(
                        child: Text(
                          "네트워크 연결 상태를 확인해주세요",
                          style: const TextStyle(
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                else{
                  return Container(height: 0);
                }
              }
            ),
            Expanded(
              child: Center(
                child: _widgetOptions.elementAt(_currentTab.index),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.translate),
              label: 'Translation',
            ),
          ],
          currentIndex: _currentTab.index,
          onTap: (index) {
            _onTabSelected(MainScreenTab.values[index]);
          },
        ),
      ),
    );
  }

  void onPressedCreateChatRoomBtn() async{
    bool networkAvailable = await networkCheckingService.isInternetConnectionAvailable();
    if(!networkAvailable){
      await sayneConfirmDialog(context, "", "네트워크 상태를 확인해주세요");
      return;
    }
    _animationController.reset();
    _animationController.forward();
    String? roomTitle = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
              -MediaQuery.of(context).size.width, 0, 0),
          child: SlideTransition(
            position: _animation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: RoomTitleSettingPage(),
            ),
          ),
        );
      },
    );
    _animationController.reverse();
    if (roomTitle != null && roomTitle.isNotEmpty) {
      ChatRoom? chatRoom = await _chatProvider.createChatRoom(
          roomTitle,
          _authProvider.curUserModel!,
      );
      if(chatRoom == null){
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomScreen(
            chatRoomToLoad: chatRoom,
          ),
        ),
      );
    }
  }
}
