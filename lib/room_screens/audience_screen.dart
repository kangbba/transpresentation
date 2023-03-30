import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

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
  void initState() {
    super.initState();
  }

  @override
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
                if(snapshot == null){
                  return Container();
                }
                if (snapshot.content.isEmpty) {
                  return Text("발표자가 발표를 준비중입니다");
                }
                return Center(
                  child: Text(
                    snapshot.content!,
                    style: TextStyle(fontSize: 20),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 50,)
        ],
      ),
    );
  }




  @override
  void dispose() {
    super.dispose();
  }
}
