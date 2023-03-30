
import 'package:flutter/material.dart';
import 'package:transpresentation/classes/user_model.dart';

class ProfileCircle extends StatefulWidget {
  const ProfileCircle({
    super.key,
    required this.userModel,
  });

  final UserModel userModel;

  @override
  State<ProfileCircle> createState() => _ProfileCircleState();
}

class _ProfileCircleState extends State<ProfileCircle> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: widget.userModel.photoURL.isEmpty
          ? const AssetImage('assets/default_icon.png') : NetworkImage(widget.userModel.photoURL) as ImageProvider<Object>,
    );
  }
}