import 'package:flutter/material.dart';

class PresenterScreen extends StatefulWidget {
  const PresenterScreen({Key? key}) : super(key: key);

  @override
  State<PresenterScreen> createState() => _PresenterScreenState();
}

class _PresenterScreenState extends State<PresenterScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Icon(Icons.mic),
    );
  }
}
