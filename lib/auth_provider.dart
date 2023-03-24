import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';

enum LoginPlatform{
  standard,
  google,
  facebook,
  apple,
}

class AuthProvider with ChangeNotifier{
  static AuthProvider? _instance;
  static AuthProvider get instance {
    _instance ??= AuthProvider();
    return _instance!;
  }

  UserCredential? _curUserCredential;
  LoginPlatform? _curUserPlatform;

  final FirebaseAuth _auth = FirebaseAuth.instance;


  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  Future<UserCredential> signInStandard(String email, String pw) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pw,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'ERROR_LOGIN_FAILED',
        message: '로그인에 실패했습니다. 다시 시도해주세요.',
      );
    } finally {
      // finally 블록에서 필요한 코드를 실행해 줍니다.
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Google 로그인이 취소되었습니다.',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'ERROR_SIGN_IN_FAILED',
        message: 'Google 로그인에 실패했습니다. 다시 시도해주세요.',
        // Firebase Authentication 예외를 던지기 때문에 stack trace도 포함시켜줍니다.
      );
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await googleSignIn.signOut();
      return true;
    } catch (error) {
      print("구글 로그아웃 도중 에러발생 : $error");
      throw FirebaseAuthException(
        code: 'ERROR_SIGN_OUT_FAILED',
        message: 'Google 로그아웃에 실패했습니다. 다시 시도해주세요.',
        // Firebase Authentication 예외를 던지기 때문에 stack trace도 포함시켜줍니다.
      );
    }
  }


  UserCredential? get curUserCredential{
    return _curUserCredential;
  }
  set curUserCredential(UserCredential? userCredential){
    _curUserCredential = userCredential;
    notifyListeners();
  }
  LoginPlatform? get curUserPlatform{
    return _curUserPlatform;
  }
  set curUserPlatform(LoginPlatform? loginPlatform){
    _curUserPlatform = loginPlatform;
    notifyListeners();
  }

  void clearCurUserInformation(){
    curUserCredential = null;
    curUserPlatform = null;
  }

  User? get curUser{
    if(_curUserCredential == null){
      return null;
    }
    else{
      return _curUserCredential!.user;
    }
  }
}