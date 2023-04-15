import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:transpresentation/classes/statics.dart';
import 'package:transpresentation/testing/message.dart';
import 'package:transpresentation/classes/user_model.dart';

import 'chat_room.dart';
import '../helper/sayne_dialogs.dart';


class ChatProvider with ChangeNotifier {

  static final ChatProvider _instance = ChatProvider._internal();

  ChatProvider._internal();

  factory ChatProvider.getInstance() => _instance;

    static ChatProvider get instance => _instance;

  Future<ChatRoom?> createChatRoom(String chatRoomName, UserModel hostUserModel) async {
    try {
      final chatRoomRef = FirebaseFirestore.instance.collection(kChatRoomsKey).doc();
      final newChatRoom = ChatRoom(
        id: chatRoomRef.id,
        name: chatRoomName,
        host: hostUserModel,
        createdAt: DateTime.now(),
      );
      await chatRoomRef.set(newChatRoom.toMap());
      final chatRoomSnapshot = await chatRoomRef.get();
      final chatRoom = ChatRoom.fromFirebaseSnapshot(chatRoomSnapshot);
      chatRoom.setHost(hostUserModel);
      return chatRoom;
    } catch (e) {
      print("Failed to create chat room: $e");
      return null;
    }
  }
  Stream<List<ChatRoom>> chatRoomsStream() {
    return FirebaseFirestore.instance
        .collection(kChatRoomsKey)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        return [];
      }
      List<ChatRoom> chatRooms =
      querySnapshot.docs.map((doc) => ChatRoom.fromFirebaseSnapshot(doc)).toList();
      // 'createdAt' 필드가 있는 경우에만 정렬
      if (querySnapshot.docs.first.data().containsKey(kCreatedAtKey)) {
        chatRooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      return chatRooms;
    });
  }










// Future<void> sendMessage(
  //     String chatRoomId,
  //     String message,
  //     UserCredential userCredential,
  //     ) async {
  //   final messageRef = FirebaseFirestore.instance
  //       .collection('chatRooms')
  //       .doc(chatRoomId)
  //       .collection('messages')
  //       .doc();
  //
  //   final newMessage = {
  //     'text': message,
  //     'senderId': userCredential.user!.uid,
  //     'senderEmail': userCredential.user!.email,
  //     'createdAt': FieldValue.serverTimestamp(),
  //   };
  //
  //   await messageRef.set(newMessage);
  // }
  //
  // Stream<List<Message>> getRecentMessages(String chatRoomId) {
  //   final messagesRef = FirebaseFirestore.instance
  //       .collection('chatRooms')
  //       .doc(chatRoomId)
  //       .collection('messages')
  //       .orderBy('createdAt', descending: true)
  //       .limit(20);
  //
  //   return messagesRef.snapshots().map((snapshot) {
  //     return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
  //   });
  // }


}
