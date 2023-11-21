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
  final eventChannel = const EventChannel('channel');
  late Isolate sumNumberIsolate;
  String messageStringFromNative = "Waiting for message...";
  String messageUserFromNative = "Waiting for message userName...";
  //String messageTime = "Waiting for message time...";

  @override
  void initState() {
    // eventChannel.receiveBroadcastStream().listen((data) {
    //   setState(() {
    //     messageTime = data;
    //   });
    // });
    super.initState();
  }

  Future<void> _getStringFromNative() async {
    String message;
    try {
      message = await platform.invokeMethod('getStringFromNative');
    } on PlatformException catch (e) {
      message = "Failed to get message from native: ${e.message}";
    }

    setState(() {
      messageStringFromNative = message;
    });
  }

  Future<void> _getUserFromNative() async {
    String message;
    try {
      message = await platform.invokeMethod('getUserFromNative');
      log('message: $message');

      Map<String, dynamic> jsonMap = json.decode(message);
      log('jsonMap: $jsonMap');

      User user = User.fromJson(jsonMap);
      message = user.userName ?? '';
      log('user ${user.userName}');
    } on PlatformException catch (e) {
      message = "Failed to get message user from native: ${e.message}";
    }
    setState(() {
      messageUserFromNative = message;
    });
  }

  void _sendMessageToNative(String message) async {
    try {
      User user = User(id: '1', email: 'anhvu@gmail.com', userName: 'anh vu');
      String json = jsonEncode(user);

      platform.invokeMethod('sendMessageToNative', {'message': json});

      // message = await platform.invokeMethod('getUserFromNative');
      //
      // setState(() {
      //   messageUserFromNative = message;
      // });
    } on PlatformException catch (e) {
      log("Failed to send message to native: ${e.message}");
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
              messageStringFromNative,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              messageUserFromNative,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => _getStringFromNative(),
              child: const Text('Get String form native'),
            ),
            ElevatedButton(
              onPressed: () => _getUserFromNative(),
              child: const Text('Get User form native'),
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
