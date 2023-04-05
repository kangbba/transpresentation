import 'package:flutter/material.dart';
import 'package:transpresentation/screens/room_selecting_page.dart';
import 'package:transpresentation/screens/tmp_page.dart';

import '../classes/auth_provider.dart';
import '../classes/chat_provider.dart';
import '../room_screens/room_screen.dart';
import 'my_friends_page.dart';
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}
enum MainScreenTab {
  friends,
  chats,
  tmp,
}

class _MainScreenState extends State<MainScreen> {
  final _chatProvider = ChatProvider.instance;
  final _authProvider = AuthProvider.instance;
  MainScreenTab _currentTab = MainScreenTab.chats;

  final List<Widget> _widgetOptions = <Widget>[
    MyFriendsPage(),
    RoomSelectingPage(),
    TmpPage(),
  ];

  void _onTabSelected(MainScreenTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    String  tabTitle;
    switch(_currentTab){
      case MainScreenTab.friends:
        tabTitle = "Friends";
        break;
      case MainScreenTab.chats:
        tabTitle = "Meeting Rooms";
        break;
      case MainScreenTab.tmp:
        tabTitle = "Tmp";
        break;
    }
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(tabTitle),
          actions: [
            if (_currentTab == MainScreenTab.chats)
              IconButton(
                icon: Image.asset('assets/new_chat.png', color: Colors.white,),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomScreen(
                        chatRoomToLoad: null,
                      ),
                    ),
                  );
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
}
