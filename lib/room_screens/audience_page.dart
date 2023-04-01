import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../classes/chat_room.dart';
import '../classes/presentation.dart';

class AudiencePage extends StatefulWidget {
  final ChatRoom chatRoom;

  const AudiencePage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<AudiencePage> createState() => _AudiencePageState();
}

class _AudiencePageState extends State<AudiencePage> {
  late StreamSubscription<Presentation?> _presentationSubscription;
  String curContent = '';

  @override
  void initState() {
    super.initState();
    listenToPresentationStream();
  }
  void listenToPresentationStream() async {
    _presentationSubscription = widget.chatRoom!.presentationStream().listen(
          (presentation) async {
        if (presentation != null) {
          setState(() {
            curContent = presentation.content;
          });
        }
      },
      onError: (error) {
        print('presentationStream 에러 발생: $error');
      },
    );
  }



// 새로운 값을 처리하는 함수
  void handleNewValue(newValue) {
    // 새로운 값을 처리하는 코드
  }

  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Presentation?>(
          create: (_) => widget.chatRoom!.presentationStream(),
          initialData: null,
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: Consumer<Presentation?>(
              builder: (context, snapshot, _) {
                if (snapshot == null) {
                  return Center(
                    child: Text('발표자가 발표를 준비중입니다. '),
                  );
                }
                else{
                  return Text(curContent);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _presentationSubscription.cancel();
    super.dispose();
  }
}
