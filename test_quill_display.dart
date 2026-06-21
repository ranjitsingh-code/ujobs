import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  final content = '[{"insert":"Hello\\n"}]';
  try {
    final decoded = jsonDecode(content);
    print('Decoded type: ${decoded.runtimeType}');
    final doc = Document.fromJson(decoded);
    print('Success: ${doc.toPlainText()}');
  } catch (e, stack) {
    print('Error: $e');
    print(stack);
  }
}
