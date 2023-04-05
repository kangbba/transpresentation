import 'package:flutter/material.dart';
import 'package:transpresentation/classes/user_model.dart';

import 'profile_circle.dart';

class ProfileCircles extends StatelessWidget {
  const ProfileCircles({
    Key? key,
    required this.userModels,
  }) : super(key: key);

  final List<UserModel> userModels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final userModel in userModels)
          ProfileCircle(userModel: userModel, radius: 5,),
      ],
    );
  }
}
