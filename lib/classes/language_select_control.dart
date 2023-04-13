import 'dart:async';

import 'package:flutter/cupertino.dart';
enum TranslateLanguage{
  english, spanish, french, german, chinese, arabic, russian, portuguese, italian, japanese, dutch,
  korean, swedish, turkish, polish, danish, norwegian, finnish, czech, thai, greek, hungarian, hebrew, romanian, ukrainian , vietnamese,
  icelandic, bulgarian, lithuanian, latvian, slovenian, croatian, estonian, serbian, slovak, georgian, catalan, bengali, persian, marathi, indonesian
}
class LanguageItem {
  late final TranslateLanguage? translateLanguage;
  late final String? menuDisplayStr;
  late final String? sttLangCode;
  late final String? langCodeGoogleServer;

  LanguageItem({
    this.translateLanguage,
    this.menuDisplayStr,
    this.sttLangCode,
    this.langCodeGoogleServer,
  });
}
class LanguageSelectControl with ChangeNotifier{

  Stream<LanguageItem> get languageItemStream => _languageItemController.stream;
  final _languageItemController = StreamController<LanguageItem>.broadcast();


  static LanguageSelectControl? _instance;
  static LanguageSelectControl get instance {
    _instance ??= LanguageSelectControl();
    return _instance!;
  }

  late TranslateLanguage initialMyTranslateLanguage = TranslateLanguage.korean;

  late LanguageItem _myLanguageItem = findLanguageItemByTranslateLanguage(initialMyTranslateLanguage);
  LanguageItem get myLanguageItem{
    return _myLanguageItem;
  }
  set myLanguageItem(LanguageItem value){
    _myLanguageItem = value;
    _languageItemController.add(value);
    notifyListeners();
  }


// TODO: LanguageItem 관리
  LanguageItem findLanguageItemByTranslateLanguage(TranslateLanguage translateLanguage) {
    return languageDataList.firstWhere((item) => item.translateLanguage == translateLanguage, orElse: () => LanguageItem());
  }
  LanguageItem findLanguageItemByMenuDisplayStr(String menuDisplayStr) {
    return languageDataList.firstWhere((item) => item.menuDisplayStr == menuDisplayStr, orElse: () => LanguageItem());
  }

  List<LanguageItem> languageDataList = [
    LanguageItem(translateLanguage: TranslateLanguage.english, menuDisplayStr: "English", sttLangCode: "en_US", langCodeGoogleServer: "en", ),
    LanguageItem(translateLanguage: TranslateLanguage.korean, menuDisplayStr: "Korean", sttLangCode: "ko_KR", langCodeGoogleServer: "ko", ),
    LanguageItem(translateLanguage: TranslateLanguage.spanish, menuDisplayStr: "Spanish", sttLangCode: "es_ES", langCodeGoogleServer: "es", ),
    LanguageItem(translateLanguage: TranslateLanguage.french, menuDisplayStr: "French", sttLangCode: "fr_FR", langCodeGoogleServer: "fr",  ),
    LanguageItem(translateLanguage: TranslateLanguage.german, menuDisplayStr: "German", sttLangCode: "de_DE", langCodeGoogleServer: "de", ),
    LanguageItem(translateLanguage: TranslateLanguage.chinese, menuDisplayStr: "Chinese", sttLangCode: "zh_CN", langCodeGoogleServer: "zh-CN",  ),
    LanguageItem(translateLanguage: TranslateLanguage.arabic, menuDisplayStr: "Arabic", sttLangCode: "ar_AR", langCodeGoogleServer: "ar",  ),
    LanguageItem(translateLanguage: TranslateLanguage.russian, menuDisplayStr: "Russian", sttLangCode: "ru_RU", langCodeGoogleServer: "ru", ),
    LanguageItem(translateLanguage: TranslateLanguage.portuguese, menuDisplayStr: "Portuguese", sttLangCode: "pt_PT", langCodeGoogleServer: "pt", ),
    LanguageItem(translateLanguage: TranslateLanguage.italian, menuDisplayStr: "Italian", sttLangCode: "it_IT", langCodeGoogleServer: "it", ),
    LanguageItem(translateLanguage: TranslateLanguage.japanese, menuDisplayStr: "Japanese", sttLangCode: "ja_JP", langCodeGoogleServer: "ja", ),
    LanguageItem(translateLanguage: TranslateLanguage.dutch, menuDisplayStr: "Dutch", sttLangCode: "nl_NL", langCodeGoogleServer: "nl", ),
    LanguageItem(translateLanguage: TranslateLanguage.swedish, menuDisplayStr: "Swedish", sttLangCode: "sv_SE", langCodeGoogleServer: "sv",),
    LanguageItem(translateLanguage: TranslateLanguage.turkish, menuDisplayStr: "Turkish", sttLangCode: "tr_TR", langCodeGoogleServer: "tr", ),
    LanguageItem(translateLanguage: TranslateLanguage.polish, menuDisplayStr: "Polish", sttLangCode: "pl_PL", langCodeGoogleServer: "pl", ),
    LanguageItem(translateLanguage: TranslateLanguage.danish, menuDisplayStr: "Danish", sttLangCode: "da_DK", langCodeGoogleServer: "da", ),
    LanguageItem(translateLanguage: TranslateLanguage.norwegian, menuDisplayStr: "Norwegian", sttLangCode: "nb_NO", langCodeGoogleServer: "no", ),
    LanguageItem(translateLanguage: TranslateLanguage.finnish, menuDisplayStr: "Finnish", sttLangCode: "fi_FI", langCodeGoogleServer: "fi",),
    LanguageItem(translateLanguage: TranslateLanguage.czech, menuDisplayStr: "Czech", sttLangCode: "cs_CZ", langCodeGoogleServer: "cs", ),
    LanguageItem(translateLanguage: TranslateLanguage.thai, menuDisplayStr: "Thai", sttLangCode: "th_TH", langCodeGoogleServer: "th", ),
    LanguageItem(translateLanguage: TranslateLanguage.greek, menuDisplayStr: "Greek", sttLangCode: "el_GR", langCodeGoogleServer: "el", ),
    LanguageItem(translateLanguage: TranslateLanguage.hungarian, menuDisplayStr: "Hungarian", sttLangCode: "hu_HU", langCodeGoogleServer: "hu", ),
    LanguageItem(translateLanguage: TranslateLanguage.hebrew, menuDisplayStr: "Hebrew", sttLangCode: "he_IL", langCodeGoogleServer: "he", ),
    LanguageItem(translateLanguage: TranslateLanguage.romanian, menuDisplayStr: "Romanian", sttLangCode: "ro_RO", langCodeGoogleServer: "ro",),
    LanguageItem(translateLanguage: TranslateLanguage.ukrainian, menuDisplayStr: "Ukrainian", sttLangCode: "uk_UA", langCodeGoogleServer: "uk", ),
    LanguageItem(translateLanguage: TranslateLanguage.vietnamese, menuDisplayStr: "Vietnamese", sttLangCode: "vi_VN", langCodeGoogleServer: "vi", ),
    LanguageItem(translateLanguage: TranslateLanguage.icelandic, menuDisplayStr: "Icelandic", sttLangCode: "is_IS", langCodeGoogleServer: "is",),
    LanguageItem(translateLanguage: TranslateLanguage.bulgarian, menuDisplayStr: "Bulgarian", sttLangCode: "bg_BG", langCodeGoogleServer: "bg", ),
    LanguageItem(translateLanguage: TranslateLanguage.lithuanian, menuDisplayStr: "Lithuanian", sttLangCode: "lt_LT", langCodeGoogleServer: "lt", ),
    LanguageItem(translateLanguage: TranslateLanguage.latvian, menuDisplayStr: "Latvian", sttLangCode: "lv_LV", langCodeGoogleServer: "lv", ),
    LanguageItem(translateLanguage: TranslateLanguage.slovenian, menuDisplayStr: "Slovenian", sttLangCode: "sl_SI", langCodeGoogleServer: "sl", ),
    LanguageItem(translateLanguage: TranslateLanguage.croatian, menuDisplayStr: "Croatian", sttLangCode: "hr_HR", langCodeGoogleServer: "hr",),
    LanguageItem(translateLanguage: TranslateLanguage.estonian, menuDisplayStr: "Estonian", sttLangCode: "et_EE", langCodeGoogleServer: "et", ),
    LanguageItem(translateLanguage: TranslateLanguage.serbian , menuDisplayStr: "Serbian", sttLangCode: "sr_RS", langCodeGoogleServer: "sr",),
    LanguageItem(translateLanguage: TranslateLanguage.slovak, menuDisplayStr: "Slovak", sttLangCode: "sk_SK", langCodeGoogleServer: "sk",),
    LanguageItem(translateLanguage: TranslateLanguage.georgian, menuDisplayStr: "Georgian", sttLangCode: "ka_GE", langCodeGoogleServer: "ka", ),
    LanguageItem(translateLanguage: TranslateLanguage.catalan, menuDisplayStr: "Catalan", sttLangCode: "ca_ES", langCodeGoogleServer: "ca",),
    LanguageItem(translateLanguage: TranslateLanguage.bengali, menuDisplayStr: "Bengali", sttLangCode: "bn_IN", langCodeGoogleServer: "bn",),
    LanguageItem(translateLanguage: TranslateLanguage.persian, menuDisplayStr: "Persian", sttLangCode: "fa_IR", langCodeGoogleServer: "fa",),
    LanguageItem(translateLanguage: TranslateLanguage.marathi, menuDisplayStr: "Marathi", sttLangCode: "mr_IN", langCodeGoogleServer: "mr",),
    LanguageItem(translateLanguage: TranslateLanguage.indonesian, menuDisplayStr: "Indonesian", sttLangCode: "id_ID", langCodeGoogleServer: "id",),
  ];

}