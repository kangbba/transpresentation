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
import '../classes/chat_room.dart';
import '../classes/language_select_control.dart';
import '../helper/sayne_separator.dart';

class PresenterPage extends StatefulWidget {
  final ChatRoom chatRoom;
  final LanguageSelectControl languageSelectControl;

  const PresenterPage({Key? key, required this.chatRoom, required this.languageSelectControl}) : super(key: key);

  @override
  _PresenterPageState createState() => _PresenterPageState();
}

class _PresenterPageState extends State<PresenterPage> {
  SpeechToTextControl speechToTextControl = SpeechToTextControl();
  bool isRecording = false;


  StreamSubscription? subs;
  final _authProvider = AuthProvider.instance;
  String recentStr = '';
  String recentTranslatedStr = '';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.languageSelectControl),
      ],
      child: Consumer<LanguageSelectControl>(
        builder: (context, languageControl, child) {
          return Column(
            children: [
              AutoScrollableText(content: recentStr, textStyle: TextStyle(fontSize: 18), bottomPadding: 100),
              const SayneSeparator(color: Colors.black45, height: 0.3, top: 8, bottom: 8),
              AutoScrollableText(content: recentTranslatedStr, textStyle: TextStyle(fontSize: 18), bottomPadding: 100),
              SizedBox(
                  height: 80,
                  child: _audioRecordBtn()),
            ],
          );
        },
      ),
    );
  }
  Widget _audioRecordBtn() {
    return
      RippleAnimation(
          color: Colors.blue,
          delay: const Duration(milliseconds: 200),
          repeat: true,
          minRadius: isRecording ? 35 : 0,
          ripplesCount: 6,
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
                  listeningRoutine(widget.languageSelectControl.myLanguageItem.speechLocaleId!);
                }
                else{

                }
              });
            },
            child: isRecording ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white) : Icon(Icons.mic, color:  Colors.white, size: 33,),
          )
      ) ;
  }
  listeningRoutine(String langCode) async{
    recentStr = '';
    speechToTextControl.recentSentence = '';
    widget.chatRoom.updatePresentation(langCode, '');

    bool isInitialized = await speechToTextControl.init();
    if(!isInitialized){
      return;
    }
    else{

    }
    speechToTextControl.listen(langCode);
    int delayMs = 50;
    //첫 마디를 대기한다.
    while(isRecording){
      if(speechToTextControl.recentSentence.isNotEmpty){
        print("첫마디 입력성공");
        break;
      }
      print("첫 마디 대기중");
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    int notRefreshedTotalTime = 0;
    while(isRecording){
      if(recentStr != speechToTextControl.recentSentence) {
        notRefreshedTotalTime = 0;
        recentStr = speechToTextControl.recentSentence;
        widget.chatRoom.updatePresentation(langCode, recentStr);
        setState(() {});
      }
      else{
        notRefreshedTotalTime += delayMs;
        print("비갱신 시간 : $notRefreshedTotalTime");
        if(notRefreshedTotalTime > 2000){
          isRecording = false;
        }
      }
      await Future.delayed(Duration(milliseconds: delayMs));
    }
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
