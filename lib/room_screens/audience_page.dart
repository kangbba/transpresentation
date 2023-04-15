import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/apis/text_to_speech_control.dart';
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
  final TextToSpeechControl textToSpeechControl = TextToSpeechControl.instance;
  TranslateByGoogleServer translateByGoogleServer = TranslateByGoogleServer();
  StreamSubscription<Presentation?>? _presentationSubscription;
  StreamSubscription<LanguageItem>? _languageSubscription;
  String curContent = '';
  late String curLangCode;

  @override
  void initState() {
    super.initState();
    translateByGoogleServer.initializeTranslateByGoogleServer();
    //회의내용 감지를 시작한다.
    listenToPresentationStream(_languageSelectControl.myLanguageItem);
    //언어를 바꿔서 설정할때 재호출한다.
    _languageSubscription = _languageSelectControl.languageItemStream.listen((currentLanguageItem) {
      print("currentLanguageItem 변경이 감지됨");
      curLangCode = currentLanguageItem.langCodeGoogleServer!;
      listenToPresentationStream(_languageSelectControl.myLanguageItem);
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
  // updateCurContentByFirstPresentation(LanguageItem languageItem) async{
  //   Presentation? firstPresentation = await widget.chatRoom!.presentationStream().first;
  //   if(firstPresentation != null){
  //     await updateCurContentByPresentation(firstPresentation, languageItem, false);
  //     print("첫 발표내용으로 해석해서 업데이트");
  //   }
  //   else{
  //     curContent = "아직 발표내용이 없습니다";
  //     print("아직 발표내용이 없습니다");
  //   }
  // }
  void listenToPresentationStream(LanguageItem languageItem) async {
    DateTime? previousUpdate;
    if(_presentationSubscription != null){
      _presentationSubscription!.cancel();
    }
    // await updateCurContentByFirstPresentation(languageItem!);
    _presentationSubscription = widget.chatRoom!.presentationStream().listen((presentation) async {
      if (presentation == null) {
        print("아직 presentation이 없습니다");
      }
      else{
        DateTime currentUpdate = DateTime.now();
        int diff = previousUpdate != null ? currentUpdate.difference(previousUpdate!).inMilliseconds : 0;
        print("presentation 내용 변경이 감지, 시간차이: ${diff}ms");
        bool useSpeak = diff != 0;
        updateCurContentByPresentation(presentation, languageItem, true);
        //TODO
        //중복없이 text to speech 호출하기.

        previousUpdate = currentUpdate;
      }
    },
    onError: (error) {
      print('presentationStream 에러 발생: $error');
    });
  }
  updateCurContentByPresentation(Presentation presentation, LanguageItem languageItem, bool useSpeak) async{
    if(presentation.content.isEmpty || presentation.content == ';'){
      print("최근 번역 언어가 내용이 없으므로 아무것도 하지 않겠음");
      return;
    }
    bool isFinalResult = presentation.content.contains(';');
    String strToTranslate = presentation.content.replaceAll(';', '.');
    String? translatedText = await translateByGoogleServer.textTranslate(strToTranslate, languageItem.langCodeGoogleServer!);
    if(translatedText == null){
      print("응답에 오류가있으므로 아무것도 하지 않겠음");
      return;
    }
    curContent = translatedText;
    if(mounted){
      setState(() {

      });
    }
    if(isFinalResult && useSpeak){
      print("isFinalResult");
      await textToSpeechControl.speak(translatedText, false);
    }
    else{
      print("not isFinalResult");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (curContent.isEmpty) {
      return const Center(child: Text('발표 내용이 없습니다'));
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenHeight * 0.032; // 디바이스 높이의 3%에 해당하는 폰트 크기
    final height = screenHeight / 2; // 디바이스 높이의 1/3에 해당하는 height
    return Center(child: Text(curContent, style: TextStyle(fontSize: fontSize),));
    return AutoScrollableText(content: curContent, textStyle: TextStyle(fontSize: fontSize), bottomPadding: height / 3,);
  }

}
