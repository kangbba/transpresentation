import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:transpresentation/sayne_dialogs.dart';

class AuthScreenControl {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  Future<bool> loginTry(String email, String pw) async{
    bool success = false;
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pw,
      );
      success = true;
      // Navigate to the home screen if the login is successful.
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        sayneToast('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        sayneToast('Wrong password provided for that user.');
      }
    }
    catch (e){
      sayneToast('$e');
    }
    finally{
    }
    return success;
  }


  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      return account != null;
    } catch (error) {
      print("구글 로그인 도중 에러발생 : $error");
      return false;
    }
  }


  Future<bool> signOutFromGoogle() async {
    try {
      await googleSignIn.signOut();
      return true;
    } catch (error) {
      print("구글 로그아웃 도중 에러발생 : $error");
      return false;
    }
  }
}