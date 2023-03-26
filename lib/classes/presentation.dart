import 'package:cloud_firestore/cloud_firestore.dart';

class Presentation {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? createdBy;
  final String? presentationMsg;

  Presentation({
    required this.id,
    required this.name,
    required this.createdAt,
    this.createdBy,
    this.presentationMsg,
  });

  factory Presentation.fromMap(Map<String, dynamic> map) {
    final createdAtDate = map['createdAt'] as Timestamp?;
    final createdAt = createdAtDate?.toDate() ?? DateTime.now();

    return Presentation(
      id: map['id'],
      name: map['name'],
      createdAt: createdAt,
      createdBy: map['createdBy'],
      presentationMsg: map['presentationMsg'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'presentationMsg': presentationMsg,
    };
  }


}
