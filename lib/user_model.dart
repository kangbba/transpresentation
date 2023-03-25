
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return UserModel(
      uid: data['uid'] ?? '',
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoURL'] ?? '',
    );
  }

  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      displayName: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL ?? '',
    );
  }
}

