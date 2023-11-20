import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:demo_flavors/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final platform = const MethodChannel('channel');
  late Isolate sumNumberIsolate;
  String messageFromNative = "Waiting for message...";
  String _batteryLevel = 'Unknown battery level.';

  @override
  void initState() {
    super.initState();
    _getMessageFromNative();
    _getBatteryLevel();
  }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final result = await platform.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _getMessageFromNative() async {
    String message;
    try {
      message = await platform.invokeMethod('getMessageFromNative');
    } on PlatformException catch (e) {
      message = "Failed to get message from native: ${e.message}";
    }

    setState(() {
      messageFromNative = message;
    });
  }

  void _sendMessageToNative(String message) async {
    try {
      User user = User(id: '1', email: 'anhvu@gmail.com', userName: 'anh vu');
      String json = jsonEncode(user);
      await platform.invokeMethod('sendMessageToNative', {'message': json});
    } on PlatformException catch (e) {
      print("Failed to send message to native: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              messageFromNative,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _batteryLevel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () =>
                  _sendMessageToNative('This is a message form flutter'),
              child: const Text('Send message to native'),
            ),
            // ElevatedButton(
            //   onPressed: () => createIsolate(),
            //   child: const Text('Create isolate'),
            // ),
            // ElevatedButton(
            //   onPressed: () => pauseIsolate(),
            //   child: const Text('pause'),
            // ),
            // ElevatedButton(
            //   onPressed: () => resumeIsolate(),
            //   child: const Text('resume'),
            //),
          ],
        ),
      ),
    );
  }

  void createIsolate() {
    //test();
    //demoEventLoop();
    isolateMain();
    log('create');
  }

  void resumeIsolate() {
    sumNumberIsolate.resume(sumNumberIsolate.pauseCapability ?? Capability());
    log('resume');
  }

  void pauseIsolate() {
    sumNumberIsolate.pause(sumNumberIsolate.pauseCapability);
    log('pause');
  }

  void demoEventLoop() {
    scheduleMicrotask(() => log('microtask #1 of 2'));

    Future.delayed(
        const Duration(seconds: 1), () => log('future #1 (delayed)'));
    Future(() => log('future #2 of 3'));
    Future(() => log('future #3 of 3'));

    scheduleMicrotask(() => log('microtask #2 of 2'));

    log('main #1 of 2');
    scheduleMicrotask(() => log('microtask #1 of 3'));

    Future.delayed(
        const Duration(seconds: 1), () => log('future #2 (delayed)'));

    Future(() => log('future #2 of 4'))
        .then((_) => log('future #2a'))
        .then((_) {
      log('future #2b');
      scheduleMicrotask(() => log('microtask #0 (from future #2b)'));
    }).then((_) => log('future #2c'));

    scheduleMicrotask(() => log('microtask #2 of 3'));

    Future(() => log('future #3 of 4'))
        .then((_) => Future(() => log('future #3a (a new future)')))
        .then((_) => log('future #3b'));

    Future(() => log('future #4 of 4'));

    scheduleMicrotask(() => log('microtask #3 of 3'));
    log('main #2 of 2');
  }

  void test() async {
    log('Before the future');

    Future<int>.delayed(
      const Duration(seconds: 1),
      () => 42,
    )
        .then((value) => log("value: $value"))
        .catchError((error) => log("Error: $error"))
        .whenComplete(() => log("Future is complete"));

    log('After the future');
  }

  @pragma('vm:entry-point')
  void isolateMain() async {
    ReceivePort receivePortMain = ReceivePort();

    sumNumberIsolate = await Isolate.spawn(sumNumber, receivePortMain.sendPort);

    for (int i = 1; i <= 5; i++) {
      log('microtask main: ${i.toString()}');
      sleep(const Duration(seconds: 1));
    }

    // Future.delayed(const Duration(seconds: 2), () {
    //   sumNumberIsolate.kill(priority: Isolate.immediate);
    //   log('sumNumberIsolate is killed');
    // });

    // var getProductsIsolate = await Isolate.spawn(getProducts, receivePort.sendPort);
    //
    // Future.delayed(const Duration(seconds: 2), () {
    //   getProductsIsolate.kill(priority: Isolate.immediate);
    //   log('getProductsIsolate is killed');
    // });

    receivePortMain.listen((message) {
      if (message is List) {
        log('Main isolate received: ${message[0]}');
        for (int i = 1; i <= 5; i++) {
          log('microtask main loop when received: ${i.toString()}');
          sleep(const Duration(seconds: 1));
        }
        if (message[1] is SendPort) {
          message[1].send('success');
        }
      } else {
        log('Products form server: $message');
      }
    });
  }

  @pragma('vm:entry-point')
  static void sumNumber(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();

    receivePort.listen((message) {
      log('Child isolate received $message');
    });

    int sum = 0;

    for (int i = 1; i <= 5; i++) {
      sum += i;
      log('microtask child: ${i.toString()}');
      sleep(const Duration(seconds: 1));
    }

    sendPort.send([sum, receivePort.sendPort]);
  }
}
