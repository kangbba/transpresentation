import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthScreenControl {

  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        Fluttertoast.showToast(msg: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'Wrong password provided for that user.');
      }
    }
    catch (e){
      Fluttertoast.showToast(msg: '$e');
    }
    finally{
    }
    return success;
  }



}