import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:transpresentation/classes/chat_room.dart';
import 'package:transpresentation/classes/user_model.dart';

class Presentation with ChangeNotifier {
  static const kIdKey = 'id';
  static const kNameKey = 'name';
  static const kContentKey = 'content';
  static const kLangCodeKey = 'langCode';

  // Members
  final String id;
  final String name;
  final String langCode;
  final String content;

  Presentation({
    required this.id,
    required this.name,
    required this.langCode,
    required this.content,
  });

  factory Presentation.fromMap(Map<String, dynamic> map) {
    final id = map[kIdKey] ?? '';
    final name = map[kNameKey] ?? '';
    final langCode = map[kLangCodeKey] ?? '';
    final content = map[kContentKey] ?? '';

    return Presentation(
      id: id,
      name: name,
      langCode: langCode,
      content: content,
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
