import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

@pragma('vm:entry-point')
void sumNumber(SendPort sendPort) {
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
