import 'dart:async';
import 'dart:ffi';

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
  StreamSubscription<LanguageItem>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    translateByGoogleServer.initializeTranslateByGoogleServer();

    updateCurContentByFirstPresentation(_languageSelectControl.myLanguageItem.langCodeGoogleServer!);
    _languageSubscription = _languageSelectControl.languageItemStream.listen((currentLanguageItem) {
      print("currentLanguageItem 변경이 감지됨");
      listenToPresentationStream(currentLanguageItem.langCodeGoogleServer!);
    });
  }

  updateCurContentByFirstPresentation(String langCode) async{
    Presentation? firstPresentation = await widget.chatRoom!.presentationStream().first;
    if(firstPresentation != null){
      await updateCurContentByPresentation(firstPresentation, langCode);
      print("첫 발표내용으로 해석해서 업데이트");
    }
    else{
      curContent = "아직 발표내용이 없습니다";
      print("아직 발표내용이 없습니다");
    }
    setState(() {});
  }
  updateCurContentByPresentation(Presentation presentation, String langCode) async{
    String? translatedText = await translateByGoogleServer.textTranslate(presentation.content, langCode);
    curContent = translatedText ?? 'error';
    setState(() {

    });
  }
  void listenToPresentationStream(String langCode) async {
    if(_presentationSubscription != null){
      _presentationSubscription!.cancel();
    }
    await updateCurContentByFirstPresentation(_languageSelectControl.myLanguageItem.langCodeGoogleServer!);
    _presentationSubscription = widget.chatRoom!.presentationStream().listen((presentation) async {
      if (presentation != null) {
        print("presentation 내용 변경이 감지됨");
        await updateCurContentByPresentation(presentation, langCode);
      }
    },
    onError: (error) {
      print('presentationStream 에러 발생: $error');
    });
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
      child: Consumer<Presentation?>(
        builder: (context, snapshot, _) {
          if (snapshot == null) {
            return Center(
              child: Text('발표자가 발표를 준비중입니다. '),
            );
          } else {
            return Container(
              alignment: Alignment.topLeft,
              child: Text(
                curContent,
                style: TextStyle(fontSize: 20, color: Colors.black87, height: 1.5),
                maxLines: null,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    if(_presentationSubscription != null){
      _presentationSubscription!.cancel();
    }
    if(_languageSubscription != null){
      _languageSubscription!.cancel();
    }
    super.dispose();
  }
}
