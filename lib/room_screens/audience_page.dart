import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../apis/translate_by_googleserver.dart';
import '../classes/chat_room.dart';
import '../classes/language_select_control.dart';
import '../classes/presentation.dart';
import '../screens/language_select_screen.dart';

class AudiencePage extends StatefulWidget {
  final ChatRoom chatRoom;
  const AudiencePage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<AudiencePage> createState() => _AudiencePageState();
}

class _AudiencePageState extends State<AudiencePage> {
  StreamSubscription<Presentation?>? _presentationSubscription;
  String curContent = '';
  final LanguageSelectControl _languageSelectControl = LanguageSelectControl.instance;
  TranslateByGoogleServer translateByGoogleServer = TranslateByGoogleServer();
  @override
  void initState() {
    super.initState();
    translateByGoogleServer.initializeTranslateByGoogleServer();
    listenToPresentationStream(_languageSelectControl.myLanguageItem.langCodeGoogleServer!);
    languageCodeChangeDetector();
  }
  void languageCodeChangeDetector() async {
    String previousLanguageCode = _languageSelectControl.myLanguageItem.langCodeGoogleServer!;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100));
      String currentLanguageCode = _languageSelectControl.myLanguageItem.langCodeGoogleServer!;
      if (previousLanguageCode != currentLanguageCode) {
        listenToPresentationStream(currentLanguageCode);
        previousLanguageCode = currentLanguageCode;
      }
    }
  }

  void listenToPresentationStream(String langCode) async {
    if(_presentationSubscription != null){
      _presentationSubscription!.cancel();
    }
    Presentation? firstPresentation = await widget.chatRoom!.presentationStream().first;
    if(firstPresentation != null){
      curContent = firstPresentation.content;
    }
    else{
      curContent = "아직 발표내용이 없습니다";
    }
    _presentationSubscription = widget.chatRoom!.presentationStream().listen((presentation) async {
            print("이 루틴 작동중");
        if (presentation != null) {
          String? translatedText = await translateByGoogleServer.textTranslate(presentation.content, langCode);
          curContent = translatedText ?? 'error';
          setState(() {});
        }
      },
      onError: (error) {
        print('presentationStream 에러 발생: $error');
      },
    );
  }
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Presentation?>(
          create: (_) => widget.chatRoom!.presentationStream(),
          initialData: null,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    return Center(child: Text(curContent, style: TextStyle(fontSize: 20),));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if(_presentationSubscription != null){
      _presentationSubscription!.cancel();
    }
    super.dispose();
  }


}
