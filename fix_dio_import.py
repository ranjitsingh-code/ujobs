import re

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

if "import 'package:dio/dio.dart';" not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:dio/dio.dart';")

with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
    f.write(text)

