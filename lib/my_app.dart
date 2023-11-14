import 'dart:developer';
import 'dart:isolate';

import 'package:demo_flavors/isolates/sum_number.dart';
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
  final platform = const MethodChannel('your_channel_name');

  String messageFromNative = "Waiting for message...";

  @override
  void initState() {
    super.initState();
    getMessageFromNative();
  }

  Future<void> getMessageFromNative() async {
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

  void sendMessageToNative(String message) async {
    try {
      await platform.invokeMethod('sendMessageToNative', {'message': message});
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
            ElevatedButton(
              onPressed: () {
                isolateMain();
                //sendMessageToNative("Hello from Flutter!");
              },
              child: const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }

  @pragma('vm:entry-point')
  void isolateMain() async {
    ReceivePort receivePort = ReceivePort();

    var sumNumberIsolate = await Isolate.spawn(sumNumber, receivePort.sendPort);

    Future.delayed(const Duration(seconds: 2), () {
      receivePort.close();
      sumNumberIsolate.kill(priority: Isolate.immediate);
      log('sumNumberIsolate is killed');
    });

    receivePort.listen((message) {
      log('Main isolate received: ${message[0]}');
      if (message[1] is SendPort) {
        message[1].send("Hello from isolateMain!");
      }
    });

    log('Main isolate is still running.');
  }
}
