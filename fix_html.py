import re

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'r') as f:
    code = f.read()

helper_method = """  String _stripHtml(String? text) {
    if (text == null || text.isEmpty) return '';
    // Replace <br> and <p> tags with newlines before stripping to preserve paragraph formatting
    String parsed = text.replaceAll(RegExp(r'(<br\s*/?>|</p>|<p>)', caseSensitive: false), '\n');
    // Strip remaining HTML tags
    parsed = parsed.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode basic HTML entities
    parsed = parsed.replaceAll('&nbsp;', ' ');
    parsed = parsed.replaceAll('&amp;', '&');
    parsed = parsed.replaceAll('&lt;', '<');
    parsed = parsed.replaceAll('&gt;', '>');
    parsed = parsed.replaceAll('&quot;', '"');
    parsed = parsed.replaceAll('&#39;', "'");
    // Clean up multiple newlines
    parsed = parsed.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return parsed.trim();
  }

  Applicant _parseApplicant(Map<String, dynamic> json) {"""

if "_stripHtml" not in code:
    code = code.replace("  Applicant _parseApplicant(Map<String, dynamic> json) {", helper_method)

code = code.replace("coverLetter: application['cover_letter']?.toString(),", "coverLetter: _stripHtml(application['cover_letter']?.toString()),")
code = code.replace("about: profile['summary']?.toString(),", "about: _stripHtml(profile['summary']?.toString()),")

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'w') as f:
    f.write(code)
