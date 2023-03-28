import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:path_provider/path_provider.dart';
class AudioRecognize extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AudioRecognizeState();
}

class _AudioRecognizeState extends State<AudioRecognize> {
  bool recognizing = false;
  bool recognizeFinished = false;
  String text = '';
  final jsonPath = 'assets/quick-woodland-376602-7a68644c54ac.json';

  void recognize() async {
    setState(() {
      recognizing = true;
    });
    final serviceAccount = ServiceAccount.fromString(
        '${(await rootBundle.loadString(jsonPath))}');
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = _getConfig();
    final audio = await _getAudioContent('test.wav');

    await speechToText.recognize(config, audio).then((value) {
      setState(() {
        text = value.results
            .map((e) => e.alternatives.first.transcript)
            .join('\n');
      });
    }).whenComplete(() => setState(() {
      recognizeFinished = true;
      recognizing = false;
    }));
  }

  void streamingRecognize() async {
    setState(() {
      recognizing = true;
    });
    final serviceAccount = ServiceAccount.fromString(
        '${(await rootBundle.loadString(jsonPath))}');
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = _getConfig();

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: true),
        await _getAudioStream('test.wav'));

    responseStream.listen((data) {
      setState(() {
        text =
            data.results.map((e) => e.alternatives.first.transcript).join('\n');
        recognizeFinished = true;
      });
    }, onDone: () {
      setState(() {
        recognizing = false;
      });
    });
  }

  RecognitionConfig _getConfig() => RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'en-US');

  Future<void> _copyFileFromAssets(String name) async {
    var data = await rootBundle.load('assets/$name');
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + '/$name';
    await File(path).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<List<int>> _getAudioContent(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + '/$name';
    if (!File(path).existsSync()) {
      await _copyFileFromAssets(name);
    }
    return File(path).readAsBytesSync().toList();
  }

  Future<Stream<List<int>>> _getAudioStream(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + '/$name';
    if (!File(path).existsSync()) {
      await _copyFileFromAssets(name);
    }
    return File(path).openRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio File Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            if (recognizeFinished)
              Column(
                children: <Widget>[
                  Text(
                    'The text recognized by the Google Speech Api:',
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: recognizing ? () {} : recognize,
              child: recognizing
                  ? CircularProgressIndicator()
                  : Text('Test with recognize'),
            ),
            SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              onPressed: recognizing ? () {} : streamingRecognize,
              child: recognizing
                  ? CircularProgressIndicator()
                  : Text('Test with streaming recognize'),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
