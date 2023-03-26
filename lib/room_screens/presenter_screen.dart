import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:transpresentation/apis/speech_recognition_control.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import '../classes/chat_room.dart';
import '../classes/presentation.dart';
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
          const SayneSeparator(color: Colors.black54, height: 0.3, top: 16, bottom: 16),
          Text(accumStr + tmpStr),
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

  listeningLoopingRoutine(String speechLocaleID) async {
    accumStr = '';
    while(isRecording){
      accumStr += " ";
      String newSentence = await listeningRoutine(speechLocaleID);
      accumStr += newSentence;
      print("$newSentence");
    }
  }

  Future<String> listeningRoutine(String speechLocaleID) async {

    tmpStr = '';
    // setVol(androidVol: 0, iOSVol: 0.0, showVolumeUI: false);
    SpeechRecognitionControl speechRecognitionControl = SpeechRecognitionControl();
    speechRecognitionControl.transcription = '';
    speechRecognitionControl.activateSpeechRecognizer();
    speechRecognitionControl.start(speechLocaleID);
    while (isRecording) {
      if(speechRecognitionControl.transcription.isNotEmpty) {
        tmpStr = speechRecognitionControl.transcription;
      }
      setState(() {

      });
      // if(!_speechToTextControl.speechToText.isListening)
      await Future.delayed(Duration(milliseconds: 0));
      if(speechRecognitionControl.isCompleted)
      {
        // for(int i = 0 ; i < 100 ; i ++){
        //   await Future.delayed(Duration(milliseconds: 10));
        // }
        // print("speechRecognitionControl.isListening가 false이기 때문에 listening routine 탈출..");
        // print(speechRecognitionControl.transcription);
        break;
      }
    }
    speechRecognitionControl.stop();
    tmpStr = speechRecognitionControl.transcription;
    return tmpStr;
  }
}
