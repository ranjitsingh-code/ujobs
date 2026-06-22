import 'dart:io';

void main() {
  final file = File(
    'lib/features/employer/applicants/employer_applicant_provider.dart',
  );
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    'targetJobTitle: "Senior Software Engineer (Flutter)"',
    'targetJobTitle: "Senior Software Engineer (Flutter)"',
  );
  content = content.replaceFirst(
    'targetJobTitle: "Senior Software Engineer (Flutter)"',
    'targetJobTitle: "Product Designer (UI/UX)"',
    content.indexOf('A-002'),
  );
  content = content.replaceFirst(
    'targetJobTitle: "Senior Software Engineer (Flutter)"',
    'targetJobTitle: "Full Stack Developer (Node.js)"',
    content.indexOf('A-003'),
  );
  file.writeAsStringSync(content);
}
