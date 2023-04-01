
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lecle_volume_flutter/lecle_volume_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:transpresentation/apis/speech_to_text_control.dart';
import 'package:transpresentation/helper/sayne_dialogs.dart';
import '../classes/chat_room.dart';
import '../helper/sayne_separator.dart';

class PresenterPage extends StatefulWidget {
  final ChatRoom chatRoom;

  const PresenterPage({Key? key, required this.chatRoom}) : super(key: key);

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
    initAudioStreamType();
    speechToTextControl.init();
  }
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // void _onSubmit() async{
  //   print("_onSubmit");
  //
  //   final text = _textController.text.trim();
  //   if (text.isNotEmpty) {
  //     widget.chatRoom.updatePresentation(text);
  //   }
  //   _textController.clear();
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '마이크 버튼을 눌러 회의 시작',
              ),
              controller: _textController,
              style: TextStyle(fontSize: 30),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              readOnly: true,
            ),
          ),
          Text(accumStr + tmpStr),
          const SayneSeparator(color: Colors.black54, height: 0.3, top: 16, bottom: 16),
          // SizedBox(
          //   height: 10,
          //   child: ElevatedButton(
          //     onPressed: _onSubmit,
          //     child: const Text('Submit'),
          //   ),
          // ),
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
            listeningRoutine('ko_KR');
          }
          else{
          }
        });
      },
      child: isRecording ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white) : Icon(Icons.mic, color:  Colors.white, size: 33,),
    );
  }
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

  listeningRoutine(String langCode) async{
    accumStr = '';
    bool isInitialized = await speechToTextControl.init();
    if(!isInitialized){
      sayneToast("아직 리스닝이 초기화되지 않았습니다");
    }
    speechToTextControl.listen();
    String previousStr = '';
    while(true){
      if(!isRecording){
        break;
      }
      if(previousStr != speechToTextControl.text){
        previousStr = accumStr;
        accumStr = speechToTextControl.text;
        print("새로운 결과 업로드 $accumStr");
        widget.chatRoom.updatePresentation('korea', accumStr);
        setState(() {

        });
      }
      await Future.delayed(Duration(milliseconds: 1));
    }
    speechToTextControl.stopListen();
  }


}
