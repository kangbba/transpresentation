import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:transpresentation/classes/language_select_control.dart';

class TextToSpeechControl extends ChangeNotifier{

  static TextToSpeechControl? _instance;
  static TextToSpeechControl get instance {
    _instance ??= TextToSpeechControl();
    return _instance!;
  }
  FlutterTts flutterTts = FlutterTts();
  initTextToSpeech(LanguageItem languageItem) async
  {
    print("${languageItem.sttLangCode} 여기작동");
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    changeLanguage(languageItem);
  }
  changeLanguage(LanguageItem languageItem) async
  {
    List<String> separated = languageItem.sttLangCode!.split('_');
    String manipulatedLangCode = "${separated[0]}-${separated[1]}";
    await flutterTts.setLanguage(manipulatedLangCode);
    // 사용 가능한 음성 목록 가져오기
    List<dynamic>? totalVoices = await flutterTts.getVoices;
    List<dynamic>? availableVoices = [];
    totalVoices?.forEach((voice) {
      if (voice['locale'] == manipulatedLangCode) {
        print(voice);
        availableVoices.add(voice);
      }
    });
    if(availableVoices.isEmpty){
      print("사용가능한 목소리가 없음");
      return;
    }

    Map<String, String> selectedVoice;
    if(languageItem.voiceName!.isEmpty){
      selectedVoice = {
        'name': availableVoices.last['name'],
        'locale': availableVoices.last['locale'],
      };
      print("마지막 정보의 selectedVoice : $selectedVoice");
    }
    else{
      selectedVoice = {
        'name': languageItem.voiceName!,
        'locale': manipulatedLangCode,
      };
      print("커스텀 selectedVoice : $selectedVoice");
    }
    await flutterTts.setVoice(selectedVoice);

    // voices?.forEach((voice) {
    //   if (voice['locale'] == manipulatedLangCode) {
    //     print(voice);
    //   }
    // });

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
  speak(String str, bool useWaiting) async {
    // await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [IosTextToSpeechAudioCategoryOptions.allowBluetooth]);
    // await flutterTts.setVolume(2.0);

    await flutterTts.speak(str);
    await flutterTts.awaitSpeakCompletion(useWaiting);
    print("음성 재생이 실제로 완료됨");
  }
}