import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transpresentation/sayne_dialogs.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
              ),
            ),
            SizedBox(height: 20),

            _signUpBtn(context),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // TODO: Implement Google login logic
              },
              child: Text('Sign up with Google'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement Facebook login logic
              },
              child: Text('Sign up with Facebook'),
            ),
            TextButton(
              onPressed: () {
                // Switch to the Login screen
                Navigator.pop(context);
              },
              child: Text('Already have an account? Log in.'),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _signUpBtn(BuildContext context) {
    return ElevatedButton(
            onPressed: () async {
              String email = _emailController.text.trim();
              String pw = _passwordController.text.trim();
              String cpw = _confirmPasswordController.text.trim();
              if(pw != cpw){
                sayneToast('confirm 비밀번호가 올바르지 않음');
                return;
              }
              sayneLoadingDialog(context, "회원가입 시도");
              try {
                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: pw,
                );
                sayneToast('User ${userCredential.user?.uid} signed up success');
                Navigator.pop(context);
              }
              on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  sayneToast('The password provided is too weak.');
                } else if (e.code == 'email-already-in-use') {
                  sayneToast('The account already exists for that email.');
                }
              } catch (e) {
                print(e);
              }
              finally{
                Navigator.pop(context);
              }
            },
            child: Text('Sign up'),
          );
  }
}