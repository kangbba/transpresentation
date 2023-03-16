import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  //
  // Future<UserCredential?> signInWithGoogle() async {
  //   // Trigger the Google Authentication flow.
  //   final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //
  //   if (googleUser == null) {
  //     throw FirebaseAuthException(
  //       code: 'ERROR_ABORTED_BY_USER',
  //       message: 'Sign in aborted by user',
  //     );
  //   }
  //
  //   // Obtain the Google Authentication credential.
  //   final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //
  //   // Create a Firebase credential from the Google Authentication credential.
  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );
  //
  //   // Sign in to Firebase with the Firebase credential.
  //   return await _auth.signInWithCredential(credential);
  // }

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
            _logInBtn(),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                // try {
                //   final UserCredential? userCredential = await signInWithGoogle();
                //   // Navigate to the home screen if the login is successful.
                // } catch (e) {
                //   print(e);
                // }
              },
              child: Text('Login with Google'),
            ),
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

  ElevatedButton _logInBtn() {
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
