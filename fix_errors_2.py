import re

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    text = f.read()

# 1. Add imports
import_target = "import 'employer_job_provider.dart';"
import_replace = "import 'package:dio/dio.dart';\nimport '../../../core/utils/api_error_parser.dart';\nimport 'employer_job_provider.dart';"
if import_target in text and "api_error_parser.dart" not in text:
    text = text.replace(import_target, import_replace)

# 2. Replace catch blocks
patterns = [
    (r"\} catch \(e\) \{\n\s*if \(context.mounted\) UJobToast.error\(context, 'Error', sub: 'Failed to publish job'\);\n\s*\}",
     "} catch (e) {\n                        if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to publish job');\n                      }"),
    (r"\} catch \(e\) \{\n\s*if \(context.mounted\) UJobToast.error\(context, 'Error', sub: 'Failed to reactivate job'\);\n\s*\}",
     "} catch (e) {\n                        if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to reactivate job');\n                      }"),
    (r"\} catch \(e\) \{\n\s*if \(context.mounted\) UJobToast.error\(context, 'Error', sub: 'Failed to republish job'\);\n\s*\}",
     "} catch (e) {\n                        if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to republish job');\n                      }"),
    (r"\} catch \(e\) \{\n\s*if \(context.mounted\) UJobToast.error\(context, 'Error', sub: 'Failed to reopen job'\);\n\s*\}",
     "} catch (e) {\n                        if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to reopen job');\n                      }"),
    (r"\} catch \(e\) \{\n\s*if \(context.mounted\) UJobToast.error\(context, 'Error', sub: 'Failed to pause job'\);\n\s*\}",
     "} catch (e) {\n                        if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to pause job');\n                      }"),
    (r"\} catch \(e\) \{\n\s*if \(context.mounted\) \{\n\s*Navigator.pop\(ctx\);\n\s*UJobToast.error\(context, 'Error', sub: 'Failed to close job'\);\n\s*\}\n\s*\}",
     "} catch (e) {\n                          if (context.mounted) {\n                            Navigator.pop(ctx);\n                            UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to close job');\n                          }\n                        }"),
    (r"\} catch \(e\) \{\n\s*if \(context.mounted\) \{\n\s*Navigator.pop\(ctx\);\n\s*UJobToast.error\(context, 'Error', sub: 'Failed to delete job'\);\n\s*\}\n\s*\}",
     "} catch (e) {\n                          if (context.mounted) {\n                            Navigator.pop(ctx);\n                            UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to delete job');\n                          }\n                        }")
]

for pat, rep in patterns:
    text = re.sub(pat, rep, text)

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
    f.write(text)

