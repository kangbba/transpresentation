import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
class ChatRoom {
  final String id;
  final String name;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.name,
    required this.createdAt,
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
    );
  }
  factory ChatRoom.fromReference(DocumentReference reference) {
    return ChatRoom(
      id: reference.id,
      name: 'Unknown Chat Room',
      createdAt: DateTime.now(),
    );
  }
  Future<bool> joinRoom(String email) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(email);
      final userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        // 사용자가 존재하지 않는 경우
        return false;
      }

      // 존재하는 경우 "members" 컬렉션에 사용자를 추가
      final membersRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(id)
          .collection('members')
          .doc(email);

      await membersRef.set({
        'userEmail': email,
        'role': 'member',
      });

      return true;
    } catch (e) {
      // 에러 발생 시 false 반환
      return false;
    }
  }

  Future<bool> exitRoom(String email) async {
    try {
      final membersRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(id)
          .collection('members')
          .doc(email);

      await membersRef.delete();
      return true;
    } catch (e) {
      return false;
    }
  }



}

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

  Future<DocumentReference> createChatRoom(String chatRoomName) async {
    final chatRoomRef =
    FirebaseFirestore.instance.collection('rooms').doc();

    final newChatRoom = {
      'name': chatRoomName,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await chatRoomRef.set(newChatRoom);

    return chatRoomRef;
  }

  Future<void> sendMessage(
      String chatRoomId,
      String message,
      UserCredential userCredential,
      ) async {
    final messageRef = FirebaseFirestore.instance
        .collection('rooms')
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
        .collection('rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(20);

    return messagesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
    });
  }


}
