import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_auth/firebase_auth.dart';
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
      final chatRoomRef = FirebaseFirestore.instance.collection(ChatRoom.kChatRoomsKey).doc();
      final newChatRoom = ChatRoom(
        id: chatRoomRef.id,
        name: chatRoomName,
        host: hostUserModel,
      );
      await chatRoomRef.set(newChatRoom.toMap());
      final chatRoomSnapshot = await chatRoomRef.get();
      final chatRoom = ChatRoom.fromFirebaseSnapshot(chatRoomSnapshot);
      await chatRoom.joinRoom(hostUserModel);
      sayneToast("방 참가 성공");
      chatRoom.host = hostUserModel;
      return chatRoom;
    } catch (e) {
      print("Failed to create chat room: $e");
      return null;
    }
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
