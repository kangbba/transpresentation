import 'dart:async';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:transpresentation/apis/speech_to_text_control.dart';
import 'package:transpresentation/classes/auth_provider.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import '../apis/text_to_speech_control.dart';
import '../classes/chat_room.dart';
import '../classes/language_select_control.dart';

class PresenterPage extends StatefulWidget {
  final ChatRoom chatRoom;
  final double presenterSpeakIdleLimit;

  const PresenterPage({Key? key, required this.chatRoom, required this.presenterSpeakIdleLimit}) : super(key: key);

  @override
  _PresenterPageState createState() => _PresenterPageState();
}
enum ListeningRoutineState{
  offRecognizing,
  waitingForFirstSentence,
  onRecognizing,
  speakingVoice,
}
class _PresenterPageState extends State<PresenterPage> {
  SpeechToTextControl speechToTextControl = SpeechToTextControl();
  TextToSpeechControl textToSpeechControl = TextToSpeechControl();

  final LanguageSelectControl _languageSelectControl = LanguageSelectControl.instance;
  final AuthProvider _authProvider = AuthProvider.instance;
  final assetsAudioPlayer = AssetsAudioPlayer();

  StreamSubscription<LanguageItem>? _languageSubscription;
  ListeningRoutineState listeningRoutineState = ListeningRoutineState.offRecognizing;
  bool recordBtnState = false;
  StreamSubscription? hostStreamSubscription;

  String recentStr = '';
  String get tutorialText{
    switch(listeningRoutineState){
      case ListeningRoutineState.offRecognizing:
        return "마이크 버튼을 눌러 음성인식을 시작하세요";
      case ListeningRoutineState.waitingForFirstSentence:
        return "지금 말하세요!";
      case ListeningRoutineState.onRecognizing:
        return "인식중입니다";
      case ListeningRoutineState.speakingVoice:
        return "목소리를 재생중입니다.";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initAudioStreamType();
    speechToTextControl.init();
    hostStreamSubscription = widget.chatRoom.hostStream().listen((host) {
      if(_authProvider.curUser == null){
        print("curUser가 null이 되었다");
      }
      if(host.uid != _authProvider.curUser!.uid){
        print("내가 호스트가 아니게 되었다.");
      }
    });
    _languageSubscription = _languageSelectControl.languageItemStream.listen((currentLanguageItem) {
      print("currentLanguageItem 변경이 감지됨");
      recordBtnState = false;
    });
  }
  @override
  void dispose() {
    recordBtnState = false;
    speechToTextControl.stopListen();

    if(_languageSubscription != null){
      _languageSubscription!.cancel();
    }
    if(hostStreamSubscription!=null){
      hostStreamSubscription!.cancel();
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
            height: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _audioRecordBtn(),
                SizedBox(height : 4),
                Text(tutorialText, style: TextStyle(fontSize: 15),),
              ],
            )),
      ],
    );
  }
  Widget _audioRecordBtn() {
    return
      RippleAnimation(
          color: Colors.blue,
          delay: const Duration(milliseconds: 200),
          repeat: true,
          minRadius: recordBtnState ? 35 : 0,
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
                recordBtnState = !recordBtnState;
                if(recordBtnState){
                  listeningLoopingRoutine();
                }
                else{
                }
              });
            },
            child: recordBtnState ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white) : Icon(Icons.mic, color:  Colors.white, size: 33,),
          )
      ) ;
  }
  listeningLoopingRoutine() async{
    recentStr = '';
    int index = 0;
    playOnce('assets/ding.mp3');
    while(true){
      if(!recordBtnState){
        break;
      }
      setState(() {
        listeningRoutineState = ListeningRoutineState.offRecognizing;
      });
      index++;
      print("$index 회차반복");
      LanguageItem languageItem = _languageSelectControl.myLanguageItem;
      bool success = await listeningRoutine(languageItem);
      if(!success || !recordBtnState){
        break;
      }
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        listeningRoutineState = ListeningRoutineState.speakingVoice;
      });
      try{
        await textToSpeechControl.speak(recentStr, true);
      }catch(e){
        print("tts 에러코드 $e");
      }
    }
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      listeningRoutineState = ListeningRoutineState.offRecognizing;
    });
  }

  //마이크 누른상태로 host화면 벗어날때 dispose호출되어야하는데 그거 확인해야한다.

  Future<bool> listeningRoutine(LanguageItem languageItem) async{
    speechToTextControl = SpeechToTextControl();
    bool isInitialized = await speechToTextControl.init();
    if(!isInitialized){
      return false;
    }
    speechToTextControl.recentSentence = '';
    speechToTextControl.startListen(languageItem.sttLangCode!);
    int delayMs = 100;
    //첫 마디를 대기한다.
    double presenterSpeakIdleAcumTime = 0;
    setState(() {
      listeningRoutineState = ListeningRoutineState.waitingForFirstSentence;
    });
    while(recordBtnState){
      if(speechToTextControl.recentSentence.isNotEmpty){
        print("첫마디 입력성공");
        break;
      }
      print("첫 마디 대기중");
      await Future.delayed(const Duration(milliseconds: 10));
    }
    setState(() {
      listeningRoutineState = ListeningRoutineState.onRecognizing;
    });
    recentStr = '';
    while(recordBtnState){
      if(recentStr != speechToTextControl.recentSentence) {
        presenterSpeakIdleAcumTime = 0;
        recentStr = speechToTextControl.recentSentence;
        widget.chatRoom.updatePresentation(languageItem.sttLangCode!, recentStr);
        setState(() {});
      }
      else{
        presenterSpeakIdleAcumTime += delayMs;
        print("비갱신 시간 : $presenterSpeakIdleAcumTime");
        if(presenterSpeakIdleAcumTime > widget.presenterSpeakIdleLimit){
          print("이 문장 break");
          break;
        }
      }
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    widget.chatRoom.updatePresentation(languageItem.sttLangCode!, '$recentStr;');
    await speechToTextControl.stopListen();
    setState(() {
      listeningRoutineState = ListeningRoutineState.offRecognizing;
    });
    return true;
  }

  Future<void> playOnce(String audioPath) async {
    AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
    await assetsAudioPlayer.open(Audio(audioPath));

    assetsAudioPlayer.playlistFinished.listen((event) {
      assetsAudioPlayer.stop();
    });
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
