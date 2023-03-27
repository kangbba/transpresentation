import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../classes/chat_room.dart';
import '../classes/presentation.dart';

class AudienceScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const AudienceScreen({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<AudienceScreen> createState() => _AudienceScreenState();
}

class _AudienceScreenState extends State<AudienceScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<Presentation?>(
            stream: widget.chatRoom.presentationStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return  Center(child: Text(snapshot.data!.presentationMsg ?? "", style: TextStyle(fontSize: 20),));
              }
              else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              else
              {
                return Text("발표자가 발표를 준비중입니다");
              }
            },
          ),
        ),
        SizedBox(height: 50,)
      ],
    );
  }
}
