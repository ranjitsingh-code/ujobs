import 'dart:convert';
import 'lib/core/models/job.dart';

void main() {
  final jsonString = """
  {
                 "id": "30",
                 "title": "Software Engineer",
                 "preferred_skills": "React, Node.js, AWS, OpenAI API, REST API",
                 "languages_required": "English"
  }
  """;

  final json = jsonDecode(jsonString);
  final job = Job.fromJson(json);

  print('Preferred Skills: \${job.preferredSkills}');
  print('Languages: \${job.languages}');
}
