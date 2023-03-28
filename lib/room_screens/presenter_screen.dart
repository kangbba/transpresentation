
import 'package:flutter/material.dart';
import 'package:lecle_volume_flutter/lecle_volume_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:transpresentation/apis/speech_to_text_control.dart';
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
            height: 10,
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
      onPressed: () async {
        setState(() {
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
        widget.chatRoom.updatePresentation(accumStr);
        setState(() {

        });
      }
      await Future.delayed(Duration(milliseconds: 1));
    }
    speechToTextControl.stopListen();
  }


}
