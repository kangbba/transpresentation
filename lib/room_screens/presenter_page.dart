import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:transpresentation/apis/speech_to_text_control.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
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
  final _textController = TextEditingController();
  SpeechToTextControl speechToTextControl = SpeechToTextControl();
  bool isRecording = false;
  String recentStr = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initAudioStreamType();
    speechToTextControl.init();
  }
  @override
  void dispose() {
    isRecording = false;
    speechToTextControl.stopListen();
    _textController.dispose();
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
              Expanded(
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    recentStr,
                    style: TextStyle(fontSize: 20, color: Colors.black87, height: 1.5),
                    maxLines: null,
                  ),
                ),
              ),
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
  listeningRoutine(String langCode) async{
    widget.chatRoom.updatePresentation(langCode, '');
    recentStr = '';
    sayneLoadingDialog(context, "message");
    bool isInitialized = await speechToTextControl.init();
    if(!isInitialized){
      sayneConfirmDialog(context, "", "아직 리스닝이 초기화되지 않았습니다");
      return;
    }
    Navigator.of(context).pop();
    speechToTextControl.listen(langCode);
    int notRefreshedTotalTime = 10;
    int delayMs = 10;
    while(true){
      if(!isRecording){
        break;
      }
      if(recentStr != speechToTextControl.recentSentence) {
        notRefreshedTotalTime = 0;
        recentStr = speechToTextControl.recentSentence;
        widget.chatRoom.updatePresentation(langCode, recentStr);
        setState(() {});
      }
      else{
        notRefreshedTotalTime += delayMs;
        print("비갱신 시간 : $notRefreshedTotalTime");
      }
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    speechToTextControl.stopListen();
  }


}
