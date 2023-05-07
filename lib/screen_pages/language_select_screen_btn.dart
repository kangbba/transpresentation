import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/language_select_control.dart';
import '../screens/language_select_screen.dart';


class LanguageSelectScreenButton extends StatefulWidget {
  final bool isHost;

  LanguageSelectScreenButton({required this.isHost});

  @override
  State<LanguageSelectScreenButton> createState() => _LanguageSelectScreenButtonState();
}

class _LanguageSelectScreenButtonState extends State<LanguageSelectScreenButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageSelectControl>(
      builder: (context, languageSelectControl, child) {
        return Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {
              late LanguageSelectScreen myLanguageSelectScreen =
              LanguageSelectScreen(
                isHost: widget.isHost,
                languageSelectControl: languageSelectControl,
              );
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: myLanguageSelectScreen,
                    ),
                  );
                },
              );
              setState(() {});
            },
            child: SizedBox(
              height: 60,
              child: Column(
                children: [
                  Text(
                      "   ${languageSelectControl.myLanguageItem.menuDisplayStr} 으로 ${widget.isHost ? '발표 하는 중' : '보는중'}"),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "   번역 언어 변경하기   ",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
