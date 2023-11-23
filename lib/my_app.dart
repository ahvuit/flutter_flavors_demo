import 'dart:async';
import 'dart:convert';
import 'dart:developer';

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
  final eventChannel = const EventChannel('eventChannel');
  String messageStringFromNative = "Waiting for message...";
  String messageUserFromNative = "Waiting for message userName...";
  String messageTime = "Waiting for message time...";
  late StreamSubscription _timerSubscription;

  @override
  void initState() {
    super.initState();
  }

  void _startTimer() {
    _timerSubscription = eventChannel.receiveBroadcastStream().listen(
      (_updateTimer),
      onError: (error) {
        setState(() {
          messageTime = error.toString();
        });
      },
    );
  }

  void _updateTimer(timer) {
    if (timer == null) {
      _endTimer();
      return;
    }
    setState(() => messageTime = timer);
  }

  void _endTimer() {
    _timerSubscription.cancel();
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
      log('user $message');
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
              messageTime,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
            ElevatedButton(
              onPressed: () => _startTimer(),
              child: const Text('Start Timer'),
            ),
            ElevatedButton(
              onPressed: () => _endTimer(),
              child: const Text('End Timer'),
            ),
          ],
        ),
      ),
    );
  }
}
