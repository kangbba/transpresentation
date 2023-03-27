
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:lecle_volume_flutter/lecle_volume_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:transpresentation/apis/google_speech_control.dart';
import '../apis/speech_recognition_control.dart';
import '../classes/chat_room.dart';
import '../helper/sayne_separator.dart';

class PresenterScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const PresenterScreen({Key? key, required this.chatRoom}) : super(key: key);

  @override
  _PresenterScreenState createState() => _PresenterScreenState();
}

class _PresenterScreenState extends State<PresenterScreen> {
  final _textController = TextEditingController();
  bool isRecording = false;
  String accumStr = '';
  String tmpStr = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAudioStreamType();
  }
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSubmit() async{
    print("_onSubmit");

    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.chatRoom.updatePresentation(text);
    }
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '테스트',
              ),
              controller: _textController,
              style: TextStyle(fontSize: 30),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
          ),
          Text(accumStr + tmpStr),
          const SayneSeparator(color: Colors.black54, height: 0.3, top: 16, bottom: 16),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _onSubmit,
              child: const Text('Submit'),
            ),
          ),
          _audioRecordBtn(),
        ],
      ),
    );
  }

  Widget _audioRecordBtn() {
    return ElevatedButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(Size(55, 55)),
        shape: MaterialStateProperty.all(CircleBorder()),
        backgroundColor: MaterialStateProperty.all(Colors.cyan[800] ),
      ),
      onPressed: () async{
        isRecording = !isRecording;
        setState(() {
        });
        if(isRecording){
          listeningLoopingRoutine('ko_KR');
        }
        else{
        }
      },
      child: isRecording ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white) : Icon(Icons.mic, color:  Colors.white, size: 33,),
    );
  }
  listeningLoopingRoutine(String langCode) async{
    int i = 0;
    accumStr = '';
    while(true) {
      if(!isRecording) {
        break;
      }
      i++;
      print('$i 번째 : 새로운 시작');
      accumStr += await listeningRoutine(langCode);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }
  listeningRoutine(String speechLocaleID) async {
    //
    // setVol(androidVol: 0, iOSVol: 0.0, showVolumeUI: true);

    SpeechRecognitionControl speechRecognitionControl = SpeechRecognitionControl();
    speechRecognitionControl.transcription = '';
    speechRecognitionControl.activateSpeechRecognizer();
    speechRecognitionControl.start(speechLocaleID);
    while (true) {
      // if(!_speechToTextControl.speechToText.isListening)
      await Future.delayed(Duration(milliseconds: 0));
      if(!isRecording){
        print("레코드 인터럽트로 인한 break");
        break;
      }
      if(speechRecognitionControl.transcription.isNotEmpty) {
        tmpStr = speechRecognitionControl.transcription;
        setState(() {

        });
      }
      if(speechRecognitionControl.isCompleted)
      {

        print("speechRecognitionControl.isListening가 false이기 때문에 listening routine 탈출..");
        print(speechRecognitionControl.transcription);
        for(int i = 0 ; i < 50 ; i ++){
          tmpStr = speechRecognitionControl.transcription;
          setState(() {

          });
          await Future.delayed(Duration(milliseconds: 10));
        }
        break;
      }
    }
    speechRecognitionControl.stop();
    tmpStr = '';

    setState(() {

    });

    return speechRecognitionControl.transcription;
  }
  // GoogleSpeechControl speechControl = GoogleSpeechControl();
  // listeningLoopingRoutine(String langCode) async{
  //   int i = 0;
  //   speechControl.text = '';
  //   bool ready =  await speechControl.initialize(langCode);
  //   while(true) {
  //     if(!isRecording) {
  //       break;
  //     }
  //     i++;
  //     print('$i 번째 : 새로운 시작');
  //     await listeningRoutine();
  //     await Future.delayed(Duration(milliseconds: 10));
  //   }
  // }
  // Future<void> listeningRoutine() async {
  //   while(!speechControl.isListening){
  //     print("대기중");
  //     speechControl.listen();
  //     await Future.delayed(Duration(milliseconds: 1));
  //   }
  //   while (true) {
  //     if(!isRecording){
  //       print('break1');
  //       break;
  //     }
  //     if(!speechControl.isListening){
  //       print('break2"');
  //       break;
  //     }
  //     accumStr = speechControl!.text;
  //     setState(() {
  //     });
  //     await Future.delayed(Duration(milliseconds: 1));
  //   }
  // }



  Future<void> initAudioStreamType() async {
    await Volume.initAudioStream(AudioManager.streamNotification);

  }
  setVol({int androidVol = 0, double iOSVol = 0.0, bool showVolumeUI = true}) async {
    await Volume.setVol(
      androidVol: androidVol,
      iOSVol: iOSVol,
      showVolumeUI: showVolumeUI,
    );
  }
}
