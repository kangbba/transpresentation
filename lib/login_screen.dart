import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/auth_provider.dart';
import 'package:transpresentation/main_screen.dart';
import 'package:transpresentation/mode_select_screen.dart';
import 'package:transpresentation/sayne_dialogs.dart';
import 'package:transpresentation/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authProvider = AuthProvider.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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

    loadRememberMe();
    GoogleSignInAccount? _currentUser;
    String _contactText = '';
    _authProvider.googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      print("으잉");
    });
    _authProvider.googleSignIn.signInSilently();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: SingleChildScrollView(
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
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.black38,),
                    ),
                  ),
                ),
                FutureBuilder<bool>(
                  future: LocalStorage.getRememberMeLocal(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CheckboxListTile(
                        title: Text("아이디 기억하기"),
                        value: snapshot.data!,
                        onChanged: (value) async {
                          await LocalStorage.setRememberMeLocal(value!);
                          setState(() {

                          });
                        },
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()))
                        .then((data) async {
                      if (data != null) {
                        String email = data['email'];
                        String password = data['password'];
                        _emailController.text = email;
                        _passwordController.text = password;
                        _obscurePassword = true;
                        bool rememberMe = await LocalStorage.getRememberMeLocal();
                        await onPressedSignInStandard(email, password, rememberMe);
                      }
                    });
                  },
                  child: Text('Need an account? Sign up.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
// 로그인 버튼을 눌렀을 때 호출되는 함수

// 앱을 실행할 때 호출되는 함수
  void loadRememberMe() async {
    bool rememberMe = await LocalStorage.getRememberMeLocal(); // 값을 불러옵니다.
    String recentId = rememberMe ? await LocalStorage.getRecentIdLocal() : '';
    setState(() {
      _emailController.text = recentId;
    });
  }
  Widget _googleLogInBtn() {
    return TextButton(
      onPressed: () async {
        sayneLoadingDialog(context, "로그인중");
        try {
          UserCredential userCredential = await _authProvider.signInWithGoogle();
          // 로그인이 성공한 경우, UserCredential 객체를 사용하여 로그인한 사용자의 정보를 가져옵니다.
          User user = userCredential.user!;
          _authProvider.curUserCredential = userCredential;
          _authProvider.curUserPlatform = LoginPlatform.google;
          sayneToast("${user.email}");
          if(mounted){
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'ERROR_ABORTED_BY_USER') {
            sayneToast("ERROR_ABORTED_BY_USER");
            // 사용자가 Google 로그인을 취소한 경우 처리할 코드
          } else if (e.code == 'ERROR_SIGN_IN_FAILED') {
            sayneToast("ERROR_SIGN_IN_FAILED");
            // Google 로그인에 실패한 경우 처리할 코드
          }
        } catch (e) {
          // FirebaseAuthException이 아닌 다른 예외가 발생한 경우 처리할 코드
        }
      },
      child: Text('Login with Google'),
    );
  }

  Widget _standardLogInBtn() {
    return ElevatedButton(
            onPressed: () async {
              String email = _emailController.text.trim();
              String password = _passwordController.text.trim();
              bool rememberMe = await LocalStorage.getRememberMeLocal();
              await onPressedSignInStandard(email, password, rememberMe);
            },
            child: Text('Login'),
          );
  }

  Future<void> onPressedSignInStandard(String email, String password, bool rememberMe) async {
    sayneLoadingDialog(context, "로그인중");
    try {
      UserCredential userCredential = await _authProvider.signInStandard(email, password);
      // 로그인 성공 시 처리할 코드를 작성합니다.
      if(rememberMe){
        LocalStorage.setRecentIdLocal(email);
        print("유저가 최근 아이디를 기억해달라고 요청하였음");
      }
      _authProvider.curUserCredential = userCredential;
      _authProvider.curUserPlatform = LoginPlatform.standard;
      if(mounted){
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      // Firebase Authentication 예외 처리
      if (e.code == 'user-not-found') {
        sayneToast('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        sayneToast('Wrong password provided for that user.');
      } else {
        sayneToast('Firebase Authentication 예외: ${e.message}');
      }
    } catch (e) {
      // 그 외 예외 처리
      sayneToast('예외 발생: $e');
    }
  }

}
