
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import 'package:transpresentation/user_model.dart';

class ChatRoom with ChangeNotifier{
  final String id;
  final String name;
  final DateTime createdAt;
  late UserModel host; // 새로운 필드 추가

  ChatRoom({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.host, // 생성자에서 초기화
  });

  Stream<List<dynamic>> get membersStream {
    final membersRef = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(id)
        .collection('members')
        .snapshots();

    return membersRef.map((querySnapshot) => querySnapshot.docs
        .map((doc) => doc.data())
        .toList());
  }

  factory ChatRoom.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return ChatRoom(
      id: snapshot.id,
      name: data['name'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      host: UserModel(
        uid: data['host']['uid'] ?? '',
        displayName: data['host']['displayName'] ?? '',
        email: data['host']['email'] ?? '',
        photoUrl: data['host']['photoURL'] ?? '',
      ),
    );
  }

  Future<bool> joinRoom(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(id)
          .collection('members')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'email': user.email,
        'photoURL': user.photoUrl,
      });
      return true;
    } catch (e) {
      print('Error joining chat room: $e');
      return false;
    }
  }
  Future<bool> exitRoom(UserModel user, {UserModel? newHost}) async {
    try {
      final membersRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(id)
          .collection('members');
      await membersRef.doc(user.uid).delete();

      final membersSnapshot = await membersRef.get();
      final remainingMembers = membersSnapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .where((member) => member.uid != user.uid)
          .toList();

      if (remainingMembers.isEmpty) {
        await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(id)
            .delete();
      } else if (host.uid == user.uid) {
        UserModel newHostUser = newHost ?? remainingMembers.first;
        await setHost(newHostUser);
      }

      return true;
    } catch (e) {
      print('Error exiting chat room: $e');
      return false;
    }
  }

  Future<bool> setHost(UserModel newHostUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(id)
          .update({
        'host': {
          'uid': newHostUser.uid,
          'displayName': newHostUser.displayName,
          'email': newHostUser.email,
          'photoURL': newHostUser.photoUrl,
        },
      });
      sayneToast("호스트 ${newHostUser.email} 에게 위임성공");
      host = newHostUser; // host 속성을 업데이트하면서 notifyListeners()를 호출합니다.
      notifyListeners();
      return true;
    } catch (e) {
      print('Error setting chat room host: $e');
      return false;
    }
  }
}