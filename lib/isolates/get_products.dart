import 'dart:isolate';

import 'package:dio/dio.dart';

@pragma('vm:entry-point')
void getProducts(SendPort sendPort) async {
  Dio dio = Dio();

  Response response = await dio.get('https://dummyjson.com/products');

  sendPort.send(response.data);
}
