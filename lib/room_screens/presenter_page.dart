import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:transpresentation/apis/speech_to_text_control.dart';
import 'package:transpresentation/apis/translate_by_googleserver.dart';
import 'package:transpresentation/classes/auth_provider.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import 'package:transpresentation/room_screens/auto_scrollable_text.dart';
import '../apis/text_to_speech_control.dart';
import '../classes/chat_room.dart';
import '../classes/language_select_control.dart';
import '../helper/sayne_separator.dart';

class PresenterPage extends StatefulWidget {
  final ChatRoom chatRoom;

  const PresenterPage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  _PresenterPageState createState() => _PresenterPageState();
}

class _PresenterPageState extends State<PresenterPage> {
  final LanguageSelectControl _languageSelectControl = LanguageSelectControl.instance;
  SpeechToTextControl speechToTextControl = SpeechToTextControl();
  bool isRecording = false;

  StreamSubscription? subs;
  final _authProvider = AuthProvider.instance;
  String recentStr = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initAudioStreamType();
    speechToTextControl.init();
    subs = widget.chatRoom.hostStream().listen((host) {
      if(_authProvider.curUser == null){
        print("curUser가 null이 되었다");
      }
      if(host.uid != _authProvider.curUser!.uid){
        print("내가 호스트가 아니게 되었다.");
      }
    });
  }
  @override
  void dispose() {
    isRecording = false;
    speechToTextControl.stopListen();

    if(subs!=null){
      subs!.cancel();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenHeight * 0.032; // 디바이스 높이의 3%에 해당하는 폰트 크기
    final height = screenHeight / 2; // 디바이스 높이의 1/3에 해당하는 height
    return Column(
      children: [
        Expanded(flex : 1, child: Center(child: Text(recentStr, style : TextStyle(fontSize: fontSize),))),
        // AutoScrollableText(content: recentStr, textStyle: TextStyle(fontSize: 18), bottomPadding: 100),
        SizedBox(
            height: 70,
            child: Center(child: _audioRecordBtn())),
      ],
    );
  }
  Widget _audioRecordBtn() {
    return
      RippleAnimation(
          color: Colors.blue,
          delay: const Duration(milliseconds: 200),
          repeat: true,
          minRadius: isRecording ? 35 : 0,
          ripplesCount: 8,
          duration: const Duration(milliseconds: 6 * 300),
          child:ElevatedButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(55, 55)),
              shape: MaterialStateProperty.all(CircleBorder()),
              backgroundColor: MaterialStateProperty.all(Colors.redAccent[200] ),
            ),
            onPressed: () async {
              setState(() {
                if (Platform.isAndroid) {
                  sayneToast("해당 기기는 발표자를 지원하지 않습니다");
                  return;
                }
                isRecording = !isRecording;
                if(isRecording){
                  listeningLoopingRoutine();
                }
                else{
                }
              });
            },
            child: isRecording ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white) : Icon(Icons.mic, color:  Colors.white, size: 33,),
          )
      ) ;
  }
  listeningLoopingRoutine() async{
    recentStr = '';
    int index = 0;
    while(true){
      index++;
      print("$index 회차반복");
      LanguageItem languageItem = _languageSelectControl.myLanguageItem;
      await listeningRoutine(speechToTextControl, languageItem);
      if(!isRecording){
        break;
      }
      await TextToSpeechControl.instance.speak(recentStr);
      await Future.delayed(const Duration(milliseconds: 2000));
    }
  }
  listeningRoutine(SpeechToTextControl speechToTextControl, LanguageItem languageItem) async{
    speechToTextControl = SpeechToTextControl();
    bool isInitialized = await speechToTextControl.init();
    if(!isInitialized){
      return;
    }
    speechToTextControl.recentSentence = '';
    speechToTextControl.startListen(languageItem.sttLangCode!);
    int delayMs = 50;
    //첫 마디를 대기한다.
    int notRefreshedTotalTime = 0;
    while(isRecording){
      if(speechToTextControl.recentSentence.isNotEmpty){
        print("첫마디 입력성공");
        break;
      }
      print("첫 마디 대기중");
      await Future.delayed(const Duration(milliseconds: 10));
    }
    recentStr = '';
    while(isRecording){
      if(recentStr != speechToTextControl.recentSentence) {
        notRefreshedTotalTime = 0;
        recentStr = speechToTextControl.recentSentence;
        widget.chatRoom.updatePresentation(languageItem.sttLangCode!, recentStr);
        setState(() {});
      }
      else{
        notRefreshedTotalTime += delayMs;
        print("비갱신 시간 : $notRefreshedTotalTime");
        if(notRefreshedTotalTime > 1000){
          print("이 문장 break");
          break;
        }
      }
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    widget.chatRoom.updatePresentation(languageItem.sttLangCode!, '$recentStr;');
    setState(() {});
    speechToTextControl.stopListen();
  }


// listeningRoutine(String langCode) async {
  //
  //   speechToTextControl = SpeechToTextControl();
  //   recentStr = '';
  //   bool isInitialized = await speechToTextControl.init();
  //   if(!isInitialized) {
  //     sayneToast("아직 리스닝이 초기화되지 않았습니다");
  //     return;
  //   }
  //   speechToTextControl.listen(langCode);
  //   speechToTextControl.recentSentenceStream.listen((recentSentence) {
  //     setState(() {
  //       print("갱신중");
  //       recentStr = recentSentence;
  //       widget.chatRoom.updatePresentation(langCode, recentStr);
  //     });
  //   });
  // }

}
