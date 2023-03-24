import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';

class ChangingNicknameScreen extends StatefulWidget {
  const ChangingNicknameScreen({Key? key}) : super(key: key);

  @override
  State<ChangingNicknameScreen> createState() => _ChangingNicknameScreenState();
}
class _ChangingNicknameScreenState extends State<ChangingNicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('닉네임 변경'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('새로운 닉네임을 입력해주세요.'),
            TextField(
              controller: _nicknameController,
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  return; // 로그인되어 있지 않으면 종료
                }
                await user.updateDisplayName(_nicknameController.text);
                sayneToast('닉네임이 변경되었습니다.');
                Navigator.pop(context);
              },
              child: Text('변경하기'),
            ),
          ],
        ),
      ),
    );
  }
}
