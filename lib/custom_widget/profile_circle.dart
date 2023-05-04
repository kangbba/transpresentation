
import 'package:flutter/material.dart';
import 'package:transpresentation/classes/user_model.dart';

class ProfileCircle extends StatefulWidget {
  const ProfileCircle({
    super.key,
    required this.userModel,
    required this.radius,
  });

  final UserModel userModel;
  final double radius;

  @override
  State<ProfileCircle> createState() => _ProfileCircleState();
}

class _ProfileCircleState extends State<ProfileCircle> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius * 0.68),
      child: Image(
        width: widget.radius * 2,
        height: widget.radius * 2,
        fit: BoxFit.cover,
        image: widget.userModel.photoURL.isEmpty
            ? const AssetImage('assets/default_icon.png')
            : NetworkImage(widget.userModel.photoURL) as ImageProvider<Object>,
      ),
    );
  }
}
