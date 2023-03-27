import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class GoogleSpeechControl with ChangeNotifier {
  late stt.SpeechToText _speech;

  String _status = '';
  String get status{
    return _status;
  }
  set status(String str){
    _status = str;
    notifyListeners();
  }

  String _text = '';
  String get text{
    return _text;
  }
  set text(String str){
    _text = str;
    notifyListeners();
  }
  bool get isListening => _speech.isListening;

  // bool _isListening = false;
  // set isListening(bool value) {
  //   _isListening = value;
  //   notifyListeners();
  // }

  Future<bool> initialize(String langCode) async{
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );
    return available;
  }
  listen() {
    _speech.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(seconds: 120),
      pauseFor: Duration(seconds: 5),
      partialResults: true,
    );
  }
  void _onSpeechStatus(String str) {
    status = str;
  }

  void _onSpeechError(dynamic error) {
    print('onError: $error');
    print("///SPEECH ERROR!/// isListening : $isListening");
    _speech.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
    }
    text = result.recognizedWords;
    print("///_onSpeechResult!///");
  }

}
