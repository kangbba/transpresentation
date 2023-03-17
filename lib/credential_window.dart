import 'package:flutter/material.dart';

import 'auth_screen_control.dart';

class CredentialWindow extends StatefulWidget {
  const CredentialWindow({Key? key}) : super(key: key);

  @override
  State<CredentialWindow> createState() => _CredentialWindowState();
}

class _CredentialWindowState extends State<CredentialWindow> {
  final authScreenControl = AuthScreenControl.instance;
  @override
  Widget build(BuildContext context) {
    return Align(
        child: Column(
          children: [
            Text("${authScreenControl.curUserCredential?.user?.email}"),
            Text("${authScreenControl.curUserCredential?.user?.displayName}"),
            Text("${authScreenControl.curUserCredential?.user?.uid}"),
            Text("${authScreenControl.curUserCredential?.user?.metadata}"),
            Text("${authScreenControl.curUserCredential?.user?.emailVerified}"),
            Text("${authScreenControl.curUserCredential?.user?.phoneNumber}"),
            Text("${authScreenControl.curUserPlatform}"),
          ],
        ));
  }
}
