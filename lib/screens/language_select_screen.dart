
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transpresentation/managers/text_to_speech_control.dart';
import 'package:transpresentation/custom_widget/sayne_separator.dart';

import '../classes/language_select_control.dart';

class LanguageSelectScreen extends StatefulWidget {
  final bool isHost;
  final LanguageSelectControl languageSelectControl;

  const LanguageSelectScreen({
    required this.isHost,
    required this.languageSelectControl,
    Key? key,
  }) : super(key: key);


  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  // TODO: 기본함수
  late bool isHost = widget.isHost;
  late List<LanguageItem> languageDataList = widget.languageSelectControl.languageDataList;
  late final List<Widget> _languageListTiles = [];

  @override
  void initState() {
    // TODO: implement initState
    for(int i = 0 ; i < languageDataList.length ; i++)
    {
      _languageListTiles.add(languageListTile(languageDataList[i], false));
    }

    // onSelectedLanguageListTile(widget.languageSelectControl.initialLanguageItem);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 70,
          child: Align(alignment : Alignment.center,
              child: Text("${isHost ? "발표할" : "청취할"} 언어를 선택해주세요",
                style: TextStyle(fontSize: 15, color: Colors.teal[900], fontWeight: FontWeight.w600),
              )),),
        const SayneSeparator(color: Colors.grey, height: 0, top: 10, bottom: 10),
        Align(alignment : Alignment.centerLeft,
            child: Text("선택됨",
              style: TextStyle(fontSize: 14, color: Colors.teal[900], fontWeight: FontWeight.w600),
              textAlign: TextAlign.left,
            )),
        languageListTile(widget.languageSelectControl.myLanguageItem, true),
        const SayneSeparator(color: Colors.grey, height: 0.5, top: 0, bottom: 20),
        Align(alignment : Alignment.centerLeft,
            child: SizedBox(
              height: 30,
              child: Text("전체",
                  style: TextStyle(fontSize: 14, color: Colors.teal[900], fontWeight: FontWeight.w600),
                  textAlign: TextAlign.left
              ),
            )),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
            child: ListView(
              children: _languageListTiles,
            ),
          ),
        ),
      ],
    );
  }

  Widget languageListTile(LanguageItem languageItem, bool isSelectedLanguage)
  {
    return InkWell(
      onTap: () => onSelectedLanguageListTile(languageItem, isSelectedLanguage),
      child: ListTile(

        title: Text(languageItem.menuDisplayStr!, textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),
      ),
    );
  }
  void onSelectedLanguageListTile(LanguageItem languageItem, bool isSelectedLanguage) {
    print("onSelectedLanguageListTile! ${languageItem.sttLangCode!}");
    if(!isSelectedLanguage)
    {
      widget.languageSelectControl.myLanguageItem = languageItem;
      TextToSpeechControl.instance.changeLanguage(languageItem);
    }
    Navigator.of(context).pop();
  }
}
