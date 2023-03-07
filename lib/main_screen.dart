import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            ElevatedButton(onPressed: (){onPressedBtn1();} , child: Icon(Icons.alarm)),
            ElevatedButton(onPressed: (){onPressedBtn2();} , child: Icon(Icons.alarm)),
            ElevatedButton(onPressed: (){onPressedBtn3();} , child: Icon(Icons.alarm)),
          ],
        ),
      ),
    );
  }

  onPressedBtn1(){
    print('create iterator');
    Iterable<int> numbers = getNumbers1(3);
    print('starting to iterate...');
    for (int val in numbers) {
      print('$val');
    }
    print('end of main');
  }
  onPressedBtn2(){
    print('create iterator');
    Stream<int> numbers = getNumbers2(3);
    print('starting to listen...');
    numbers.listen((int value) {
      print('$value');
    });
    print('end of main');
  }
  onPressedBtn3(){
    print('create iterator');
    Iterable<int> numbers = getNumbersRecursive3(3);
    print('starting to iterate...');
    for (int val in numbers) {
      print('$val');
    }
    print('end of main');
  }
}



Iterable<int> getNumbers1(int number) sync* {
  print('generator started');
  for (int i = 0; i < number; i++) {
    yield i;
  }

  print('generator ended');
}

Stream<int> getNumbers2(int number) async* {
  print('제너레이터 내부에서 잠시 대기 중 :)');
  await new Future.delayed(new Duration(seconds: 2)); //sleep 5s
  print('값 생성 시작...');
  for (int i = 0; i < number; i++) {
    await new Future.delayed(new Duration(seconds: 1)); //sleep 1s
    yield i;
  }
  print('값 생성 종료...');
}

Iterable<int> getNumbersRecursive3(int number) sync* {
  print('generator $number started');
  if (number > 0) {
    yield* getNumbersRecursive3(number - 1);
  }
  yield number;
  print('generator $number ended');
}
