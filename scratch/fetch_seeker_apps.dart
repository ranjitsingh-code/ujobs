import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final res = await dio.post('https://api.ujobs.com/api/v1/mobile/auth/login', 
       // I don't have credentials easily available to write a script.
    );
  } catch(e) {
    print(e);
  }
}
