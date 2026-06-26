import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';

void main() {
  var delta = HtmlToDelta().convert("<p>Hello <b>World</b></p>");
  print(delta);
}
