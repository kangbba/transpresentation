import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:transpresentation/classes/chat_room.dart';
import 'package:transpresentation/classes/user_model.dart';
class Presentation with ChangeNotifier{
  static const kIdKey = 'id';
  static const kNameKey = 'name';
  static const kContentKey = 'content';
  static const kLangCodeKey = 'langCode';

  // Members
  final String id;
  final String name;
  String langCode = '';
  String content = '';

  Presentation({
    required this.id,
    required this.name,
    required langCode,
    required content,
  });

  factory Presentation.fromMap(Map<String, dynamic> map) {
    return Presentation(
      id: map[kIdKey],
      name: map[kNameKey],
      langCode: map[kLangCodeKey],
      content: map[kContentKey],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      kIdKey: id,
      kNameKey: name,
      kContentKey: content,
      kLangCodeKey: langCode,
    };
  }

}
