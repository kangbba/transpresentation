
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:transpresentation/classes/presentation.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import 'package:transpresentation/classes/user_model.dart';

import '../exceptions/chat_room_exception.dart';

class ChatRoom with ChangeNotifier{
  final String id;
  final String name;
  final UserModel host;

  static const String kIdKey = 'id';
  static const String kNameKey = 'name';
  static const String kHostKey = 'host';
  static const String kChatRoomsKey = 'chatRooms';
  static const String kPresentationsKey = 'presentations';
  static const String kPresentationId = 'presentation_0';

  //chatRoom
  ChatRoom({
    required this.id,
    required this.name,
    required this.host,
  });

  Map<String, dynamic> toMap() {
    return {
      kIdKey: id,
      kNameKey: name,
      kHostKey: host.toMap(),
    };
  }

  factory ChatRoom.fromFirebaseSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChatRoom(
      id: snapshot.id,
      name: data[kNameKey],
      host: UserModel.fromMap(data[kHostKey]),
    );
  }

  //host
  void setHost(UserModel host) {
    FirebaseFirestore.instance
        .collection(kChatRoomsKey)
        .doc(id)
        .update({
      kHostKey: host.toMap(),
    }).onError((error, stackTrace) {
      print('Error setting chat room host: $error');
      print(stackTrace);
      throw ChatRoomException('Failed to set chat room host.');
    });
    notifyListeners();
  }
  //hostStream
  Stream<UserModel> hostStream() {
    return FirebaseFirestore.instance
        .collection(kChatRoomsKey)
        .doc(id)
        .snapshots()
        .map((snapshot) =>
        UserModel.fromMap((snapshot.data() ?? {})[kHostKey] ?? {}));
  }

  Stream<Presentation?> presentationStream() {
    return FirebaseFirestore.instance
        .collection(kChatRoomsKey)
        .doc(id)
        .collection(kPresentationsKey)
        .doc(kPresentationId)
        .snapshots()
        .map((snapshot) => Presentation.fromMap(snapshot.data() ?? const <String, dynamic>{}));
  }





  Future<bool> updatePresentation(String langCode, String content) async {
    try {
      final presentationRef = FirebaseFirestore.instance
          .collection(ChatRoom.kChatRoomsKey)
          .doc(id)
          .collection(ChatRoom.kPresentationsKey)
          .doc(kPresentationId);

      final presentationQuerySnapshot = await presentationRef.get();
      final presentationSnapshot = presentationQuerySnapshot.data();
      if (presentationSnapshot == null) {
        // Presentation document does not exist, create it first
        await presentationRef.set(Presentation(
          id: 'temp_id',
          name: 'temp_name',
          langCode: langCode,
          content: content,
        ).toMap());
        print("dd");
      } else {
        // Presentation document exists, update its content and language code
        await presentationRef.update({
          Presentation.kContentKey: content,
          Presentation.kLangCodeKey: langCode,
        });
        print("dd2");
      }
      return true;
    } catch (e) {
      print('Error updating presentation content: $e');
      return false;
    }
  }



  // Members
  static const kMembersKey = 'members';


  Stream<List<dynamic>> get membersStream {
    final membersRef = this.membersRef.snapshots();
    return membersRef.map((querySnapshot) => querySnapshot.docs
        .map((doc) => doc.data())
        .toList());
  }

  CollectionReference get membersRef =>
      FirebaseFirestore.instance.collection(kChatRoomsKey).doc(id).collection(kMembersKey);

  Future<bool> joinRoom(UserModel user) async {
    try {
      final memberRef = membersRef.doc(user.uid);
      final memberDoc = await memberRef.get();
      if (memberDoc.exists) {
        // 이미 멤버인 경우
        print("${user.email} 이미있음");
        return true;
      } else {
        print("${user.email} 없어서 추가하겠음");
        // 멤버가 아닌 경우, 추가
        await memberRef.set(user.toMap());
        return true;
      }
    } catch (e) {
      throw FirebaseException(
          message: 'Error joining chat room: $e', code: 'join-room-error', plugin: '');
    }
  }


  Future<void> exitRoom(UserModel user, {UserModel? newHost}) async {
    try {
      final userDoc = await membersRef.doc(user.uid).get();
      if (!userDoc.exists) {
        sayneToast("해당 방에 내가 없습니다");
        return; // 해당 사용자가 채팅방 멤버가 아니면 삭제하지 않음
      }

      await userDoc.reference.delete();

      final membersSnapshot = await membersRef.get();
      final remainingMembers = membersSnapshot.docs
          .map((doc) => UserModel.fromFirebaseSnapshot(doc))
          .where((member) => member.uid != user.uid)
          .toList();

      if (remainingMembers.isEmpty) {
        await FirebaseFirestore.instance
            .collection(kChatRoomsKey)
            .doc(id)
            .delete();
      } else if (host.uid == user.uid) {
        UserModel newHostUser = newHost ?? remainingMembers.first;
        setHost(newHostUser);
      }

      return;
    } catch (e) {
      throw FirebaseException(
          message: 'Error exiting chat room: $e', code: 'exit-room-error', plugin: '');
    }
  }



}