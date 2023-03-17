import 'package:flutter/material.dart';

class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({Key? key}) : super(key: key);

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Icon(Icons.add)),
        Expanded(child: Icon(Icons.add)),
      ],
    );
  }
}
