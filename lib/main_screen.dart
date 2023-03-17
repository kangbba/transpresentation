import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transpresentation/presenter_screen.dart';

import 'audience_screen.dart';
import 'auth_screen_control.dart';
import 'mode_select_screen.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final authScreenControl = AuthScreenControl.instance;
  Stream<DocumentSnapshot> _userStream =
  FirebaseFirestore.instance.collection('users').doc().snapshots();

  @override
  void initState() {
    super.initState();
    String uid = authScreenControl.curUserCredential!.user!.uid;
    _userStream =
        FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (!snapshot.hasData || snapshot.data!.data() == null) {
                return const ModeSelectScreen();
              }

              final String mode = (snapshot.data!.data() as Map<String, dynamic>)['mode'] ?? '';
              switch (mode) {
                case 'Presenter':
                  return const PresenterScreen();
                case 'Audience':
                  return const AudienceScreen();
                default:
                  return const ModeSelectScreen();
              }
          }
        },
      ),
    );
  }

}
