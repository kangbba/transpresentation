import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transpresentation/screens/room_selecting_page.dart';
import 'package:transpresentation/screens/setting_screen.dart';

import '../classes/auth_provider.dart';
import '../classes/chat_provider.dart';
import '../room_screens/room_screen.dart';
import 'my_friends_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _chatProvider = ChatProvider.instance;
  final _authProvider = AuthProvider.instance;
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[    MyFriendsPage(),    RoomSelectingPage(),    SettingScreen(),  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // void _showChangeNicknameDialog() async {
  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         child: ChangingNicknameScreen(),
  //       );
  //     },
  //     barrierDismissible: false,
  //   );
  //   Navigator.pop(context);
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로 가기 버튼이 눌렸을 때의 동작을 작성합니다.
        return false; // 뒤로 가기 버튼을 무시합니다.
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading : false,
          title: Text('Chat Rooms'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomScreen(chatRoomToLoad: null,),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.more),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
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
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
