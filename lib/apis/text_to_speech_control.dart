import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechControl extends ChangeNotifier{

  FlutterTts flutterTts = FlutterTts();
  initTextToSpeech() async
  {
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }
  _changeLanguage(String langCode) async
  {
    List<String> separated = langCode.split('_');
    String manipulatedLangCode = "${separated[0]}-${separated[1]}";
    await flutterTts.setLanguage(manipulatedLangCode);
  }
  speak(String langCode, String str) async {
    _changeLanguage(langCode);
    await flutterTts.speak(str);
  }
}