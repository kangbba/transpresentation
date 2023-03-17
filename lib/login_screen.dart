import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:transpresentation/auth_screen_control.dart';
import 'package:transpresentation/main_screen.dart';
import 'package:transpresentation/sayne_dialogs.dart';
import 'package:transpresentation/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthScreenControl authScreenControl = AuthScreenControl();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    GoogleSignInAccount? _currentUser;
    String _contactText = '';
    authScreenControl.googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
    });
    authScreenControl.googleSignIn.signInSilently();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20),
            _standardLogInBtn(),
            SizedBox(height: 20),
            _googleLogInBtn(),
            TextButton(
              onPressed: () {
                // TODO: Implement Facebook login logic
              },
              child: Text('Login with Facebook'),
            ),
            TextButton(
              onPressed: () {
                // Switch to the Signup screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: Text('Need an account? Sign up.'),
            ),
          ],
        ),
      ),
    );
  }
  Widget _googleLogInBtn() {
    return TextButton(
      onPressed: () async {
        sayneLoadingDialog(context, "구글 접속중");
        bool succeed = await authScreenControl.signInWithGoogle();
        Navigator.pop(context);
        sayneToast("${succeed ? "로그인 성공" : " 로그인 실패"}");
      },
      child: Text('Login with Google'),
    );
  }

  Widget _standardLogInBtn() {
    return ElevatedButton(
            onPressed: () async {
              sayneLoadingDialog(context, "로그인중");
              String email = _emailController.text.trim();
              String pw = _passwordController.text.trim();
              bool loginSucceed = await authScreenControl.loginTry(email, pw);
              if(loginSucceed){
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              }
              else{
                Navigator.pop(context);
              }
            },
            child: Text('Login'),
          );
  }

}
