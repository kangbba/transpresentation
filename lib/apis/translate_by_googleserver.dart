import 'dart:async';
import 'package:google_cloud_translation/google_cloud_translation.dart';

class TranslateByGoogleServer {
  final String apiKey = "AIzaSyBlraqGv_3DXKqEsUD3Pce8sTPEzLbRb6U";
  late Translation _translation;

  initializeTranslateByGoogleServer() {
    _translation = Translation(apiKey: apiKey);
  }

  Future<String?> textTranslate(String inputStr, String to) async {
    try {
      final translationModel = await _translation.translate(text: inputStr, to: to);
      return translationModel.translatedText;
    } on Exception catch (e) {
      print('Translation error: $e');
      return null;
    }
  }
}
