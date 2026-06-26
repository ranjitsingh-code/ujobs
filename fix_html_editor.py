import re

with open('lib/core/widgets/ujob_rich_text_editor.dart', 'r') as f:
    text = f.read()

import_statement = "import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';\n"
if "flutter_quill_delta_from_html.dart" not in text:
    text = text.replace("import 'package:flutter_quill/flutter_quill.dart';", "import 'package:flutter_quill/flutter_quill.dart';\n" + import_statement)

pat_parse = r"Document _parseInitialValue\(String value\) \{\n\s*if \(value.isEmpty\) return Document\(\);\n\s*try \{\n\s*return Document.fromJson\(jsonDecode\(value\)\);\n\s*\} catch \(e\) \{\n\s*final doc = Document\(\);\n\s*doc.insert\(0, value\);\n\s*return doc;\n\s*\}"
rep_parse = r"""Document _parseInitialValue(String value) {
    if (value.isEmpty) return Document();
    try {
      return Document.fromJson(jsonDecode(value));
    } catch (e) {
      if (value.contains('<') && value.contains('>')) {
        try {
          final delta = HtmlToDelta().convert(value);
          return Document.fromDelta(delta);
        } catch (_) {}
      }
      final doc = Document();
      doc.insert(0, value);
      return doc;
    }
  }"""
text = re.sub(pat_parse, rep_parse, text)

with open('lib/core/widgets/ujob_rich_text_editor.dart', 'w') as f:
    f.write(text)

