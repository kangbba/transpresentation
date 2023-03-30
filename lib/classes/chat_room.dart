
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:transpresentation/classes/presentation.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import 'package:transpresentation/classes/user_model.dart';

class ChatRoom with ChangeNotifier{
  final String id;
  final String name;
  late UserModel _host;

  static const String kIdKey = 'id';
  static const String kNameKey = 'name';
  static const String kHostKey = 'host';
  static const String kChatRoomsKey = 'chatRooms';
  static const String kPresentationsKey = 'presentations';
  static const String kPresentationId = 'presentation_0';

  UserModel get host => _host;
  set host(UserModel value) {
    _host = value;
    _updateHost(value);
  }

  //chatRoom
  ChatRoom({
    required this.id,
    required this.name,
    required UserModel host,
  }) : _host = host;

  Map<String, dynamic> toMap() {
    return {
      kIdKey: id,
      kNameKey: name,
      kHostKey: host.toMap(),
    };
  }

  factory ChatRoom.fromFirebaseSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    final hostData = data[kHostKey] as Map<String, dynamic>;
    final host = UserModel.fromMap(hostData);

    return ChatRoom(
      id: data[kIdKey],
      name: data[kNameKey],
      host: host,
    );
  }
  //host
  void _updateHost(UserModel host) {
    FirebaseFirestore.instance
        .collection(kChatRoomsKey)
        .doc(id)
        .update({
      kHostKey: host.toMap(),
    }).catchError((error) {
      // handle error
    });
    notifyListeners();
  }

  //presentation

  Stream<Presentation> presentationStream() {
    return FirebaseFirestore.instance
        .collection(kChatRoomsKey)
        .doc(id)
        .collection(kPresentationsKey)
        .doc(kPresentationId)
        .snapshots()
        .map((snapshot) => Presentation.fromMap(snapshot.data() ?? {}));
  }

  Future<bool> updatePresentation(String langCode, String content) async {
    try {
      final presentationRef = FirebaseFirestore.instance
          .collection(ChatRoom.kChatRoomsKey)
          .doc(id)
          .collection(ChatRoom.kPresentationsKey)
          .doc(kPresentationId);

      final presentationSnapshot = await presentationRef.get();
      if (!presentationSnapshot.exists) {
        // Presentation document does not exist, create it first
        await presentationRef.set(Presentation(
          id: 'temp_id',
          name: 'temp_name',
          langCode: langCode,
          content: content,
        ).toMap());
      } else {
        // Presentation document exists, update its content and language code
        await presentationRef.update({
          Presentation.kContentKey: content,
          Presentation.kLangCodeKey: langCode,
        });
      }
      return true;
    } catch (e) {
      print('Error updating presentation content: $e');
      return false;
    }
  }


  // Members
  static const kMembersKey = 'members';

  CollectionReference get membersRef =>
      FirebaseFirestore.instance.collection(kChatRoomsKey).doc(id).collection(kMembersKey);

  Stream<List<dynamic>> get membersStream {
    final membersRef = this.membersRef.snapshots();
    return membersRef.map((querySnapshot) => querySnapshot.docs
        .map((doc) => doc.data())
        .toList());
  }

  Future<bool> joinRoom(UserModel user) async {
    try {
      final memberRef = this.membersRef.doc(user.uid);

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
      await membersRef.doc(user.uid).delete();

      final membersSnapshot = await membersRef.get();
      final remainingMembers = membersSnapshot.docs
          .map((doc) => UserModel.fromFirebaseSnapshot(doc))
          .where((member) => member.uid != user.uid)
          .toList();

      if (remainingMembers.isEmpty) {
        await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(id)
            .delete();
      }
      else if (host.uid == user.uid) {
        UserModel newHostUser = newHost ?? remainingMembers.first;
        host = (newHostUser);
      }

      return true;
    } catch (e) {
      print('Error exiting chat room: $e');
      return false;
    }
  }

}