import 'dart:developer';
import 'dart:isolate';

@pragma('vm:entry-point')
void sumNumber(SendPort sendPort) {
  ReceivePort receivePort = ReceivePort();

  receivePort.listen((message) {
    log('$message');
  });

  int sum = 0;

  for (int i = 0; i < 1000000000; i++) {
    sum += i;
  }

  sendPort.send([sum, receivePort.sendPort]);
}
