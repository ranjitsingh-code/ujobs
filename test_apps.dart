import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final res = await dio.get(
      'https://ujobapi.gidentex.com/api/v1/mobile/seeker/applications',
      options: Options(
        headers: {
          'X-Api-Key': 'jp_live_abc123xyz456',
          'Authorization': 'Bearer 202|N9gVdY0v3p83fOQ3NivH9r9hK5UUBnZ99L64qVwZ61af7103', // Use dummy or assume it fails, wait we don't have token
        },
      ),
    );
    debugPrint('${res.data}');
  } catch (e) {
    debugPrint('$e');
  }
}
