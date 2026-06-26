import re

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

# 1. Add vsc_quill_delta_to_html and countries_provider imports
import_target = "import '../../../core/providers/categories_provider.dart';"
import_replace = "import '../../../core/providers/categories_provider.dart';\nimport '../../../core/providers/countries_provider.dart';\nimport 'dart:convert';\nimport 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';"
if import_target in text and "vsc_quill_delta_to_html" not in text:
    text = text.replace(import_target, import_replace)

# 2. Add delta to html converter helper and country lookup inside _submitJob
func_target = """  Future<void> _submitJob(String targetStatus) async {
    final state = ref.read(postJobWizardProvider);
    final dio = ref.read(dioClientProvider).dio;
    
    final options = ref.read(jobFormOptionsProvider).valueOrNull;
    final categories = ref.read(categoriesProvider).valueOrNull;"""

func_replace = """  String _deltaToHtml(String deltaJson) {
    if (deltaJson.isEmpty) return '';
    try {
      final List<dynamic> ops = jsonDecode(deltaJson);
      final converter = QuillDeltaToHtmlConverter(
        List.castFrom(ops).map((op) => Map<String, dynamic>.from(op)).toList()
      );
      return converter.convert();
    } catch (e) {
      return deltaJson;
    }
  }

  Future<void> _submitJob(String targetStatus) async {
    final state = ref.read(postJobWizardProvider);
    final dio = ref.read(dioClientProvider).dio;
    
    final options = ref.read(jobFormOptionsProvider).valueOrNull;
    final categories = ref.read(categoriesProvider).valueOrNull;
    final countries = ref.read(countriesProvider).valueOrNull;"""

if "String _deltaToHtml" not in text:
    text = text.replace(func_target, func_replace)

# 3. Update the payload to convert delta to HTML and country to iso2
payload_target = """        'city': state.city,
        'country': state.country,
        'vacancies': int.tryParse(state.openings) ?? 1,
        if (state.deadline.isNotEmpty) 'application_deadline': state.deadline,
        if (state.salaryMin.isNotEmpty) 'salary_min': int.tryParse(state.salaryMin),
        if (state.salaryMax.isNotEmpty) 'salary_max': int.tryParse(state.salaryMax),
        'salary_currency': state.currency.isNotEmpty ? state.currency : fallbackCurrency,
        'salary_period': state.salaryPeriod.isNotEmpty ? state.salaryPeriod : fallbackSalaryPeriod,
        'responsibilities': state.responsibilities,
        'requirements': state.requirements,"""

payload_replace = """        'city': state.city,
        'country': countries?.firstWhere((c) => c.name == state.country, orElse: () => countries.first).iso2 ?? 'GB',
        'vacancies': int.tryParse(state.openings) ?? 1,
        if (state.deadline.isNotEmpty) 'application_deadline': state.deadline,
        if (state.salaryMin.isNotEmpty) 'salary_min': int.tryParse(state.salaryMin),
        if (state.salaryMax.isNotEmpty) 'salary_max': int.tryParse(state.salaryMax),
        'salary_currency': state.currency.isNotEmpty ? state.currency : fallbackCurrency,
        'salary_period': state.salaryPeriod.isNotEmpty ? state.salaryPeriod : fallbackSalaryPeriod,
        'description': _deltaToHtml(state.description),
        'responsibilities': _deltaToHtml(state.responsibilities),
        'requirements': _deltaToHtml(state.requirements),"""

# Note: We must also remove 'description': state.description, from earlier in the payload
payload_desc_target = """        'title': state.title,
        'description': state.description,"""
payload_desc_replace = """        'title': state.title,"""

if "'description': state.description," in text:
    text = text.replace(payload_desc_target, payload_desc_replace)

if payload_target in text:
    text = text.replace(payload_target, payload_replace)

with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
    f.write(text)

