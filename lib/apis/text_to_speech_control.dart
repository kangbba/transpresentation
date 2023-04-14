import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechControl extends ChangeNotifier{

  static TextToSpeechControl? _instance;
  static TextToSpeechControl get instance {
    _instance ??= TextToSpeechControl();
    return _instance!;
  }
  FlutterTts flutterTts = FlutterTts();
  initTextToSpeech(String sttLangCode) async
  {
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await changeLanguage(sttLangCode);
  }
  changeLanguage(String sttLangCode) async
  {
    List<String> separated = sttLangCode.split('_');
    String manipulatedLangCode = "${separated[0]}-${separated[1]}";
    await flutterTts.setLanguage(manipulatedLangCode);
    // 사용 가능한 음성 목록 가져오기
    // List<dynamic>? voices = await flutterTts.getVoices;
    // print(voices);
    // if (voices == null) {
    //   return;
    // }
    // // 남성 목소리 선택
    // Map<String, String>? maleVoiceMap = voices.firstWhere((voice) => voice["gender"] == "male", orElse: () => null);
    // print(maleVoiceMap);
    // if (maleVoiceMap == null) {
    //   return;
    // }
    // // 남성 목소리로 변경
    // await flutterTts.setVoice(maleVoiceMap);
  }
  speak(String str) async {
    await flutterTts.speak(str);
  }
}