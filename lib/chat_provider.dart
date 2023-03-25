import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:transpresentation/user_model.dart';

import 'chat_room.dart';
import 'helper/sayne_dialogs.dart';

class Message {
  final String text;
  final String senderId;
  final String senderEmail;
  final DateTime createdAt;

  Message({
    required this.text,
    required this.senderId,
    required this.senderEmail,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    final text = data['text'];
    final senderId = data['senderId'];
    final senderEmail = data['senderEmail'];
    final timestamp = (data['createdAt'] as Timestamp).toDate();

    return Message(
      text: text,
      senderId: senderId,
      senderEmail: senderEmail,
      createdAt: timestamp,
    );
  }
}

class ChatProvider with ChangeNotifier {

  static final ChatProvider _instance = ChatProvider._internal();

  ChatProvider._internal();

  factory ChatProvider.getInstance() => _instance;

  static ChatProvider get instance => _instance;

  Future<ChatRoom> createChatRoom(String chatRoomName, UserModel hostUserModel) async {
    final chatRoomRef = FirebaseFirestore.instance.collection('chatRooms').doc();
    final newChatRoom = {
      'name': chatRoomName,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await chatRoomRef.set(newChatRoom);
    final chatRoomSnapshot = await chatRoomRef.get();
    final chatRoom = ChatRoom.fromSnapshot(chatRoomSnapshot);
    await chatRoom.joinRoom(hostUserModel);
    sayneToast("방 참가 성공");
    await chatRoom.setHost(hostUserModel);
    return chatRoom;
  }




  Future<void> sendMessage(
      String chatRoomId,
      String message,
      UserCredential userCredential,
      ) async {
    final messageRef = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc();

    final newMessage = {
      'text': message,
      'senderId': userCredential.user!.uid,
      'senderEmail': userCredential.user!.email,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await messageRef.set(newMessage);
  }

  Stream<List<Message>> getRecentMessages(String chatRoomId) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(20);

    return messagesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
    });
  }


}
