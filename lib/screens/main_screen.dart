import 'package:flutter/material.dart';
import 'package:transpresentation/helper/colors.dart';
import 'package:transpresentation/screens/room_selecting_page.dart';
import 'package:transpresentation/testing/tmp_page.dart';

import '../classes/auth_provider.dart';
import '../classes/chat_provider.dart';
import '../classes/chat_room.dart';
import '../classes/user_model.dart';
import '../room_screens/room_screen.dart';
import '../room_screens/room_title_setting_page.dart';
import 'my_friends_page.dart';
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}
enum MainScreenTab {
  friends,
  chats,
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{
  final _chatProvider = ChatProvider.instance;
  final _authProvider = AuthProvider.instance;
  MainScreenTab _currentTab = MainScreenTab.chats;
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  final List<Widget> _widgetOptions = <Widget>[    MyFriendsPage(),    RoomSelectingPage(),  ];


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
        body: Center(
          child: _widgetOptions.elementAt(_currentTab.index),
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
