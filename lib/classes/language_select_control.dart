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
  late final String? speechLocaleId;
  late final String? langCodeGoogleServer;

  LanguageItem({
    this.translateLanguage,
    this.menuDisplayStr,
    this.speechLocaleId,
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
    LanguageItem(translateLanguage: TranslateLanguage.english, menuDisplayStr: "English", speechLocaleId: "en_US", langCodeGoogleServer: "en", ),
    LanguageItem(translateLanguage: TranslateLanguage.spanish, menuDisplayStr: "Spanish", speechLocaleId: "es_ES", langCodeGoogleServer: "es", ),
    LanguageItem(translateLanguage: TranslateLanguage.french, menuDisplayStr: "French", speechLocaleId: "fr_FR", langCodeGoogleServer: "fr",  ),
    LanguageItem(translateLanguage: TranslateLanguage.german, menuDisplayStr: "German", speechLocaleId: "de_DE", langCodeGoogleServer: "de", ),
    LanguageItem(translateLanguage: TranslateLanguage.chinese, menuDisplayStr: "Chinese", speechLocaleId: "zh_CN", langCodeGoogleServer: "zh-CN",  ),
    LanguageItem(translateLanguage: TranslateLanguage.arabic, menuDisplayStr: "Arabic", speechLocaleId: "ar_AR", langCodeGoogleServer: "ar",  ),
    LanguageItem(translateLanguage: TranslateLanguage.russian, menuDisplayStr: "Russian", speechLocaleId: "ru_RU", langCodeGoogleServer: "ru", ),
    LanguageItem(translateLanguage: TranslateLanguage.portuguese, menuDisplayStr: "Portuguese", speechLocaleId: "pt_PT", langCodeGoogleServer: "pt", ),
    LanguageItem(translateLanguage: TranslateLanguage.italian, menuDisplayStr: "Italian", speechLocaleId: "it_IT", langCodeGoogleServer: "it", ),
    LanguageItem(translateLanguage: TranslateLanguage.japanese, menuDisplayStr: "Japanese", speechLocaleId: "ja_JP", langCodeGoogleServer: "ja", ),
    LanguageItem(translateLanguage: TranslateLanguage.dutch, menuDisplayStr: "Dutch", speechLocaleId: "nl_NL", langCodeGoogleServer: "nl", ),
    LanguageItem(translateLanguage: TranslateLanguage.korean, menuDisplayStr: "Korean", speechLocaleId: "ko_KR", langCodeGoogleServer: "ko", ),
    LanguageItem(translateLanguage: TranslateLanguage.swedish, menuDisplayStr: "Swedish", speechLocaleId: "sv_SE", langCodeGoogleServer: "sv",),
    LanguageItem(translateLanguage: TranslateLanguage.turkish, menuDisplayStr: "Turkish", speechLocaleId: "tr_TR", langCodeGoogleServer: "tr", ),
    LanguageItem(translateLanguage: TranslateLanguage.polish, menuDisplayStr: "Polish", speechLocaleId: "pl_PL", langCodeGoogleServer: "pl", ),
    LanguageItem(translateLanguage: TranslateLanguage.danish, menuDisplayStr: "Danish", speechLocaleId: "da_DK", langCodeGoogleServer: "da", ),
    LanguageItem(translateLanguage: TranslateLanguage.norwegian, menuDisplayStr: "Norwegian", speechLocaleId: "nb_NO", langCodeGoogleServer: "no", ),
    LanguageItem(translateLanguage: TranslateLanguage.finnish, menuDisplayStr: "Finnish", speechLocaleId: "fi_FI", langCodeGoogleServer: "fi",),
    LanguageItem(translateLanguage: TranslateLanguage.czech, menuDisplayStr: "Czech", speechLocaleId: "cs_CZ", langCodeGoogleServer: "cs", ),
    LanguageItem(translateLanguage: TranslateLanguage.thai, menuDisplayStr: "Thai", speechLocaleId: "th_TH", langCodeGoogleServer: "th", ),
    LanguageItem(translateLanguage: TranslateLanguage.greek, menuDisplayStr: "Greek", speechLocaleId: "el_GR", langCodeGoogleServer: "el", ),
    LanguageItem(translateLanguage: TranslateLanguage.hungarian, menuDisplayStr: "Hungarian", speechLocaleId: "hu_HU", langCodeGoogleServer: "hu", ),
    LanguageItem(translateLanguage: TranslateLanguage.hebrew, menuDisplayStr: "Hebrew", speechLocaleId: "he_IL", langCodeGoogleServer: "he", ),
    LanguageItem(translateLanguage: TranslateLanguage.romanian, menuDisplayStr: "Romanian", speechLocaleId: "ro_RO", langCodeGoogleServer: "ro",),
    LanguageItem(translateLanguage: TranslateLanguage.ukrainian, menuDisplayStr: "Ukrainian", speechLocaleId: "uk_UA", langCodeGoogleServer: "uk", ),
    LanguageItem(translateLanguage: TranslateLanguage.vietnamese, menuDisplayStr: "Vietnamese", speechLocaleId: "vi_VN", langCodeGoogleServer: "vi", ),
    LanguageItem(translateLanguage: TranslateLanguage.icelandic, menuDisplayStr: "Icelandic", speechLocaleId: "is_IS", langCodeGoogleServer: "is",),
    LanguageItem(translateLanguage: TranslateLanguage.bulgarian, menuDisplayStr: "Bulgarian", speechLocaleId: "bg_BG", langCodeGoogleServer: "bg", ),
    LanguageItem(translateLanguage: TranslateLanguage.lithuanian, menuDisplayStr: "Lithuanian", speechLocaleId: "lt_LT", langCodeGoogleServer: "lt", ),
    LanguageItem(translateLanguage: TranslateLanguage.latvian, menuDisplayStr: "Latvian", speechLocaleId: "lv_LV", langCodeGoogleServer: "lv", ),
    LanguageItem(translateLanguage: TranslateLanguage.slovenian, menuDisplayStr: "Slovenian", speechLocaleId: "sl_SI", langCodeGoogleServer: "sl", ),
    LanguageItem(translateLanguage: TranslateLanguage.croatian, menuDisplayStr: "Croatian", speechLocaleId: "hr_HR", langCodeGoogleServer: "hr",),
    LanguageItem(translateLanguage: TranslateLanguage.estonian, menuDisplayStr: "Estonian", speechLocaleId: "et_EE", langCodeGoogleServer: "et", ),
    LanguageItem(translateLanguage: TranslateLanguage.serbian , menuDisplayStr: "Serbian", speechLocaleId: "sr_RS", langCodeGoogleServer: "sr",),
    LanguageItem(translateLanguage: TranslateLanguage.slovak, menuDisplayStr: "Slovak", speechLocaleId: "sk_SK", langCodeGoogleServer: "sk",),
    LanguageItem(translateLanguage: TranslateLanguage.georgian, menuDisplayStr: "Georgian", speechLocaleId: "ka_GE", langCodeGoogleServer: "ka", ),
    LanguageItem(translateLanguage: TranslateLanguage.catalan, menuDisplayStr: "Catalan", speechLocaleId: "ca_ES", langCodeGoogleServer: "ca",),
    LanguageItem(translateLanguage: TranslateLanguage.bengali, menuDisplayStr: "Bengali", speechLocaleId: "bn_IN", langCodeGoogleServer: "bn",),
    LanguageItem(translateLanguage: TranslateLanguage.persian, menuDisplayStr: "Persian", speechLocaleId: "fa_IR", langCodeGoogleServer: "fa",),
    LanguageItem(translateLanguage: TranslateLanguage.marathi, menuDisplayStr: "Marathi", speechLocaleId: "mr_IN", langCodeGoogleServer: "mr",),
    LanguageItem(translateLanguage: TranslateLanguage.indonesian, menuDisplayStr: "Indonesian", speechLocaleId: "id_ID", langCodeGoogleServer: "id",),
  ];

}