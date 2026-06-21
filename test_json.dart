import 'dart:convert';
void main() {
  final content = '[{"insert":"We are looking for a skilled Software Engineer to join our dynamic team. You will be responsible for building high-performance, scalable applications. Your daily tasks will include writing clean, maintainable code, reviewing pull requests, and collaborating with cross-functional teams.\\n"}]';
  try {
    print(jsonDecode(content));
    print("Success");
  } catch (e) {
    print("Fail: \$e");
  }
}
