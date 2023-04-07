import 'dart:async';

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

  final StreamController<List<String>> _sentencedController = StreamController();
  Stream<List<String>> get sentencedStream => _sentencedController.stream;
  List<String> _sentenced = [];
  List<String> get sentenced => _sentenced;
  set sentenced(List<String> value) {
    _sentenced = value;
    _sentencedController.add(value);
    notifyListeners();
  }

  final StreamController<String> _recentSentenceController = StreamController();
  Stream<String> get recentSentenceStream => _recentSentenceController.stream;
  String _recentSentence = '';
  String get recentSentence => _recentSentence;
  set recentSentence(String value) {
    _recentSentence = value;
    _recentSentenceController.add(value);
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
  void listen(String localeId) {
    isListening = true;
    _speech.listen(
        localeId: localeId,
        onResult: (result) {
          bool b = result.finalResult;
          String recognizedWords = result.recognizedWords;
          if (recognizedWords.endsWith("니다")) {
            _recentSentence += "$recognizedWords.";
            _recentSentenceController.add(_recentSentence);
            sentenced.add(_recentSentence);
            _sentencedController.add(sentenced);
            sentenced = [];
            _recentSentence = '';
          } else {
            sentenced.add(recognizedWords);
            _recentSentence += recognizedWords;
            _recentSentenceController.add(_recentSentence);
          }
          if (b) {
            print("FINAL RESULT");
          }
        },
        onSoundLevelChange: (level) {
          //  print('sound level stream: $level');
        }
    );
  }


  stopListen(){
    isListening = false;
    _speech.stop();
    sentenced = [];
    recentSentence = '';
  }

  void disposeSpeechToText() {
    _sentencedController.close();
    _recentSentenceController.close();
    super.dispose();
  }
}
