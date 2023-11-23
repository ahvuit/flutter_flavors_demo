import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:demo_flavors/isolates/sum_number.dart';
import 'package:flutter/material.dart';

class HomePageIsolate extends StatefulWidget {
  const HomePageIsolate({super.key, required this.title});

  final String title;

  @override
  State<HomePageIsolate> createState() => _HomePageIsolateState();
}

class _HomePageIsolateState extends State<HomePageIsolate> {
  late Isolate sumNumberIsolate;

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
            const Text(
              "Demo ISOLATE",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => createIsolate(),
              child: const Text('Create isolate'),
            ),
            ElevatedButton(
              onPressed: () => pauseIsolate(),
              child: const Text('pause'),
            ),
            ElevatedButton(
              onPressed: () => resumeIsolate(),
              child: const Text('resume'),
            ),
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
}
