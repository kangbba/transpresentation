import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class SpeechToTextControl with ChangeNotifier {

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  bool get isListening => _isListening;
  set isListening(bool value) {
    _isListening = value;
    notifyListeners();
  }
  String _text = '';
  String get text => _text;
  set text(String value) {
    _text = value;
    notifyListeners();
  }
  Future<bool> init() async{
    if(isListening){
      print("이미 듣고있음");
      return false;
    }
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('status: $status');
      },
      onError: (error) {
        print('error: $error');
      },
    );
    return available;
  }
  listen() async {
    isListening = true;
    _speech.listen(
        onResult: (result) {
          text = result.recognizedWords;
        });
  }
  stopListen(){
    isListening = false;
    _speech.stop();
  }
}