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
  String accumStr = '';
  String tmpStr = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initAudioStreamType();
    speechToTextControl.init();
  }
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    print(accumStr + tmpStr);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.languageSelectControl),
      ],
      child: Consumer<LanguageSelectControl>(
        builder: (context, languageControl, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      accumStr + tmpStr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20,),
                    ),
                  ),
                ),
                const SayneSeparator(color: Colors.black54, height: 0.3, top: 16, bottom: 16),

                _audioRecordBtn(),
              ],
            ),
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
    accumStr = '';
    bool isInitialized = await speechToTextControl.init();
    if(!isInitialized){
      sayneToast("아직 리스닝이 초기화되지 않았습니다");
    }
    speechToTextControl.listen(langCode);
    String previousStr = '';
    while(true){
      if(!isRecording){
        break;
      }
      if(previousStr != speechToTextControl.text){
        previousStr = accumStr;
        accumStr = speechToTextControl.text;
        print("새로운 결과 업로드 $accumStr");
        widget.chatRoom.updatePresentation(langCode, accumStr);
        setState(() {

        });
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    speechToTextControl.stopListen();
  }


}
