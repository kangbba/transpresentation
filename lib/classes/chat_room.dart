
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:transpresentation/classes/presentation.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import 'package:transpresentation/classes/user_model.dart';

class ChatRoom{
  final String id;
  final String name;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Stream<Presentation?> get presentationStream {
    final presentationRef = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(id)
        .collection('presentations')
        .doc('presentation')
        .snapshots();

    return presentationRef.map((docSnapshot) {
      if (!docSnapshot.exists) {
        return null;
      }
      final data = docSnapshot.data() as Map<String, dynamic>;
      return Presentation.fromMap(data);
    });
  }

  Future<void> updatePresentation(String presentationMsgToUpdate) async {
    final presentationRef = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(id)
        .collection('presentations')
        .doc('presentation');

    final presentationDoc = await presentationRef.get();
    final presentation = Presentation(
      id: id,
      name: '',
      createdAt: DateTime.now(),
      createdBy: '',
      presentationMsg: presentationMsgToUpdate,
    );

    final presentationData = presentation.toMap();

    if (presentationDoc.exists) {
      presentationRef.update(presentationData);
    } else {
      presentationRef.set(presentationData);
    }
  }



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

  Stream<UserModel?> get hostStream {
    final hostRef = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(id)
        .snapshots();

    return hostRef.map((docSnapshot) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      final hostData = data['host'] as Map<String, dynamic>;
      return UserModel.fromMap(hostData);
    });
  }

  factory ChatRoom.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    final createdAtDate = data['createdAt'] as Timestamp;
    final createdAt = createdAtDate.toDate();


    return ChatRoom(
      id: snapshot.id,
      name: data['name'],
      createdAt: createdAt,
    );
  }
  Future<bool> joinRoom(UserModel user) async {
    try {
      final memberRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(id)
          .collection('members')
          .doc(user.uid);

      final memberDoc = await memberRef.get();
      if (memberDoc.exists) {
        // 이미 멤버인 경우
        return true;
      } else {
        // 멤버가 아닌 경우, 추가
        await memberRef.set(user.toMap());
        return true;
      }
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

      UserModel? host = await hostStream.first;
      if (remainingMembers.isEmpty) {
        await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(id)
            .delete();
      }
      else if (host != null && host.uid == user.uid) {
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
      final hostData = newHostUser.toMap();

      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(id)
          .update({
        'host': hostData,
      });

      sayneToast("호스트 ${newHostUser.email} 지정 성공");
      return true;
    } catch (e) {
      print('Error setting chat room host: $e');
      return false;
    }
  }
}