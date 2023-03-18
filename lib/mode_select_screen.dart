import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'auth_provider.dart';

class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({Key? key}) : super(key: key);

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen> {
  final authScreenControl = AuthProvider.instance;

  String roomId = "users";
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _onPresenterButtonPressed,
            child: Text('Presenter'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onAudienceButtonPressed,
            child: Text('Audience'),
          ),
        ],
      ),
    );
  }
  void _onPresenterButtonPressed() async {
    if(authScreenControl.curUserCredential == null || authScreenControl.curUserCredential!.user == null) {
      // 로그인되어 있지 않은 경우, 로그인 화면으로 돌아가기
      Navigator.pop(context);
      return;
    }

    String mode = "Presenter"; // 모드 선택
    String uid = authScreenControl.curUserCredential!.user!.uid; // 현재 사용자의 uid 가져오기
    await FirebaseFirestore.instance // 데이터베이스에 데이터 저장
        .collection(roomId)
        .doc(uid)
        .set({'mode': mode});
    // TODO: presenter 모드로 이동하는 코드 작성
  }

  void _onAudienceButtonPressed() async {
    if(authScreenControl.curUserCredential == null || authScreenControl.curUserCredential!.user == null) {
      // 로그인되어 있지 않은 경우, 로그인 화면으로 돌아가기
      Navigator.pop(context);
      return;
    }

    String mode = "Audience"; // 모드 선택
    String uid = authScreenControl.curUserCredential!.user!.uid; // 현재 사용자의 uid 가져오기
    await FirebaseFirestore.instance // 데이터베이스에 데이터 저장
        .collection(roomId)
        .doc(uid)
        .set({'mode': mode});
    // TODO: audience 모드로 이동하는 코드 작성
  }


}
