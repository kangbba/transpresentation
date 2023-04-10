import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/helper/sayne_separator.dart';

import '../apis/translate_by_googleserver.dart';
import '../classes/chat_room.dart';
import '../classes/language_select_control.dart';
import '../classes/presentation.dart';
import '../screens/language_select_screen.dart';
import 'auto_scrollable_text.dart';
import 'content_pages.dart';

class AudiencePage extends StatefulWidget {
  final ChatRoom chatRoom;
  const AudiencePage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<AudiencePage> createState() => _AudiencePageState();
}

class _AudiencePageState extends State<AudiencePage> {

  final LanguageSelectControl _languageSelectControl = LanguageSelectControl.instance;
  TranslateByGoogleServer translateByGoogleServer = TranslateByGoogleServer();
  StreamSubscription<Presentation?>? _presentationSubscription;
  StreamSubscription<LanguageItem>? _languageSubscription;
  String curContent = '';
  late String curLangCode;

  @override
  void initState() {
    super.initState();
    translateByGoogleServer.initializeTranslateByGoogleServer();
    LanguageItem curLanguageItem = _languageSelectControl.myLanguageItem;
    //회의내용 감지를 시작한다.
    curLangCode = _languageSelectControl.myLanguageItem.langCodeGoogleServer!;
    listenToPresentationStream(curLangCode);
    //언어를 바꿔서 설정할때 재호출한다.
    _languageSubscription = _languageSelectControl.languageItemStream.listen((currentLanguageItem) {
      print("currentLanguageItem 변경이 감지됨");
      curLangCode = currentLanguageItem.langCodeGoogleServer!;
      listenToPresentationStream(curLangCode);
    });
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
  }
  void listenToPresentationStream(String langCode) async {
    DateTime? previousUpdate;
    if(_presentationSubscription != null){
      _presentationSubscription!.cancel();
    }
    await updateCurContentByFirstPresentation(_languageSelectControl.myLanguageItem.langCodeGoogleServer!);
    _presentationSubscription = widget.chatRoom!.presentationStream().listen((presentation) async {
      if (presentation == null) {
        print("아직 presentation이 없습니다");
      }
      else{
        DateTime currentUpdate = DateTime.now();
        int diff = previousUpdate != null ? currentUpdate.difference(previousUpdate!).inMilliseconds : 0;
        print("presentation 내용 변경이 감지, 시간차이: ${diff}ms");
        if(diff > 10){
          updateCurContentByPresentation(presentation, langCode);
        }
        previousUpdate = currentUpdate;
      }
    },
    onError: (error) {
      print('presentationStream 에러 발생: $error');
    });
  }
  updateCurContentByPresentation(Presentation presentation, String langCode) async{
    String? translatedText = await translateByGoogleServer.textTranslate(presentation.content, langCode);
    if(translatedText == null){
      print("응답에 오류가있으므로 아무것도 하지 않겠음");
      return;
    }
    curContent = translatedText;
    if(mounted){
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (curContent.isEmpty) {
      return const Center(child: Text('발표 내용이 없습니다'));
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenHeight * 0.03; // 디바이스 높이의 3%에 해당하는 폰트 크기
    final height = screenHeight / 2; // 디바이스 높이의 1/3에 해당하는 height
    return AutoScrollableText(content: curContent, textStyle: TextStyle(fontSize: fontSize), bottomPadding: height / 3,);
  }

}
